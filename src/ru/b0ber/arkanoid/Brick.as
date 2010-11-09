package ru.b0ber.arkanoid {
	import org.casalib.display.CasaSprite;

/**
 * @author Andrey Bobkv
 */
public class Brick extends CasaSprite {
public static const WIDTH:Number = 50;
public static const HEIGHT:Number = 20;
public function Brick(initialX:Number, initialY:Number) {
  super();
  graphics.beginFill(0x00FF00);
  graphics.drawRect(0, 0, WIDTH, HEIGHT);
  graphics.endFill();
  x = initialX;
  y = initialY;
}
}
}
