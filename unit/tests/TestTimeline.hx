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
	var b:Float;
	
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
		tl.stepTo(2);
		Assert.isTrue(b == 10);
	}
	
	public function testCallbackOrders():Void {
		var tl = new Timeline();
		
		tl.tween(0, 1, a => 10);
		tl.stepTo(2);
		Assert.isTrue(b == 10);
	}
	
	public function testChaining():Void {
		var tl = new Timeline();
		tl.tween(0, 1, b => 10).tween(0, 1, a.a => 20).stepTo(1);
		Assert.isTrue(a.a == 20 && b == 10);
	}
}

class CallbackTween extends Tween {
	public function new(startTime:Float, duration:Float, tweeners:Array<Tweener>, ?ease:Float->Float) {
		super(starTime, duration, tweeners, ease);
	}
	
	//override 
}