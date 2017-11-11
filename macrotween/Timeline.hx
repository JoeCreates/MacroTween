package macrotween;

import macrotween.TimelineItem.Boundary;

/**
 * The Timeline class helps organize multiple timeline items, such as Tweens,
 * allowing them to be managed and manipulated as a group.
 * Timelines are themselves timeline items, and so can be nested within each other.
 */
class Timeline extends TimelineItem {
	public var items:List<TimelineItem>;

	private var dirtyDuration:Bool;

	public function new() {
		super(null, 0, 0);
		items = new List<TimelineItem>();
		dirtyDuration = true;
	}

	// Step to a relative time on the timeline
	public function step(dt:Float):Void {
		stepTo(currentTime + dt, currentTime);
	}

	// Steps to an absolute time on the timeline
	// Boundary crossing callbacks of items are called in chronological order
	// The order that individual items are updated is undefined
	override public function stepTo(nextTime:Float, ?unusedCurrentTime:Float):Void {
		nextTime = bound(nextTime, 0, duration);

		if (currentTime == nextTime) {
			return;
		}
		
		//TODO hack... figure out better solution with Sam
		var currentTime = currentTime;
		this.currentTime = nextTime;

		// TODO remove items that are complete/ready for removal
		//removeMarked();

		// TODO this won't trigger the boundary callbacks, because intersection checks were moved from the superclass to the timeline
		super.stepTo(nextTime, currentTime);

		var intersections:Array<Boundary> = [];

		var gatherIntersections = function(item:TimelineItem) {
			var shouldStep:Bool = rangesIntersect(currentTime, nextTime, item.startTime, item.endTime);

			if (!shouldStep) {
				return;
			}

			var intersectLeft:Bool = pointRangeIntersection(item.startTime, currentTime, nextTime);
			var intersectRight:Bool = pointRangeIntersection(item.endTime, currentTime, nextTime);
			if (intersectLeft) {
				intersections.push(item.left);
			}
			if (intersectRight) {
				intersections.push(item.right);
			}
		}

		gatherIntersections(this);
		for (item in items) {
			gatherIntersections(item);
		}

		var reversing:Bool = currentTime > nextTime;

		// TODO sort by parent item start/end time
		//intersections.sort(function(a:Boundary, b:Boundary)) {

		//}

		for (boundary in intersections) {
			boundary.onCrossed(reversing, reversing ? ++boundary.rightToLeftCount : ++boundary.leftToRightCount);
		}
		
		for (item in items) item.stepTo(nextTime, currentTime);

		// TODO remove items that are complete/ready for removal
		//removeMarked();
	}

	private inline function pointRangeIntersection(p:Float, x1:Float, x2:Float):Bool {
		return (p >= Math.min(x1, x2) && p <= Math.max(x1, x2));
	}

	private inline function rangesIntersect(x1:Float, x2:Float, y1:Float, y2:Float):Bool {
		return ((Math.min(x1, x2) <= Math.max(y1, y2)) && (Math.min(y1, y2) <= Math.max(x1, x2)));
	}

	public function add(item:TimelineItem):Void {
		item.parent = this;
		items.add(item);
		dirtyDuration = true;
		return;
	}

	public function remove(item:TimelineItem):Void {
		items.remove(item);
	}

	public function clear():Void {
		items = new List<TimelineItem>();
	}

	override public function reset():Void {
		super.reset();

		for (item in items) {
			item.reset();
		}

		onReset();
	}

	public function itemTimeChanged(item:TimelineItem):Void {
		dirtyDuration = true;
	}

	override private function get_duration():Float {
		if (dirtyDuration) {
			var duration:Float = 0;
			for (item in items) {
				duration = Math.max(duration, item.endTime);
			}
			this.duration = duration;
			dirtyDuration = false;
		}
		return this.duration;
	}
	
	private static inline function bound(value:Float, ?min:Float, ?max:Float):Float {
		var lowerBound:Float = (min != null && value < min) ? min : value;
		return (max != null && lowerBound > max) ? max : lowerBound;
	}
}