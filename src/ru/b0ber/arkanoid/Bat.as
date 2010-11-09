package ru.b0ber.arkanoid {
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import org.casalib.display.CasaSprite;

/**
 * @author Andrey Bobkv
 */
public class Bat extends CasaSprite {
private const WIDTH:Number = 100;
private var dx:Number = 0;

public function Bat(initialX:Number, initialY:Number) {
  super();
  graphics.beginFill(0x000000);
  graphics.drawRect(-(WIDTH/2), 0, WIDTH, 10);
  graphics.endFill();
  x = initialX;
  y = initialY;
}

public function keyDownListener(event:KeyboardEvent):void {
  if (event.keyCode == Keyboard.LEFT) {
    dx = -10;
  } else if (event.keyCode == Keyboard.RIGHT) {
    dx = 10;
  } else {
    dx = 0;
  }
}

public function keyUpListener(event:KeyboardEvent):void {
  dx = 0;
}

public function moveOneFrame(..._):void {
  x += dx;
  if (x + (WIDTH / 2) > Main.FIELD_WIDTH) {
    x = Main.FIELD_WIDTH - (WIDTH / 2);
  }
  if (x - (WIDTH / 2) < 0) {
    x = WIDTH / 2;
  }
}

}
}
