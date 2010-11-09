package ru.b0ber.arkanoid {
import flash.utils.setTimeout;
import flash.geom.Rectangle;
import org.casalib.display.CasaSprite;

import flash.events.Event;
import flash.geom.Point;

/**
 * @author Andrey Bobkv
 */
public class Ball extends CasaSprite {
public static const FAIL_EVENT:String = "ballFail";
private static const BALL_RADIUS:Number = 5;
private var speed:Point;
private var bat:Bat;
private var level:Level;

public function Ball(initialX:Number, initialY:Number, initialSpeed:Point, currentBat:Bat, currentLevel:Level) {
  super();
  graphics.beginFill(0xFF0000);
  graphics.drawCircle(0, 0, BALL_RADIUS);
  graphics.endFill();
//  graphics.beginFill(0xFFFF00);
//  graphics.drawCircle(-BALL_RADIUS / 4, -BALL_RADIUS / 2, 3);
//  graphics.endFill();
  x = initialX;
  y = initialY;
  speed = initialSpeed;
  bat = currentBat;
  level = currentLevel;
//  if (bat != null) {
//    trace(x,y, speed);
//    var p:Point = hitPoint(new Point(x - BALL_RADIUS / 4, y - BALL_RADIUS / 2));
//    
//    graphics.lineStyle(3, 0x00FF00);
//    graphics.moveTo(0, 0);
//    graphics.lineTo(speed.x, speed.y);
//    graphics.lineStyle(3, 0x0000FF);
//    graphics.moveTo(0, 0);
//    graphics.lineTo(p.x - x, p.y - y);
//    
//    const d:Point = new Point(p.x - (x - BALL_RADIUS / 4), p.y - (y - BALL_RADIUS / 2));
//    trace(d);
//    const _d:Number = Math.sqrt(d.x * d.x + d.y * d.y);
//    trace(_d);
//    const xy:Point = new Point(x - p.x, y - p.y);
//    trace(xy);
//    const da:Number = Math.abs(2 * (xy.x * d.x + xy.y * d.y) / BALL_RADIUS) / BALL_RADIUS;
//    trace((xy.x * d.x + xy.y + d.y) / BALL_RADIUS);
//    const a:Point = new Point(d.x * da, d.y * da);
//    trace(a);
//    const b:Point = new Point(xy.x + 2 * a.x, xy.y + 2 * a.y);
//    trace(b);
//    
//    graphics.lineStyle(3, 0x00FFFF);
//    graphics.moveTo(p.x - x, p.y - y);
//    graphics.lineTo(p.x + a.x - x, p.y + a.y - y);
//    
//    
//    speed.x = 0;
//    speed.y = 0;
//  }
}

public function moveOneFrame(..._):void {
  x += speed.x;
  y += speed.y;
  testLevel();
  testBat();
  testWalls();
}

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

private function testBat():void {
  const batRect:Rectangle = bat.getBounds(parent);
  const _speed:Number = Math.sqrt(speed.x * speed.x + speed.y * speed.y);
  if (y + BALL_RADIUS > batRect.y) {
    var intersectX:Number = x - (y + BALL_RADIUS - batRect.y) * speed.x / speed.y;
    if (intersectX >= batRect.left && intersectX <= batRect.right) {
      y = 2 * (batRect.y - BALL_RADIUS) - y;
      speed.y = -speed.y;
      speed.x += bat.ballDx;
      speed.y = (speed.y / Math.abs(speed.y)) * Math.sqrt(_speed * _speed - speed.x * speed.x);
    }
  }
}

private function testLevel():void {
  hb = new Vector.<Brick>();
  for each (var brick:Brick in level.bricks) {
    testBrick(brick);
  }
  for each (brick in hb) {
    level.hitBrick(brick);
  }
}

private function testBrick(brick:Brick):void {
  const brickRect:Rectangle = brick.getBounds(parent);
  const currentPoint:Point = new Point(x, y);
  var intersectX:Number;
  var intersectY:Number;
  const topRight:Point = new Point(brickRect.right, brickRect.top);
  const bottomLeft:Point = new Point(brickRect.left, brickRect.bottom);
  var p:Point;
  var d:Point;
  var xy:Point;
  var da:Number;
  var a:Point;
  var b:Point;
  const _speed:Number = Math.sqrt(speed.x * speed.x + speed.y * speed.y);
  var _newxy:Number;
  if (speed.y > 0 && y + BALL_RADIUS >= brickRect.top && y - speed.y + BALL_RADIUS < brickRect.top) {
    intersectX = x - (y + BALL_RADIUS - brickRect.top) * speed.x / speed.y;
    if (intersectX >= brickRect.left && intersectX <= brickRect.right) {
      y = 2 * (brickRect.top - BALL_RADIUS) - y;
      speed.y = -speed.y;
      hitBrick(brick);
    }
  } else if (speed.y < 0 && y - BALL_RADIUS <= brickRect.bottom && y - speed.y - BALL_RADIUS > brickRect.bottom) {
    intersectX = x - (brickRect.bottom - y + BALL_RADIUS) * speed.x / speed.y;
    if (intersectX >= brickRect.left && intersectX <= brickRect.right) {
      y = 2 * (brickRect.bottom + BALL_RADIUS) - y;
      speed.y = -speed.y;
      hitBrick(brick);
    }
  } else if (speed.x > 0 && x + BALL_RADIUS >= brickRect.left && x - speed.x + BALL_RADIUS < brickRect.left) {
    intersectY = y - (x + BALL_RADIUS - brickRect.left) * speed.y / speed.x;
    if (intersectY >= brickRect.top && intersectY <= brickRect.bottom) {
      x = 2 * (brickRect.left - BALL_RADIUS) - x;
      speed.x = -speed.x;
      hitBrick(brick);
    }
  } else if (speed.x < 0 && x - BALL_RADIUS <= brickRect.right && x - speed.x - BALL_RADIUS > brickRect.right) {
    intersectY = y - (brickRect.right - y + BALL_RADIUS) * speed.y / speed.x;
    if (intersectY >= brickRect.top && intersectY <= brickRect.bottom) {
      x = 2 * (brickRect.right + BALL_RADIUS) - x;
      speed.x = -speed.x;
      hitBrick(brick);
    }
  } else if (distance(currentPoint, brickRect.topLeft) <= BALL_RADIUS) {
    p = hitPoint(brickRect.topLeft);
    d = new Point(p.x - brickRect.topLeft.x, p.y - brickRect.topLeft.y);
    xy = new Point(x - p.x, y - p.y);
    da = Math.abs(2 * (xy.x * d.x + xy.y * d.y) / BALL_RADIUS) / BALL_RADIUS;
    a = new Point(d.x * da, d.y * da);
    b = new Point(xy.x + 2 * a.x, xy.y + 2 * a.y);
    
    x += b.x;
    y += b.y;

    _newxy = Math.sqrt((x - p.x) * (x - p.x) + (y - p.y) * (y - p.y));
    speed.x = (x - p.x) / _newxy * _speed;
    speed.y = (y - p.y) / _newxy * _speed;
    
    trace("top_left");
    hitBrick(brick);
  } else if (distance(currentPoint, topRight) <= BALL_RADIUS) {
    p = hitPoint(topRight);
    d = new Point(p.x - topRight.x, p.y - topRight.y);
    xy = new Point(x - p.x, y - p.y);
    da = Math.abs(2 * (xy.x * d.x + xy.y * d.y) / BALL_RADIUS) / BALL_RADIUS;
    a = new Point(d.x * da, d.y * da);
    b = new Point(xy.x + 2 * a.x, xy.y + 2 * a.y);
    
    x += b.x;
    y += b.y;

    _newxy = Math.sqrt((x - p.x) * (x - p.x) + (y - p.y) * (y - p.y));
    speed.x = (x - p.x) / _newxy * _speed;
    speed.y = (y - p.y) / _newxy * _speed;
    
    trace("top_right");
    hitBrick(brick);
  } else if (distance(currentPoint, bottomLeft) <= BALL_RADIUS) {
    p = hitPoint(bottomLeft);
    d = new Point(p.x - bottomLeft.x, p.y - bottomLeft.y);
    xy = new Point(x - p.x, y - p.y);
    da = Math.abs(2 * (xy.x * d.x + xy.y * d.y) / BALL_RADIUS) / BALL_RADIUS;
    a = new Point(d.x * da, d.y * da);
    b = new Point(xy.x + 2 * a.x, xy.y + 2 * a.y);
    
    x += b.x;
    y += b.y;

    _newxy = Math.sqrt((x - p.x) * (x - p.x) + (y - p.y) * (y - p.y));
    speed.x = (x - p.x) / _newxy * _speed;
    speed.y = (y - p.y) / _newxy * _speed;
    
    
    trace("bottom_left");
    hitBrick(brick);
  } else if (distance(currentPoint, brickRect.bottomRight) <= BALL_RADIUS) {
    p = hitPoint(brickRect.bottomRight);
    d = new Point(p.x - brickRect.bottomRight.x, p.y - brickRect.bottomRight.y);
    xy = new Point(x - p.x, y - p.y);
    da = Math.abs(2 * (xy.x * d.x + xy.y * d.y) / BALL_RADIUS) / BALL_RADIUS;
    a = new Point(d.x * da, d.y * da);
    b = new Point(xy.x + 2 * a.x, xy.y + 2 * a.y);
    
    x += b.x;
    y += b.y;

    _newxy = Math.sqrt((x - p.x) * (x - p.x) + (y - p.y) * (y - p.y));
    speed.x = (x - p.x) / _newxy * _speed;
    speed.y = (y - p.y) / _newxy * _speed;
    
    
    trace("borrom_right");
    hitBrick(brick);
  }
}


private function distance(p1:Point, p2:Point):Number {
  return Math.sqrt((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y));
}

private function hitPoint(p:Point):Point {
  const xyr:Number = speed.x / speed.y;
  const a:Number = xyr * xyr + 1;
  const b:Number = 2 * x * xyr - 2 * y * xyr * xyr - 2 * p.x * xyr - 2 * p.y;
  const c:Number = (x - y * xyr - p.x) * (x - y * xyr - p.x) + p.y * p.y - BALL_RADIUS * BALL_RADIUS;
  const d:Number = b * b - 4 * a * c;
  if (d < 0) {
    trace("unsolvable");
    return null;
  } else if (d == 0) {
    //trace("single solution");
    const _y:Number = (-b) / (2 * a);
    const _x:Number = x - (y - _y) * xyr;
    //trace("y=", _y, "   x=", _x);
    return new Point(_x, _y);
  } else {
    //trace("double solution");
    const _y1:Number = (-b + Math.sqrt(d)) / (2 * a);
    const _x1:Number = x - (y - _y1) * xyr;
    //trace("y=", _y1, "   x=", _x1);
    const _y2:Number = (-b - Math.sqrt(d)) / (2 * a);
    const _x2:Number = x - (y - _y2) * xyr;
    //trace("y=", _y2, "   x=", _x2);
    if ((_x1 - x) * speed.x + (_y1 - y) * speed.y < 0) {
      //trace("first");
      return new Point(_x1, _y1);
    } else if ((_x2 - x) * speed.x + (_y2 - y) * speed.y < 0) {
      //trace("second");
      return new Point(_x2, _y2);
    }
  }
  return new Point();
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
