package tests;

import macrotween.Tween;
import tests.HelperObjects;
import utest.Assert;
import utest.ITest;

/**
 * Tests the Tween class.
 */
class TestTween implements ITest {
	public function new() {}
	
	function linear(x:Float) { return x; }
	
	public function testTweenSingleFieldToValue() {
		var myObject:{ x:Float } = { x: 0 };
		var tween:Tween = Tween.tween(myObject.x => 100, 1, 0, linear);
		
		tween.stepTo(0, null, true);
		Assert.isTrue(myObject.x == 0);
		
		tween.stepTo(0.1, null, true);
		Assert.isTrue(myObject.x == 10);
		
		tween.stepTo(0.5, null, true);
		Assert.isTrue(myObject.x == 50);
		
		tween.stepTo(0.99, null, true);
		Assert.isTrue(myObject.x == 99);
		
		tween.stepTo(1, null, true);
		Assert.isTrue(myObject.x == 100);
	}
	
	public function testTweenSingleFieldWithImplicitStart() {
		var myObject:{ x:Float } = { x: 50 };
		var tween:Tween = Tween.tween([myObject.x => _...100], 1, 0, linear);
		
		tween.stepTo(0, null, true);
		Assert.isTrue(myObject.x == 50);
		
		tween.stepTo(1, null, true);
		Assert.isTrue(myObject.x == 100);
	}
	
	public function testMultiVariableSameValueTween() {
		var myObject:{ scale:{x:Float, y:Float}, position:{x:Float, y:Float}} = { scale: {x: 0, y: 0}, position: {x: 0, y: 0} };
		var tween:Tween = Tween.tween(myObject => [[scale, position] => [[x, y] => 100]], 1, 0, linear);
		
		tween.stepTo(0, null, true);
		Assert.isTrue(myObject.position.x == 0 && myObject.scale.y == 0);

		tween.stepTo(0.5, null, true);
		Assert.isTrue(myObject.position.x == 50 && myObject.scale.y == 50);
	}
	
	public function testTweenRanges() {
		var myObject:{ x:Float } = { x: 0 };
		var tween:Tween = Tween.tween([myObject.x => 10...20], 1, 0, linear);
		
		tween.stepTo(0.0, null, true);
		Assert.isTrue(myObject.x == 10);
		
		tween.stepTo(0.5, null, true);
		Assert.isTrue(myObject.x == 15);
		
		tween.stepTo(1.0, null, true);
		Assert.isTrue(myObject.x == 20);
	}
	
	public function testTweenLocal() {
		var x:Float = 50;
		var tween:Tween = Tween.tween([x => 100], 1, 0, linear);
		
		Assert.isTrue(x == 50);
		
		tween.stepTo(0.0, null, true);
		Assert.isTrue(x == 50);
		
		tween.stepTo(0.5, null, true);
		Assert.isTrue(x == 75);
		
		tween.stepTo(1.0, null, true);
		Assert.isTrue(x == 100);
	}
	
	public function testMultipleObjectTweens() {
		var myObject:{ x:Float } = { x: 0 };
		var anotherObject:{ x:Float, y:Float, z:Float } = { x: 0, y: 0, z: 0 };
		
		var tween:Tween = Tween.tween([myObject.x => 100, anotherObject.x => 200], 1, 0, linear);
		
		tween.stepTo(0.0, null, true);
		Assert.isTrue(myObject.x == 0 && anotherObject.x == 0);
		
		tween.stepTo(0.5, null, true);
		Assert.isTrue(myObject.x == 50 && anotherObject.x == 100);
		
		tween.stepTo(1.0, null, true);
		Assert.isTrue(myObject.x == 100 && anotherObject.x == 200);
	}
	
	public function testCompoundMultipleFields() {
		var myObject:{ x:Float, y:Float } = { x: 0, y: 0 };
		
		var tween:Tween = Tween.tween([myObject => [x => 100, y => 100]], 1, 0, linear);
		
		tween.stepTo(0.0, null, true);
		Assert.isTrue(myObject.x == 0 && myObject.y == 0);
		
		tween.stepTo(0.5, null, true);
		Assert.isTrue(myObject.x == 50 && myObject.y == 50);
		
		tween.stepTo(1.0, null, true);
		Assert.isTrue(myObject.x == 100 && myObject.y == 100);
	}
	
	public function testCompoundMultipleObjects() {
		var myObject:{ x:Float, y:Float } = { x: 0, y: 0 };
		var anotherObject:{ x:Float, y:Float, z:Float } = { x: 0, y : 0, z : 0 };
		
		var tween:Tween = Tween.tween([[myObject, anotherObject] => [ x => 100, y => 200]], 1, 0, linear);
		
		Assert.isTrue(myObject.x == 0);
		
		tween.stepTo(0.5, null, true);
		
		Assert.isTrue(myObject.x == 50);
		Assert.isTrue(anotherObject.x == 50);
		
	}
	
	public function testImplicitStartOrEnd() {
		var myObject:{ x:Float } = { x: 0 };
		
		var tween:Tween = Tween.tween([myObject.x => 10..._], 1, 0, linear);
		
		tween.stepTo(0.5, null, true);
		Assert.isTrue(myObject.x == 5);
	}
	
	public function testFunctionTween() {
		var x:Float = 0;
		var myFunction = function (value:Float, add:Float):Void {
			x = value + add;
		};
		
		var tween:Tween = Tween.tween([myFunction(10...20, 10)], 1, 0, linear);
		
		Assert.isTrue(x == 0);
		tween.stepTo(0.5, null, true);
		Assert.isTrue(x == 25);
	}
	
	public function testPotentialKeywordConflicts() {
		var time:Float = 0;
		var tween:Float = 0;
		var startValue:Float = 0;
		var endValue:Float = 0;
		
		var t1 = Tween.tween([time => 100], 1, 0, linear);
		var t2 = Tween.tween([tween => 100], 1, 0, linear);
		var t3 = Tween.tween([startValue => 100], 1, 0, linear);
		var t4 = Tween.tween([endValue => 100], 1, 0, linear);
		
		for (t in [t1, t2, t3, t4]) t.stepTo(0.5, null, true);
		
		Assert.isTrue(time == 50 && tween == 50 && startValue == 50 && endValue == 50);
	}
	
	public function testTweenAbstract() {
		var x:HelperAbstractFloat = new HelperAbstractFloat(50.0);
		
		var tween:Tween = Tween.tween([x => 100], 1, 0, linear);
		
		Assert.isTrue(x == 50);
		
		tween.stepTo(0.0, null, true);
		Assert.isTrue(x == 50);
		
		tween.stepTo(0.5, null, true);
		Assert.isTrue(x == 75);
		
		tween.stepTo(1.0, null, true);
		Assert.isTrue(x == 100);
	}
	
	public function testTweenCallbacks() {
		var x:Float = 50;
		
		var cbt1:CallbackTween = Tween.tween([x => 0...100], 1, 0, null, {pack: ["tests"], name: "CallbackTween"});
		
		var str:String = "";
		
		cbt1.leftHit = function(rev) {str += "1L" + (rev ? "r" : ""); };
		cbt1.rightHit = function(rev) {str += "1R" + (rev ? "r" : ""); };
		
		cbt1.stepTo(0, null, true);
		cbt1.stepTo(1, null, true);
		Assert.isTrue(x == 100);
		cbt1.stepTo(0, null, true);
		var expectedStr = "1L1R1Lr";
		
		Assert.isTrue(x == 0);
		Assert.isTrue(str == expectedStr, (str == expectedStr ? "" : ("Expected: " + expectedStr + ", Actual: " + str)));
	}
}