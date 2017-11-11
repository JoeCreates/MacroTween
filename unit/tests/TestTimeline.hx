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
	}
	
	public function testChaining():Void {
		var tl = new Timeline();
		tl.tween(0, 1, b => 10,)
	}
}