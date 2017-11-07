package macrotween;

import macrotween.Signal;

// TODO events (boundaries) should be queued up to happen in correct order when many are passed

class Boundary {
	public var parent(default, null):TimelineItem;
	public var leftToRightCount:Int = 0;
	public var rightToLeftCount:Int = 0;
	
	public var onCrossed:TypedSignal<Bool->Int->Void>;

	public inline function new(parent:TimelineItem) {
		this.parent = parent;
		this.onCrossed = new TypedSignal<Bool->Int->Void>();
	}

	public function add(f:Bool->Int->Void):Void {
		onCrossed.add(f);
	}

	public function dispatch(reverse:Bool, count:Int):Void {
		onCrossed.dispatch(reverse, count);
	}
}

// Base class for anything that can go on a timeline
class TimelineItem {
	public var parent(default, null):Timeline;
	
	/** Setting this will skip boundary triggering */
	public var currentTime:Float;

	public var startTime(default, set):Float;
	@:isVar public var duration(get, set):Float;
	public var endTime(get, null):Float;

	public var exitLeftLimit(default, null):Int;
	public var exitRightLimit(default, null):Int;
	public var isComplete(get, null):Bool;

	public var removeOnCompletion(default, default):Bool;
	public var markedForRemoval(default, default):Bool;

	public var left:Boundary;
	public var right:Boundary;
	public var onRemoved = new TypedSignal<Timeline->Void>();

	public function new(?parent:Timeline, startTime:Float, duration:Float) {
		this.parent = parent;
		this.currentTime = 0;
		this.startTime = startTime;
		this.duration = duration;

		left = new Boundary(this);
		right = new Boundary(this);

		exitLeftLimit = 1;
		exitRightLimit = 1;

		removeOnCompletion = true;
		markedForRemoval = false;

		#if debug
		onRemoved.add(function(parent:Timeline) {
			trace("Removed timeline item from timeline");
		});
		#end
	}

	public function reset():Void {
		// TODO reset boundary counts, remove signals?
		markedForRemoval = false;
	}

	public function onUpdate(time:Float):Void {

	}

	public function stepTo(nextTime:Float, ?currentTime:Float):Void {
		if (markedForRemoval) {
			return;
		}
		
		if (isComplete) {
			if (removeOnCompletion) {
				markedForRemoval = true;
			}
			return;
		}

		onUpdate(nextTime);
	}
	
	public function isTimeInBounds(time:Float):Bool {
		return (currentTime >= startTime && currentTime <= endTime);
	}

	private function get_duration():Float {
		return this.duration;
	}

	private function set_duration(duration:Float):Float {
		this.duration = Math.max(0, duration);
		if (parent != null) {
			parent.itemTimeChanged(this);
		}
		return duration;
	}

	private function set_startTime(startTime:Float):Float {
		this.startTime = startTime;
		if (parent != null) {
			parent.itemTimeChanged(this);
		}
		return startTime;
	}

	private function get_endTime():Float {
		return startTime + duration;
	}

	private function get_isComplete():Bool {
		return (left.rightToLeftCount >= exitLeftLimit && right.leftToRightCount >= exitRightLimit);
	}
}