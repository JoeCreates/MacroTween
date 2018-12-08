package tests;

import tests.HelperObjects;
import macrotween.Timeline;
import macrotween.Tween;
import macrotween.TimelineItem;
import utest.Assert;
import utest.ITest;

/**
 * Tests the Timeline class.
 */
class TestTimeline implements ITest {
	private var a:{a:Float, b:Float};
	private var b:Float;
	
	public function new() {}
	
	public function setup():Void {
		a = {a: 10, b: 20};
		b = 5;
	}
	
	public function testSimpleTimeline():Void {
		var tl = new Timeline();
		
		tl.tween(0, 1, b => 10);
		tl.stepTo(0.5, null, true);
		Assert.isTrue(b == 7.5);
	}
	
	public function testOvershootBounds():Void {
		var tl = new Timeline();
		
		tl.tween(0, 1, b => 10);
		tl.stepTo(0, null, true);
		tl.stepTo(2, null, true);
		Assert.isTrue(b == 10);
	}
	
	public function testCallbackOrders():Void {
		var tl = new Timeline(0, 1, 1);
		
		var cbt1:CallbackTween = Tween.tween(0.1, 0.6, a.a => 0...100, null, {pack: ["tests"], name: "CallbackTween"});
		var cbt2:CallbackTween = Tween.tween(0.2, 0.7, a.b => 100...200, null, {pack: ["tests"], name: "CallbackTween"});
		
		var str:String = "";
		
		cbt1.leftHit = function(rev) {str += "1L" + (rev ? "r" : ""); };
		cbt1.rightHit = function(rev) {str += "1R" + (rev ? "r" : ""); };
		cbt2.leftHit = function(rev) {str += "2L" + (rev ? "r" : ""); };
		cbt2.rightHit = function(rev) {str += "2R" + (rev ? "r" : ""); };
		
		tl.add(cbt1).add(cbt2);
		Assert.isTrue(tl.length == 2);
		tl.stepTo(0, null, true);
		tl.stepTo(1, null, true);
		Assert.isTrue(a.b == 200);
		tl.stepTo(0.05, null, true);
		var expectedStr = "1L2L1R2R2Rr1Rr2Lr1Lr";
		
		Assert.isTrue(a.b == 100);
		Assert.isTrue(str == expectedStr, (str == expectedStr ? "" : ("Expected: " + expectedStr + ", Actual: " + str)));
	}
	
	public function testCallbackOrdersAndBounds():Void {
		var tl = new Timeline(0, 1, 1);
		
		var cbt1:CallbackTween = Tween.tween(0.0, 0.6, a.a => 0...100, null, {pack: ["tests"], name: "CallbackTween"});
		var cbt2:CallbackTween = Tween.tween(0.2, 0.8, a.b => 100...200, null, {pack: ["tests"], name: "CallbackTween"});
		
		var str:String = "";
		
		cbt1.leftHit = function(rev) {str += "1L" + (rev ? "r" : ""); };
		cbt1.rightHit = function(rev) {str += "1R" + (rev ? "r" : ""); };
		cbt2.leftHit = function(rev) {str += "2L" + (rev ? "r" : ""); };
		cbt2.rightHit = function(rev) {str += "2R" + (rev ? "r" : ""); };
		
		tl.add(cbt1).add(cbt2);
		Assert.isTrue(tl.length == 2);
		tl.stepTo(0, null, true);
		tl.stepTo(1, null, true);
		Assert.isTrue(a.b == 200);
		tl.stepTo(0, null, true);
		var expectedStr = "1L2L1R2R1Rr2Lr1Lr";
		
		Assert.isTrue(a.b == 100);
		Assert.isTrue(str == expectedStr, (str == expectedStr ? "" : ("Expected: " + expectedStr + ", Actual: " + str)));
	}
	
	public function testChaining():Void {
		var tl:Timeline = new Timeline();
		tl.tween(0, 1, b => 10).tween(0, 1, a.a => 20).stepTo(1, null, true);
		Assert.isTrue(a.a == 20 && b == 10);
	}
	
	public function testSimpleRelativeDuration():Void {
		var tl:Timeline = new Timeline(0, 1, 2);
		tl.tween(0, 1, b => 10).stepTo(0.5, null, true);
		
		// TODO is this broken?
		Assert.isTrue(b == 7.5);
	}
	
	public function testNestedTimelines():Void {
		// TODO
		Assert.isTrue(true);
	}
	
	public function testMultipleTimelines():Void {
		var tl:Timeline = new Timeline(0, 1);
		var tl2:Timeline = new Timeline(0, 1);
		
		var tween = Tween.tween(0, 1, b => 0);
		tl.add(tween);
		tl2.add(tween);
		
		// Tween is new, so can be stepped to 0
		tl.stepTo(1, null, true);
		Assert.isTrue(b == 0);
		
		// Tween was already stepped to 1 on the other timeline
		// So this will not change anything
		b = 500;
		tl2.stepTo(1, null, true);
		Assert.isTrue(b == 500);
		
		// TODO moving tweens between timelines without breaking stuff?
	}
	
	public function testTweensOrdering():Void {
		var tl:Timeline = new Timeline(0, 10, 10);
		
		tl.tween(0, 1, b => 0...100);
		tl.tween(2, 1, b => 2000...3000);
		tl.tween(4, 1, b => 50000...60000);
		
		tl.stepTo(0.5, null, true);
		Assert.isTrue(b == 50);
		tl.stepTo(2.5, null, true);
		Assert.isTrue(b == 2500);
		tl.stepTo(4.5, null, true);
		Assert.isTrue(b == 55000);
	}
}