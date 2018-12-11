package tests;

import macrotween.Ease;
import utest.Assert;
import utest.ITest;

/**
 * Tests the Easing class.
 */
class TestEase implements ITest {
	public function new() {
		
	}
	
	public function testLinear() {
		Assert.isTrue(Ease.linear(0.5) == 0.5 && Ease.linear(-0.5) == -0.5);
	}
	
	public function testQuad() {
		Assert.isTrue(Ease.quadIn(0.5) == 0.25);
	}
}