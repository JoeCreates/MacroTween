# MacroTween
MacroTween offers concise tweening with zero reflection, providing unrivalled performance and ease of use.

```haxe
// Concise arrow syntax
// Tween myObject.x to 100
Tween.tween(0, 1, [myObject.x => 100]);

// Specify ranges
Tween.tween(0, 1, [myObject.x => 10...20]);

// Tween local variables
var x = 10;
Tween.tween(0, 1, [x => 100]);

// Tween multiple objects at once
Tween.tween(0, 1, [object1.x => 100, object2.x => 200]);

// Compound expressions
Tween.tween(0, 1, [obj => [x => 100, y => 100]]

// Wildcards
// In this example, a forward tween would set myObject.x to 10 at t=0
// A reverse tween would tween from the intial value at t=1 to 10 at t=0
Tween.tween(0, 1, [myObject.x => 10..._]);

// Function tweening
// Repeatedly call a function with tweening parameters
Tween.tween(0, 1, [myFunc(10...20)]);

// Add tweens to a timeline 

```

## How it works


