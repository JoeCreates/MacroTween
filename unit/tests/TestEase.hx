package tests;

import macrotween.Ease;
import utest.Assert;

/**
 * Tests the Easing class.
 */
class TestEase {
	public function new() {
		
	}
	
	public function testLinear() {
		Assert.isTrue(Ease.none(0.5) == 0.5 && Ease.none(-0.5) == -0.5);
	}
	
	public function testQuad() {
		Assert.isTrue(Ease.quadIn(0.5) == 0.25);
	}
}