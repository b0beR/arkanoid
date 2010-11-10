package ru.b0ber.arkanoid {
import ru.b0ber.arkanoid.loader.BatchLoader;

import org.casalib.display.CasaSprite;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * @author Andrey Bobkov
 */
public class Ball extends CasaSprite {
public static const FAIL_EVENT:String = "ballFail";
private static const BALL_RADIUS:Number = 10;
private var speed:Point;
private var bat:Bat;
private var level:Level;

public function Ball(initialX:Number, initialY:Number, initialSpeed:Point, currentBat:Bat, currentLevel:Level) {
  super();
//  graphics.beginFill(0xFF0000);
//  graphics.drawCircle(0, 0, BALL_RADIUS);
//  graphics.endFill();
  const bd:BitmapData = (BatchLoader.getInstance().getContents("ball") as Bitmap).bitmapData;
  const bmp:Bitmap = new Bitmap(bd);
  bmp.x = -10;
  bmp.y = -10;
  addChild(bmp);
  x = initialX;
  y = initialY;
  speed = initialSpeed;
  bat = currentBat;
  level = currentLevel;
}

/*
 * Пересчет координат и проверки на столкновения.
 * Должна вызываться по событию ENTER_FRAME
 */
public function moveOneFrame(..._):void {
  x += speed.x;
  y += speed.y;
  testLevel();
  testBat();
  testWalls();
}

/*
 * Проверка на столкновение со стенами.
 * Если пересекаем нижнюю стену, шарик проигран
 */
private function testWalls():void {
  if (x < BALL_RADIUS) {
    x = 2 * BALL_RADIUS - x;
    speed.x = -speed.x;
  } else if (x > (Main.FIELD_WIDTH - BALL_RADIUS)) {
    x = 2 * (Main.FIELD_WIDTH - BALL_RADIUS) - x;
    speed.x = -speed.x;
  }
  if (y < BALL_RADIUS) {
    y = 2 * BALL_RADIUS - y;
    speed.y = -speed.y;
  } else if (y > (Main.FIELD_HEIGHT - BALL_RADIUS)) {
    dispatchEvent(new Event(Ball.FAIL_EVENT));
  }
}

/*
 * Проверка на столкновение с платформой.
 * Если платформа двигается, то угол отражения шарика изменяется в направлении движения.
 * Таким образом можно точнее управлять шариком.
 */
private function testBat():void {
  // Прямоугольник, содержащий платформу
  const batRect:Rectangle = bat.getBounds(parent);
  // Модуль вектора скорости
  const _speed:Number = Math.sqrt(speed.x * speed.x + speed.y * speed.y);
  if (y + BALL_RADIUS > batRect.y) {
    // Находим x - координату точки пересечения шариком линии платформы
    var intersectX:Number = x - (y + BALL_RADIUS - batRect.y) * speed.x / speed.y;
    if (intersectX >= batRect.left && intersectX <= batRect.right) {
      // Пересчитываем y-координату
      y = 2 * (batRect.y - BALL_RADIUS) - y;
      // Пересчитываем вектор скорости
      speed.x += bat.ballDx;
      
      if (_speed - Math.abs(speed.x) <= 0.2) {
        // Если после отскока шарик летит горизонтально, придаем ему небольшую вертикальную скорость
        speed.y = -1;
        speed.x = Math.sqrt(_speed * _speed - speed.y * speed.y);
      } else {
        speed.y = - Math.sqrt(_speed * _speed - speed.x * speed.x);
      }
    }
  }
}

/* 
 * Проверка всех кирпичей текущего уровня на столкновение
 */
private function testLevel():void {
  hb = new Vector.<Brick>();
  for each (var brick:Brick in level.bricks) {
    testBrick(brick);
  }
  for each (brick in hb) {
    level.hitBrick(brick);
  }
}

/*
 * Проверка на столкновение с данным кирпичом.
 * Внутри много проверок для реализации правильной геометрии отскока шарика от граней и углов кирпича
 */
private function testBrick(brick:Brick):void {
  // Прямоугольник, содержащий кирпич. С Rectangle удобнее работать :-)
  const brickRect:Rectangle = brick.getBounds(parent);
  // Текущая точка
  const currentPoint:Point = new Point(x, y);
  // Правый верхний и левый нижний углы прямоугольника brickRect (Нужны для проверки соударения с углами кирпича)
  const topRight:Point = new Point(brickRect.right, brickRect.top);
  const bottomLeft:Point = new Point(brickRect.left, brickRect.bottom);
  
  // Это нам понадобится при проверке соударения с гранями кирпича
  var intersectX:Number;
  var intersectY:Number;
  
  // Проверяем грани кирпича
  if (speed.y > 0 && y + BALL_RADIUS >= brickRect.top && y - speed.y + BALL_RADIUS < brickRect.top) {
    // Верхняя грань. Ищем x-координату точки пересечения с прямой содержащей грань
    intersectX = x - (y + BALL_RADIUS - brickRect.top) * speed.x / speed.y;
    if (intersectX >= brickRect.left && intersectX <= brickRect.right) {
      // Точка пересечения лежит на верхней грани : пересчитываем координаты
      y = 2 * (brickRect.top - BALL_RADIUS) - y;
      // Меняем вертикальную скорость
      speed.y = -speed.y;
      // Ставим кирпич в очередь на уничтожение
      hitBrick(brick);
      trace("top");
    }
  } else if (speed.y < 0 && y - BALL_RADIUS <= brickRect.bottom && y - speed.y - BALL_RADIUS > brickRect.bottom) {
    // Нижняя грань. Ищем x-координату точки пересечения с прямой содержащей грань
    intersectX = x - (brickRect.bottom - y + BALL_RADIUS) * speed.x / speed.y;
    if (intersectX >= brickRect.left && intersectX <= brickRect.right) {
      // Точка пересечения лежит на нижней грани : пересчитываем координаты
      y = 2 * (brickRect.bottom + BALL_RADIUS) - y;
      // Меняем вертикальную скорость
      speed.y = -speed.y;
      // Ставим кирпич в очередь на уничтожение
      hitBrick(brick);
      trace("bottom");
    }
  } else if (speed.x > 0 && x + BALL_RADIUS >= brickRect.left && x - speed.x + BALL_RADIUS < brickRect.left) {
    // Левая грань. Ищем y-координату точки пересечения с прямой содержащей грань
    intersectY = y - (x + BALL_RADIUS - brickRect.left) * speed.y / speed.x;
    if (intersectY >= brickRect.top && intersectY <= brickRect.bottom) {
      // Точка пересечения лежит на левой грани : пересчитываем координаты
      x = 2 * (brickRect.left - BALL_RADIUS) - x;
      // Меняем горизонтальную скорость
      speed.x = -speed.x;
      // Ставим кирпич в очередь на уничтожение
      hitBrick(brick);
      trace("left");
    }
  } else if (speed.x < 0 && x - BALL_RADIUS <= brickRect.right && x - speed.x - BALL_RADIUS > brickRect.right) {
    // Правая грань. Ищем y-координату точки пересечения с прямой содержащей грань
    intersectY = y - (brickRect.right - x + BALL_RADIUS) * speed.y / speed.x;
    if (intersectY >= brickRect.top && intersectY <= brickRect.bottom) {
      // Точка пересечения лежит на левой грани : пересчитываем координаты
      x = 2 * (brickRect.right + BALL_RADIUS) - x;
      // Меняем горизонтальную скорость
      speed.x = -speed.x;
      // Ставим кирпич в очередь на уничтожение
      hitBrick(brick);
      trace("right");
    }
  } else 
  // Далее проверяем столкновение шарика с углами кирпича (при этом меняется угол направления шарика
  if ((speed.x > 0 || speed.y > 0) && distance(currentPoint, brickRect.topLeft) <= BALL_RADIUS) {
    // Левый верхний угол
    hitCorner(brickRect.topLeft);
    trace("top_left");
    hitBrick(brick);
  } else if ((speed.x > 0 || speed.y > 0) && distance(currentPoint, topRight) <= BALL_RADIUS) {
    // Правый верхний угол
    hitCorner(topRight);
    trace("top_right");
    hitBrick(brick);
  } else if ((speed.x > 0 || speed.y > 0) && distance(currentPoint, bottomLeft) <= BALL_RADIUS) {
    // Левый нижний угол
    hitCorner(bottomLeft);
    trace("bottom_left");
    hitBrick(brick);
  } else if ((speed.x > 0 || speed.y > 0) && distance(currentPoint, brickRect.bottomRight) <= BALL_RADIUS) {
    // Правый нижний угол
    hitCorner(brickRect.bottomRight);
    trace("borrom_right");
    hitBrick(brick);
  }
}

/*
 * Находит расстояние между двумя точками. Нужна для проверки соударения с углами кирпича
 */
private function distance(p1:Point, p2:Point):Number {
  return Math.sqrt((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y));
}

/*
 * Эта функция пересчитывает координаты и скорость при столкновении с углом кирпича. 
 * Работает одинаково для любого из углов, поэтому вынесена в отдельную функцию.
 * Внутри - магия с векторами, вспомнил школьную геометрию :-)
 */
private function hitCorner(corner:Point):void {
    // Точка соударения с углом
    const hitPoint:Point = getHitPoint(corner);
    // Вектор угол -> точка соударения. Служит нормалью для отражения вектора скорости и перемещения
    const d:Point = new Point(hitPoint.x - corner.x, hitPoint.y - corner.y);
    // Часть вектора перемещения, которую необходимо отразить от угла
    const dxy:Point = new Point(x - hitPoint.x, y - hitPoint.y);
    // Модуль корректирующего вектора (для отражения вектора перемещения). Равен удвоенной проекции dxy на d
    const _a:Number = Math.abs(2 * (dxy.x * d.x + dxy.y * d.y) / BALL_RADIUS);
    // Корректирующий вектор (сонаправлен с d)
    const a:Point = new Point(d.x * _a / BALL_RADIUS, d.y * _a / BALL_RADIUS);
    // Применяем вектор a к координатам. Теперь шарик в правильной точке после отскока от угла
    x += a.x;
    y += a.y;
    // Модуль скорости (нужен для смены направления).
    const _speed:Number = Math.sqrt(speed.x * speed.x + speed.y * speed.y);
    // Это модуль отраженной части вектора перемещения.
    const _dxy:Number = Math.sqrt((x - hitPoint.x) * (x - hitPoint.x) + (y - hitPoint.y) * (y - hitPoint.y));
    // Вектор скорости теперь сонаправлен с отраженной частью вектора перемещения
    speed.x = (x - hitPoint.x) / _dxy * _speed;
    speed.y = (y - hitPoint.y) / _dxy * _speed;
    if (Math.abs(speed.y) < 0.5) {
      // Если после отскока шарик летит горизонтально, придаем ему небольшую вертикальную скорость
      speed.y = 1;
      speed.x = Math.sqrt(_speed * _speed - speed.y * speed.y);
    }
}

/*
 * Находит точку столкновения шарика с углом 
 * (т. к. изменение координат дискретно, эта точка лежит на уже пройденном пути)
 */
private function getHitPoint(p:Point):Point {
  const xyr:Number = speed.x / speed.y;
  // Тут решаем квадратное уравнение. a, b, c - коэффициенты
  const a:Number = (xyr * xyr) + 1;
  const b:Number = 2 * x * xyr - 2 * y * (xyr * xyr) - 2 * p.x * xyr - 2 * p.y;
  const c:Number = (x - y * xyr - p.x) * (x - y * xyr - p.x) + (p.y * p.y) - (BALL_RADIUS * BALL_RADIUS);
  // d - дискриминант
  const d:Number = (b * b) - 4 * a * c;
  if (d < 0) {
    // Решение должно существовать :-))
    throw new Error("Cannot find a hit point");
  } else if (d == 0) {
    // Удар об угол по касательной. При этом траектория практически не изменится.
    const _y:Number = (-b) / (2 * a);
    const _x:Number = x - (y - _y) * xyr;
    return new Point(_x, _y);
  } else {
    // Нормальное столкновение. При этом мы получаем две точки удовлетворяющих уравнению
    const _y1:Number = (-b + Math.sqrt(d)) / (2 * a);
    const _x1:Number = x - (y - _y1) * xyr;
    const _y2:Number = (-b - Math.sqrt(d)) / (2 * a);
    const _x2:Number = x - (y - _y2) * xyr;
    // Из этих точек мы выбираем ту, которая лежит в направлении, противоположном скорости
    // Для проверки используем свойства скалярного произведения векторов
    if ((_x1 - x) * speed.x + (_y1 - y) * speed.y < 0) {
      return new Point(_x1, _y1);
    } else if ((_x2 - x) * speed.x + (_y2 - y) * speed.y < 0) {
      return new Point(_x2, _y2);
    }
  }
  return null;
}

private var hb:Vector.<Brick>;
private function hitBrick(brick:Brick):void {
  // setTimeout нужен для того чтобы кирпич удалился из вектора 
  // только когда закончится вся проверка, иначе индексы собьются
  //setTimeout(level.hitBrick, 0, brick);
  if (hb.indexOf(brick) == -1) {
    hb.push(brick);
  } else {
    trace("duplicate");
  }
}


}
}
