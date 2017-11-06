# MacroTween

[![Haxelib Version](https://img.shields.io/github/tag/JoeCreates/MacroTween.svg?style=flat-square&label=haxelib)](http://lib.haxe.org/p/MacroTween)
[![Travis Build Status](https://img.shields.io/travis/JoeCreates/MacroTween.svg?style=flat-square)](https://travis-ci.org/JoeCreates/MacroTween)
[![Code Climate](https://img.shields.io/codeclimate/issues/github/JoeCreates/MacroTween.svg?style=flat-square)](https://codeclimate.com/github/JoeCreates/MacroTween/issues)
[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](https://github.com/JoeCreates/MacroTween/blob/master/LICENSE)

MacroTween offers concise tweening without reflection, providing unrivalled performance and ease of use.

**WARNING: Currently in development and unstable!**

```haxe
// Concise arrow syntax
// Tween myObject.x to 100
Tween.tween(0, 1, [myObject.x => 100], Ease.quadInOut);

// Specify ranges
Tween.tween(0, 1, [myObject.x => 10...20]);

// Tween local variables
var x:Float = 10;
Tween.tween(0, 1, [x => 100]);

// Tween multiple objects at once
Tween.tween(0, 1, [object1.x => 100, object2.x => 200]);

// Compound expressions
Tween.tween(0, 1, [obj => [x => 100, y => 100]]);
Tween.tween(0, 1, [[objA, objB] => [x => 100, y => 100]]);

// Implicit start or end values
// A reverse tween from t=1...0 would tween from whatever the initial value is to 10
Tween.tween(0, 1, [myObject.x => 10..._]);

// Repeatedly call function with tweening parameters
Tween.tween(0, 1, [myFunc(10...20)]);

```

## How it works
Unlike typical tweening libraries which use reflection, MacroTween generates a object with methods to return and set the value of a variable. For example:

```haxe
// This macro call...
Tween.tween(0, 1, [myObj.x => 100]);

// ...creates the following object
{
  startValue: null,
  endValue: 100,
  implicitStart: true,
  implicitEnd: false,
  currentValue:
    function():Float {
      return myObj.x
    },
  tween:
    function(startValue:Float, endValue:Float, tween:Tween, time:Float):Void {
      myObj.x = startValue + progress * (endValue - startValue);
    }
}
```

The `currentValue` and `tween` functions can be used to set and get the value of `myObj.x` without using reflection, providing considerable performance benefits.

