package;

import tests.TestEase;
import tests.TestSignal;
import tests.TestTimeline;
import tests.TestTween;
import utest.Runner;
import utest.ui.Report;

/**
 * Runs all of the unit tests.
 */
class TestAll {
	public static function addTests(runner:Runner) {
		runner.addCase(new TestEase());
		runner.addCase(new TestSignal());
		runner.addCase(new TestTimeline());
		runner.addCase(new TestTween());
	}

	public static function main() {
		#if php untyped __call__('ini_set', 'xdebug.max_nesting_level', 10000); #end
		var runner = new Runner();
		addTests(runner);
		Report.create(runner);
		runner.run();
	}
}