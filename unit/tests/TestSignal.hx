package tests;

import macrotween.Signal;
import utest.Assert;

/**
 * Tests the Signal class.
 */
class TestSignal {
	public function new() {
		
	}
	
	public function testDispatchSignal() {
		var signal:Signal = new Signal();
		var x = 0;
		
		signal.add(function() {
			x++;
		});
		signal.dispatch();
		
		Assert.isTrue(x == 1);
	}
}