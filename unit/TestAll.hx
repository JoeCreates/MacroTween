package;

#if lime
import lime.app.Application;
#end

import tests.TestEase;
import tests.TestReadmeExamples;
import tests.TestTimeline;
import tests.TestTimelineItem;
import tests.TestTween;
import utest.Runner;
import utest.ui.Report;

/**
 * Runs all of the unit tests.
 */
class TestAll #if lime extends Application #end {
	#if lime
	public function new() {
		super();
		main();
	}
	#end
	
	public static function addTests(runner:Runner) {
		runner.addCase(new TestEase());
		runner.addCase(new TestReadmeExamples());
		runner.addCase(new TestTimeline());
		runner.addCase(new TestTimelineItem());
		runner.addCase(new TestTween());
	}

	public static function main() {
		#if php untyped __call__('ini_set', 'xdebug.max_nesting_level', 10000); #end
		var runner = new Runner();
		addTests(runner);
		Report.create(runner, AlwaysShowSuccessResults);
		runner.run();
	}
}