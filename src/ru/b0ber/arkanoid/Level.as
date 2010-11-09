package ru.b0ber.arkanoid {
	import org.casalib.display.CasaSprite;

/**
 * @author Andrey Bobkv
 */
public class Level extends CasaSprite {
private static const LEVELS:Array = [
  [
    [1,1,1,1,1,1,1,1,1,1],
    [1,1,1,1,0,0,1,1,1,1],
    [0,0,1,1,1,1,1,1,0,0]
  ]
];

private var levelNum:uint;
private var level:Array;
private var bricks:Vector.<Brick> = new Vector.<Brick>();
public function Level(num:uint) {
  super();
  if (num >= LEVELS.length) {
    throw new Error("[Error] no such level");
  }
  levelNum = num;
  level = LEVELS[levelNum];
  var i:uint;
  var j:uint;
  var sx:Number;
  var row:Array;
  var brick:Brick;
  for (i = 0; i < level.length; i++) {
    row = level[i];
    sx = (Main.FIELD_WIDTH - (row.length * Brick.WIDTH + (row.length - 1) * 10)) / 2;
    for (j = 0; j < row.length; j++) {
      if (row[j] == 1) {
        brick = new Brick(sx + j * (Brick.WIDTH + 10), 40 + i * (Brick.HEIGHT + 10));
        addChild(brick);
        bricks.push(brick);
      }
    }
  }
}
}
}
