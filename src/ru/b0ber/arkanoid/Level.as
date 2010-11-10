package ru.b0ber.arkanoid {
import org.casalib.display.CasaSprite;

import flash.events.Event;

/**
 * @author Andrey Bobkv
 */
public class Level extends CasaSprite {
public static const WIN_EVENT:String = "levelWin";
private static const LEVELS:Array = [
  [
    [1,1,1,1,1,1,1,1,1,1],
    [1,1,1,1,0,0,1,1,1,1],
    [0,0,1,1,1,1,1,1,0,0]
  ],
  [
    [0,1,1,0,0,0,0,1,1,0],
    [0,0,1,1,1,1,1,1,0,0],
    [0,1,1,1,0,0,1,1,1,0],
    [1,1,1,1,1,1,1,1,1,1]
  ]
];

private var levelNum:uint;
private var level:Array;
private var _bricks:Vector.<Brick> = new Vector.<Brick>();
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
        _bricks.push(brick);
      }
    }
  }
}

public function get bricks():Vector.<Brick> {
  return _bricks;
}

public function hitBrick(brick:Brick):void {
  const index:int = _bricks.indexOf(brick);
  if (index == -1) {
    throw new Error("[Error] no such brick");
  }
  removeChild(brick);
  _bricks.splice(index, 1);
  if (_bricks.length == 0) {
    dispatchEvent(new Event(Level.WIN_EVENT));
  }
}

}
}
