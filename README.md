# MacroTween

[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://github.com/JoeCreates/MacroTween/blob/master/LICENSE)
[![Build Status Badge](https://ci.appveyor.com/api/projects/status/github/Tw1ddle/MacroTween)](https://ci.appveyor.com/project/Tw1ddle/MacroTween)

MacroTween is a Haxe library for concise tweening and timelines.

**WARNING: Currently in development and incomplete, we haven't used it for any big projects yet!**

Run the demo in your [browser](https://joecreates.github.io/MacroTweenDemo/index.html).

## Usage

```haxe
// Concise arrow syntax
// Tween myObject.x to 100
Tween.tween(myObject.x => 100, Ease.quadInOut);

// Specify ranges
Tween.tween(myObject.x => 10...20);

// Tween local variables
var x:Float = 10;
Tween.tween(x => 100);

// Tween multiple objects at once
Tween.tween([object1.x => 100, object2.x => 200]);

// Compound expressions
Tween.tween(obj => [x => 100, y => 100]);
Tween.tween([objA, objB] => [x => 100, y => 100]);
Tween.tween( mySprite.scale => [[x, y] => 100]]);

// Implicit start or end values
// A reverse tween from t=1...0 would tween from whatever the initial value is to 10
Tween.tween( myObject.x => 10..._);

// Repeatedly call function with tweening parameters
Tween.tween(myFunc(10...20));

//TODO
// Tween from timeline
timeline.tween(...);

// Chaining
timeline.tween(...).tween(...);

```

See more usage examples in the [unit tests](https://github.com/JoeCreates/MacroTween/blob/master/unit/tests/TestReadmeExamples.hx) and [demo code](https://github.com/JoeCreates/MacroTweenDemo)

[![Graphs Tween Demo](https://github.com/JoeCreates/MacroTweenDemo/blob/master/screenshots/graphs_demo_animation.gif?raw=true "MacroTween Graphs Demo Screenshot")](https://joecreates.github.io/MacroTweenDemo/index.html)

## Notes
 * Got an idea or request? Open an issue on [GitHub](https://github.com/JoeCreates/MacroTween) or contact [Joe](https://twitter.com/JoeCreates) and [Sam](https://twitter.com/Sam_Twidale).
 * Read the documentation [here](https://joecreates.github.io/MacroTween/macrotween/index.html).
