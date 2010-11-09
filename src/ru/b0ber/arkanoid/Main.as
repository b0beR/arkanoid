package ru.b0ber.arkanoid {
import flash.ui.Keyboard;
import flash.events.KeyboardEvent;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.geom.Point;

/**
 * @author Andrey Bobkv
 */
public class Main extends Sprite {
public static const FIELD_WIDTH:Number = 640;
public static const FIELD_HEIGHT:Number = 480;
private var ball:Ball;
private var bat:Bat;

[Swf(width=640, height=480, frameRate=60)]
public function Main() {
  super();
  trace("[FrameRate] ", stage.frameRate);
  stage.scaleMode = StageScaleMode.NO_SCALE;
  stage.align = StageAlign.TOP_LEFT;
  bat = new Bat(320, 470);
  addChild(bat);
  addEventListener(Event.ENTER_FRAME, bat.moveOneFrame);
  stage.addEventListener(KeyboardEvent.KEY_DOWN, bat.keyDownListener);
  stage.addEventListener(KeyboardEvent.KEY_UP, bat.keyUpListener);
  
  addChild(new Level(0));
  
  stage.addEventListener(KeyboardEvent.KEY_DOWN, function(event:KeyboardEvent):void {
    if (ball == null && event.keyCode == Keyboard.SPACE) {
      ball = new Ball(320, 230, new Point(5, 8), bat);
      addChild(ball);
      addEventListener(Event.ENTER_FRAME, ball.moveOneFrame);
      ball.addEventListener(Ball.FAIL_EVENT, function(..._):void {
        removeChild(ball);
        removeEventListener(Event.ENTER_FRAME, ball.moveOneFrame);
        ball.destroy();
        ball = null;
      });
    }
  });
}
}
}
