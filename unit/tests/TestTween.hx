package tests;

import macrotween.Tween;
import tests.HelperObjects;
import utest.Assert;

/**
 * Tests the Tween class.
 */
class TestTween {
	public function new() {}
	
	function linear(x:Float) { return x; }
	
	public function testTweenSingleFieldToValue() {
		var myObject:{ x:Float } = { x: 0 };
		var tween:Tween = Tween.tween(0, 1, myObject.x => 100, linear);
		
		tween.stepTo(0);
		Assert.isTrue(myObject.x == 0);
		
		tween.stepTo(0.1);
		Assert.isTrue(myObject.x == 10);
		
		tween.stepTo(0.5);
		Assert.isTrue(myObject.x == 50);
		
		tween.stepTo(0.99);
		Assert.isTrue(myObject.x == 99);
		
		tween.stepTo(1);
		Assert.isTrue(myObject.x == 100);
	}
	
	public function testTweenSingleFieldWithImplicitStart() {
		var myObject:{ x:Float } = { x: 50 };
		var tween:Tween = Tween.tween(0, 1, [myObject.x => _...100], linear);
		
		tween.stepTo(0);
		Assert.isTrue(myObject.x == 50);
		
		tween.stepTo(1);
		Assert.isTrue(myObject.x == 100);
	}
	
	public function testMultiVariableSameValueTween() {
		var myObject:{ scale:{x:Float, y:Float}, position:{x:Float, y:Float}} = { scale: {x: 0, y: 0}, position: {x: 0, y: 0} };
		var tween:Tween = Tween.tween(0, 1, myObject => [[scale, position] => [[x, y] => 100]], linear);
		
		tween.stepTo(0);
		Assert.isTrue(myObject.position.x == 0 && myObject.scale.y == 0);

		tween.stepTo(0.5);
		Assert.isTrue(myObject.position.x == 50 && myObject.scale.y == 50);
	}
	
	public function testTweenRanges() {
		var myObject:{ x:Float } = { x: 0 };
		var tween:Tween = Tween.tween(0, 1, [myObject.x => 10...20], linear);
		
		tween.stepTo(0.0);
		Assert.isTrue(myObject.x == 10);
		
		tween.stepTo(0.5);
		Assert.isTrue(myObject.x == 15);
		
		tween.stepTo(1.0);
		Assert.isTrue(myObject.x == 20);
	}
	
	public function testTweenLocal() {
		var x:Float = 50;
		var tween:Tween = Tween.tween(0, 1, [x => 100], linear);
		
		Assert.isTrue(x == 50);
		
		tween.stepTo(0.0);
		Assert.isTrue(x == 50);
		
		tween.stepTo(0.5);
		Assert.isTrue(x == 75);
		
		tween.stepTo(1.0);
		Assert.isTrue(x == 100);
	}
	
	public function testMultipleObjectTweens() {
		var myObject:{ x:Float } = { x: 0 };
		var anotherObject:{ x:Float, y:Float, z:Float } = { x: 0, y: 0, z: 0 };
		
		var tween:Tween = Tween.tween(0, 1, [myObject.x => 100, anotherObject.x => 200], linear);
		
		tween.stepTo(0.0);
		Assert.isTrue(myObject.x == 0 && anotherObject.x == 0);
		
		tween.stepTo(0.5);
		Assert.isTrue(myObject.x == 50 && anotherObject.x == 100);
		
		tween.stepTo(1.0);
		Assert.isTrue(myObject.x == 100 && anotherObject.x == 200);
	}
	
	public function testCompoundMultipleFields() {
		var myObject:{ x:Float, y:Float } = { x: 0, y: 0 };
		
		var tween:Tween = Tween.tween(0, 1, [myObject => [x => 100, y => 100]], linear);
		
		tween.stepTo(0.0);
		Assert.isTrue(myObject.x == 0 && myObject.y == 0);
		
		tween.stepTo(0.5);
		Assert.isTrue(myObject.x == 50 && myObject.y == 50);
		
		tween.stepTo(1.0);
		Assert.isTrue(myObject.x == 100 && myObject.y == 100);
	}
	
	public function testCompoundMultipleObjects() {
		var myObject:{ x:Float, y:Float } = { x: 0, y: 0 };
		var anotherObject:{ x:Float, y:Float, z:Float } = { x: 0, y : 0, z : 0 };
		
		var tween:Tween = Tween.tween(0, 1, [[myObject, anotherObject] => [ x => 100, y => 200]], linear);
		
		Assert.isTrue(myObject.x == 0);
		
		tween.stepTo(0.5);
		
		Assert.isTrue(myObject.x == 50);
		Assert.isTrue(anotherObject.x == 50);
		
	}
	
	public function testImplicitStartOrEnd() {
		var myObject:{ x:Float } = { x: 0 };
		
		var tween:Tween = Tween.tween(0, 1, [myObject.x => 10..._], linear);
		
		tween.stepTo(0.5);
		Assert.isTrue(myObject.x == 5);
	}
	
	public function testFunctionTween() {
		var x:Float = 0;
		var myFunction = function (value:Float, add:Float):Void {
			x = value + add;
		};
		
		var tween:Tween = Tween.tween(0, 1, [myFunction(10...20, 10)], linear);
		
		Assert.isTrue(x == 0);
		tween.stepTo(0.5);
		Assert.isTrue(x == 25);
	}
	
	public function testPotentialKeywordConflicts() {
		var time:Float = 0;
		var tween:Float = 0;
		var startValue:Float = 0;
		var endValue:Float = 0;
		
		var t1 = Tween.tween(0, 1, [time => 100], linear);
		var t2 = Tween.tween(0, 1, [tween => 100], linear);
		var t3 = Tween.tween(0, 1, [startValue => 100], linear);
		var t4 = Tween.tween(0, 1, [endValue => 100], linear);
		
		for (t in [t1, t2, t3, t4]) t.stepTo(0.5);
		
		Assert.isTrue(time == 50 && tween == 50 && startValue == 50 && endValue == 50);
	}
	
	public function testTweenAbstract() {
		var x:HelperAbstractFloat = new HelperAbstractFloat(50.0);
		
		var tween:Tween = Tween.tween(0, 1, [x => 100], linear);
		
		Assert.isTrue(x == 50);
		
		tween.stepTo(0.0);
		Assert.isTrue(x == 50);
		
		tween.stepTo(0.5);
		Assert.isTrue(x == 75);
		
		tween.stepTo(1.0);
		Assert.isTrue(x == 100);
	}
	
	public function testTweenCallbacks() {
		var x:Float = 50;
		
		var cbt1:CallbackTween = Tween.tween(0.0, 1.0, x => 0...100, null, {pack: ["tests"], name: "CallbackTween"});
		
		var str:String = "";
		
		cbt1.leftHit = function(rev) {str += "1L" + (rev ? "r" : ""); };
		cbt1.rightHit = function(rev) {str += "1R" + (rev ? "r" : ""); };
		
		cbt1.stepTo(0);
		cbt1.stepTo(1);
		Assert.isTrue(x == 100);
		cbt1.stepTo(0);
		var expectedStr = "1L1R1Lr";
		
		Assert.isTrue(x == 0);
		Assert.isTrue(str == expectedStr, (str == expectedStr ? "" : ("Expected: " + expectedStr + ", Actual: " + str)));
	}
}