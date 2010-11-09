package ru.b0ber.arkanoid {
import flash.geom.Rectangle;
import org.casalib.display.CasaSprite;

import flash.events.Event;
import flash.geom.Point;

/**
 * @author Andrey Bobkv
 */
public class Ball extends CasaSprite {
public static const FAIL_EVENT:String = "ballFail";
private static const BALL_RADIUS:Number = 10;
private var speed:Point;
private var bat:Bat;

public function Ball(initialX:Number, initialY:Number, initialSpeed:Point, currentBat:Bat) {
  super();
  graphics.beginFill(0xFF0000);
  graphics.drawCircle(0, 0, BALL_RADIUS);
  graphics.endFill();
  x = initialX;
  y = initialY;
  speed = initialSpeed;
  bat = currentBat;
}

public function moveOneFrame(..._):void {
  x += speed.x;
  y += speed.y;
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
  if (y + BALL_RADIUS > batRect.y) {
    var intersectX:Number = x - (y + BALL_RADIUS - batRect.y) * speed.x / speed.y;
    if (intersectX >= batRect.left && intersectX <= batRect.right) {
      y = 2 * (batRect.y - BALL_RADIUS) - y;
      speed.y = -speed.y;
    }
  }
}

}
}
