package;

import tests.TestTimeline;
import utest.Runner;
import utest.ui.Report;

/**
 * Runs all of the unit tests.
 */
class TestAll {
	public static function addTests(runner:Runner) {
		runner.addCase(new TestTimeline());
	}

	public static function main() {
		#if php untyped __call__('ini_set', 'xdebug.max_nesting_level', 10000); #end
		var runner = new Runner();
		addTests(runner);
		Report.create(runner);
		runner.run();
	}
}