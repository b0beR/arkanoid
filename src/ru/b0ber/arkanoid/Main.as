package ru.b0ber.arkanoid {
import flash.utils.setTimeout;
import flash.text.TextFormatAlign;
import ru.b0ber.arkanoid.buttons.ExitButton;
import ru.b0ber.arkanoid.buttons.StartButton;
import ru.b0ber.arkanoid.loader.BatchLoader;
import ru.b0ber.arkanoid.loader.LoaderEvent;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.text.TextField;
import flash.text.TextFormat;

/**
 * @author Andrey Bobkov
 */
[Swf(width=640, height=480, frameRate=60)]
public class Main extends Sprite {
public static const FIELD_WIDTH:Number = 640;
public static const FIELD_HEIGHT:Number = 480;
private var ball:Ball;
private var bat:Bat;
private var level:Level;
private var game:Sprite = new Sprite();
private var menu:Sprite = new Sprite();
private var startButton:StartButton = new StartButton();
private var exitButton:ExitButton = new ExitButton();
private var loader:BatchLoader;
private var lives:uint = 3;
private var textField:TextField = new TextField();

public function Main() {
  super();
  stage.scaleMode = StageScaleMode.NO_SCALE;
  stage.align = StageAlign.TOP_LEFT;
  
  loader = new BatchLoader();
  loader.add("../resources/ball.png", "ball");
  loader.add("../resources/brick.png", "brick");
  loader.add("../resources/wall.jpeg", "wall");
  loader.addEventListener(LoaderEvent.BATCH_COMPLETE, loadComplete);
  loader.start(5);
}

private function loadComplete(event:LoaderEvent):void {
  graphics.beginBitmapFill((loader.getContents("wall") as Bitmap).bitmapData);
  graphics.drawRect(0, 0, FIELD_WIDTH, FIELD_HEIGHT);
  graphics.endFill();
  bat = new Bat(320, 470);
  game.addChild(bat);
  addEventListener(Event.ENTER_FRAME, bat.moveOneFrame);
  stage.addEventListener(KeyboardEvent.KEY_DOWN, bat.keyDownListener);
  stage.addEventListener(KeyboardEvent.KEY_UP, bat.keyUpListener);
  ball = new Ball(bat);
  game.addChild(ball);
  addEventListener(Event.ENTER_FRAME, ball.moveOneFrame);
  stage.addEventListener(KeyboardEvent.KEY_DOWN, ball.keyDownListener);
  ball.addEventListener(Ball.FAIL_EVENT, ballFail);
  
  textField.x = 0;
  textField.width = 640;
  textField.y = 240;
  var tf:TextFormat = new TextFormat();
  tf.size = 22;
  tf.align = TextFormatAlign.CENTER;
  textField.defaultTextFormat = tf;
  
  startButton.x = 320;
  startButton.y = 210;
  startButton.addEventListener(MouseEvent.CLICK, startGame);
  menu.addChild(startButton);
  exitButton.x = 320;
  exitButton.y = 270;
  exitButton.addEventListener(MouseEvent.CLICK, exitButtonListener);
  menu.addChild(exitButton);
  
  addChild(menu);
}

private function startGame(..._):void {
  removeChild(menu);
  level = new Level(1);
  level.addEventListener(Level.WIN_EVENT, winLevel);
  game.addChild(level);
  ball.currentLevel = level;
  addChild(game);
  lives = 3;
  ball.restore();
}

private function showMenu():void {
  removeChild(game);
  addChild(menu);
}


private function ballFail(..._):void {
  ball.restore();
  lives--;
  if (lives == 0) {
    textField.text = "Вы проиграли!";
    game.addChild(textField);
    setTimeout(function():void {
      game.removeChild(textField);
      game.removeChild(level);
      showMenu();
    }, 2000);
  }
}

private function winLevel(..._):void {
  textField.text = "Вы выиграли!";
  game.addChild(textField);
  setTimeout(function():void {
    game.removeChild(textField);
    game.removeChild(level);
    showMenu();
  }, 2000);
}

private function exitButtonListener(..._):void {
  ExternalInterface.call("window.close");
}

}
}
