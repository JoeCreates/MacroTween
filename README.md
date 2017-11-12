# MacroTween

[![Haxelib Version](https://img.shields.io/github/tag/JoeCreates/MacroTween.svg?style=flat-square&label=haxelib)](http://lib.haxe.org/p/MacroTween)
[![Travis Build Status](https://img.shields.io/travis/JoeCreates/MacroTween.svg?style=flat-square)](https://travis-ci.org/JoeCreates/MacroTween)
[![Code Climate](https://img.shields.io/codeclimate/issues/github/JoeCreates/MacroTween.svg?style=flat-square)](https://codeclimate.com/github/JoeCreates/MacroTween/issues)
[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](https://github.com/JoeCreates/MacroTween/blob/master/LICENSE)

MacroTween offers concise tweening and timelines.

**WARNING: Currently in development and unstable!**

```haxe
// Concise arrow syntax
// Tween myObject.x to 100
Tween.tween(0, 1, myObject.x => 100, Ease.quadInOut);

// Specify ranges
Tween.tween(0, 1, myObject.x => 10...20);

// Tween local variables
var x:Float = 10;
Tween.tween(0, 1, x => 100);

// Tween multiple objects at once
Tween.tween(0, 1, [object1.x => 100, object2.x => 200]);

// Compound expressions
Tween.tween(0, 1, obj => [x => 100, y => 100]);
Tween.tween(0, 1, [objA, objB] => [x => 100, y => 100]);
Tween.tween(0, 1, mySprite.scale => [[x, y] => 100]]);

// Implicit start or end values
// A reverse tween from t=1...0 would tween from whatever the initial value is to 10
Tween.tween(0, 1, myObject.x => 10..._);

// Repeatedly call function with tweening parameters
Tween.tween(0, 1, myFunc(10...20));

```

# Notes
 * Read the documentation [here](https://joecreates.github.io/MacroTween/macrotween/index.html).