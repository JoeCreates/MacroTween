package tests;

import macrotween.Tween;
import utest.Assert;
import utest.ITest;

/**
 * Introductory example code for the MacroTween tweening library readme
 */
class TestReadmeExamples implements ITest {
	private var myObject:{ x : Float };
	private var mySecondObject:{ y : Float };
	private var myThirdObject:{ a: Float, b: Float };
	private var myFourthObject: { v: { p: Float, q: Float } };
	
	public function new() {}
	
	public function setup():Void {
		myObject = { x: 0 };
		mySecondObject = { y: 0 };
		myThirdObject = { a: 0, b: 0 };
		myFourthObject = { v : { p: 0, q: 0 } };
	}

	public function testSimpleTween() {
		// Tween myObject.x to 100
		// Notice the concise arrow syntax!
		var tween = Tween.tween(myObject.x => 100);
		
		tween.stepTo(0, null, true);
		Assert.isTrue(myObject.x == 0);
		
		tween.stepTo(0.5, null, true);
		Assert.isTrue(myObject.x == 50);
		
		tween.stepTo(1, null, true);
		Assert.isTrue(myObject.x == 100);
	}
	
	public function testTweenWithRanges() {
		// Specify ranges, from 10 to 20!
		var tween = Tween.tween(myObject.x => 10...20);
		
		tween.stepTo(0, null, true);
		Assert.isTrue(myObject.x == 10);
		
		tween.stepTo(0.5, null, true);
		Assert.isTrue(myObject.x == 15);
		
		tween.stepTo(1, null, true);
		Assert.isTrue(myObject.x == 20);
	}
	
	public function testTweenWithLocalVariable() {
		// Tween local variables
		var x:Float = 50;
		var tween = Tween.tween(x => 100);
		
		tween.stepTo(0, null, true);
		Assert.isTrue(x == 50);
		
		tween.stepTo(0.5, null, true);
		Assert.isTrue(x == 75);
		
		tween.stepTo(1, null, true);
		Assert.isTrue(x == 100);
	}
	
	public function testTweenMultipleThings() {
		// Tween multiple things at once
		var z:Float = 0;
		var tween = Tween.tween([myObject.x => 100, mySecondObject.y => 200, z => 300]);
		
		tween.stepTo(0, null, true);
		Assert.isTrue(z == 0);
		
		tween.stepTo(0.5, null, true);
		Assert.isTrue(z == 150);
		
		tween.stepTo(1, null, true);
		Assert.isTrue(z == 300);
	}
	
	public function testCompoundExpressions() {
		// Tweening with compound expressions
		var t1 = Tween.tween(myThirdObject => [a => 100, b => 100]);
		
		t1.stepTo(0, null, true);
		Assert.isTrue(myThirdObject.a == 0 && myThirdObject.b == 0);
		t1.stepTo(0.5, null, true);
		Assert.isTrue(myThirdObject.a == 50 && myThirdObject.b == 50);
		t1.stepTo(1, null, true);
		Assert.isTrue(myThirdObject.a == 100 && myThirdObject.b == 100);
		
		var t2 = Tween.tween(myFourthObject.v => [[p, q] => 100]);
		
		t2.stepTo(0, null, true);
		Assert.isTrue(myFourthObject.v.p == 0 && myFourthObject.v.q == 0);
		t2.stepTo(0.5, null, true);
		Assert.isTrue(myFourthObject.v.p == 50 && myFourthObject.v.q == 50);
		t2.stepTo(1, null, true);
		Assert.isTrue(myFourthObject.v.p == 100 && myFourthObject.v.q == 100);
	}
	
	public function testImplicitStartOrEndValues() {
		// Tween with implicit start or end values
		// A reverse tween from t=1...0 would tween from whatever the initial value is to 10
		var tween = Tween.tween(myObject.x => 10..._);
		
		tween.stepTo(0, null, true);
		Assert.isTrue(myObject.x == 10);
		
		tween.stepTo(0.5, null, true);
		Assert.isTrue(myObject.x == 5);
		
		tween.stepTo(1, null, true);
		Assert.isTrue(myObject.x == 0);
	}
	
	public function testFunctionTween() {
		// Repeatedly call function with parameters
		var result:Float = 0;
		var myFunction = (v:Float)-> {
			result = v;
		};
		
		var tween = Tween.tween(myFunction(10...20));
		
		tween.stepTo(0, null, true);
		Assert.isTrue(result == 10);
		
		tween.stepTo(0.5, null, true);
		Assert.isTrue(result == 15);
		
		tween.stepTo(1.0, null, true);
		Assert.isTrue(result == 20);
		
		tween.stepTo(0.5, null, true);
		Assert.isTrue(result == 15);
		
		tween.stepTo(0, null, true);
		Assert.isTrue(result == 10);
	}
}