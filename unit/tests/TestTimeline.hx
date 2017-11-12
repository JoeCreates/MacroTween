package tests;

import macrotween.Timeline;
import macrotween.Tween;
import macrotween.TimelineItem;
import utest.Assert;

/**
 * Tests the Timeline class.
 */
class TestTimeline {
	var tl:Timeline;
	var a:{a:Float, b:Float};
	public var b:Float;
	
	function linear(x:Float) { return x; }
	
	public function new() {}
	
	public function setup():Void {
		a = {a: 10, b: 20};
		b = 5;
	}
	
	public function testSimpleTimeline():Void {
		var tl = new Timeline();
		
		tl.tween(0, 1, b => 10);
		tl.stepTo(0.5);
		Assert.isTrue(b == 7.5);
	}
	
	public function testOvershootBounds():Void {
		var tl = new Timeline();
		
		tl.tween(0, 1, b => 10);
		tl.stepTo(0);
		tl.stepTo(2);
		Assert.isTrue(b == 10);
	}
	
	public function testCallbackOrders():Void {
		var tl = new Timeline();
		
		var cbt1:CallbackTween = Tween.tween(0.1, 0.6, a.a => 0...100, null, {pack: ["tests"], name: "CallbackTween"});
		var cbt2:CallbackTween = Tween.tween(0.2, 0.7, a.b => 100...200, null, {pack: ["tests"], name: "CallbackTween"});
		
		var str:String = "";
		
		cbt1.leftHit = function(rev) {str += "1L" + (rev ? "r" : ""); };
		cbt1.rightHit = function(rev) {str += "1R" + (rev ? "r" : ""); };
		cbt2.leftHit = function(rev) {str += "2L" + (rev ? "r" : ""); };
		cbt2.rightHit = function(rev) {str += "2R" + (rev ? "r" : ""); };
		
		tl.add(cbt1).add(cbt2);
		Assert.isTrue(tl.length == 2);
		tl.stepTo(0);
		tl.stepTo(1);
		Assert.isTrue(a.b == 200);
		tl.stepTo(0.05);
		var expectedStr = "1L2L1R2R2Rr1Rr2Lr1Lr";
		
		Assert.isTrue(a.b == 100);
		Assert.isTrue(str == expectedStr, (str == expectedStr ? "" : ("Expected: " + expectedStr + ", Actual: " + str)));
	}
	
	public function testChaining():Void {
		var tl:Timeline = new Timeline();
		tl.tween(0, 1, b => 10).tween(0, 1, a.a => 20).stepTo(1);
		Assert.isTrue(a.a == 20 && b == 10);
	}
	
		public function testSimpleRelativeDuration():Void {
		var tl:Timeline = new Timeline(0, 1, 2);
		tl.tween(0, 1, b => 10).stepTo(1);
		
		tl.stepTo(1);
	}
	
	public function testMultipleTimelines():Void {
		var tl:Timeline = new Timeline(0, 1);
		var tl2:Timeline = new Timeline(0, 1);
		
		var tween = Tween.tween(0, 1, b => 0);
		tl.add(tween);
		tl2.add(tween);
		
		// Tween is new, so can be stepped to 0
		tl.stepTo(1);
		Assert.isTrue(b == 0);
		
		// Tween was already stepped to 1 on the other timeline
		// So this will not change anything
		b = 500;
		tl2.stepTo(1);
		Assert.isTrue(b == 500);
	}
	
	public function testTweensOrdering():Void {
		var tl:Timeline = new Timeline(0, 10, 10);
		
		tl.tween(0, 1, b => 0...100);
		tl.tween(2, 1, b => 2000...3000);
		tl.tween(4, 1, b => 50000...60000);
		
		tl.stepTo(0.5);
		Assert.isTrue(b == 50);
		tl.stepTo(2.5);
		Assert.isTrue(b == 2500);
		tl.stepTo(4.5);
		Assert.isTrue(b == 55000);
	}
}

class CallbackTween extends Tween {
	public var leftHit:Bool->Void;
	public var rightHit:Bool->Void;
	
	public function new(startTime:Float, duration:Float, tweeners:Array<Tweener>, ?ease:Float->Float) {
		super(startTime, duration, tweeners, ease);
	}
	
	override public function onLeftHit(rev:Bool):Void {
		super.onLeftHit(rev);
		if (leftHit != null) leftHit(rev);
	}
	override public function onRightHit(rev:Bool):Void {
		super.onRightHit(rev);
		if (rightHit != null) rightHit(rev);
	}
}