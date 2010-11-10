package ru.b0ber.arkanoid {
import ru.b0ber.arkanoid.loader.BatchLoader;

import org.casalib.display.CasaSprite;

import flash.display.Bitmap;
import flash.display.BitmapData;

/**
 * @author Andrey Bobkov
 */
public class Brick extends CasaSprite {
public static const WIDTH:Number = 73;
public static const HEIGHT:Number = 20;
public function Brick(initialX:Number, initialY:Number) {
  super();
//  graphics.beginFill(0x00FF00);
//  graphics.drawRect(0, 0, WIDTH, HEIGHT);
//  graphics.endFill();
  const bd:BitmapData = (BatchLoader.getInstance().getContents("brick") as Bitmap).bitmapData;
  addChild(new Bitmap(bd));
  x = initialX;
  y = initialY;
}
}
}
