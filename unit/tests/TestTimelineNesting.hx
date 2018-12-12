package tests;

import tests.HelperObjects;
import macrotween.Timeline;
import macrotween.Tween;
import macrotween.TimelineItem;
import utest.Assert;
import utest.ITest;

/**
 * Tests nesting of timelines.
 */
class TestTimelineNesting implements ITest {
	private var a:{a:Float, b:Float};
	private var five:Float;
	
	public function new() {}
	
	public function setup():Void {
		a = {a: 10, b: 20};
		five = 5;
	}
	
	public function testNestedTimelines():Void {
		var tl1 = new Timeline(1, 0);
		var tl2 = new Timeline(0.5, 0.5);
		
		tl1.add(tl2);
		
		var x:Float = 0;
		tl2.tween(x => 0...10);
		
		tl1.stepTo(0.75);
		
		//TODO
		Assert.isTrue(true);
	}
}