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
		tl = new Timeline();
		a = {a:5.0, b:5.0};
		b = 5.0;
	}
	
	public function testTimelineNotEntered():Void {
		tl.add(Tween.tween(1, 1, [a.a => _...10, a.b => 10..._], linear));
		
		tl.items.first().removeOnCompletion = false;
		tl.stepTo(0.5);
		
		Assert.isTrue(a.a == 5);
		Assert.isTrue(a.b == 5);
		Assert.isTrue(!tl.items.first().isTimeInBounds(5));
	}
	
	public function testTimelineEntered():Void {
		tl.add(Tween.tween(1, 1, [a.a => _...10, a.b => 10..._], linear));
		tl.items.first().removeOnCompletion = false;
		tl.stepTo(1.1);
		Assert.isTrue(tl.items.first().isTimeInBounds(1.1));
		Assert.isTrue(a.a == 5.5);
		Assert.isTrue(a.b == 9);
	}
	
	public function testReverseOutOfTimeline():Void {
		// TODO
		
		//tl.add(Tween.tween(1, 1, [a.a => _...10, a.b => 10..._], linear));
		//tl.items.first().removeOnCompletion = false;
		//tl.stepTo(1.1);
		
		//Assert.isTrue(tl.items.first().isTimeInBounds(1.1));
		//Assert.isTrue(a.a == 5.5);
		//Assert.isTrue(a.b == 9);
		
		//tl.stepTo(0.1);//TODO something going wrong, here
		//Assert.isTrue(a.a == 5);
		
		//TODO technically above should fail
		//if we're moving toward _ we shouldn't be changing
		//tl.stepTo(3);
		//Assert.isTrue(a.a == 10);
	}
}