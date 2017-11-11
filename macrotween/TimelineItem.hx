package macrotween;

// TODO events (boundaries) should be queued up to happen in correct order when many are passed

class Boundary {
	public var parent(default, null):TimelineItem;
	public var leftToRightCount:Int = 0;
	public var rightToLeftCount:Int = 0;
	
	public function onCrossed(direction:Bool, times:Int):Void {

	}

	public inline function new(parent:TimelineItem) {
		this.parent = parent;
	}
}

/**
 * The TimelineItem class is the base class for any object that can go on a timeline.
 */
class TimelineItem {
	public var parent(default, null):Timeline;
	
	/** Setting this will skip boundary triggering */
	public var currentTime:Null<Float>;

	@:isVar public var startTime(get, set):Float;
	@:isVar public var duration(get, set):Float;
	public var endTime(get, null):Float;

	public var isComplete(get, null):Bool;

	public var left:Boundary;
	public var right:Boundary;
	
	public function onReset():Void {
		
	}
	
	public function onRemoved(from:Timeline):Void {
		
	}

	public function new(?parent:Timeline, startTime:Float, duration:Float) {
		this.parent = parent;
		this.currentTime = null;
		this.startTime = startTime;
		this.duration = duration;

		left = new Boundary(this);
		right = new Boundary(this);

		#if debug
		onRemoved.add(function(parent:Timeline) {
			trace("Removed timeline item from timeline");
		});
		#end
	}

	public function reset():Void {

	}

	public function onUpdate(time:Float):Void {

	}

	public function stepTo(nextTime:Float):Void {
		if (isComplete) {
			return;
		}
		
		if (isTimeInBounds(currentTime)) {
			if (currentTime == null) {
				currentTime = nextTime;
				
				setImplicitStartTimes();
				setImplicitEndTimes();
			} else {
				
			}
		}
		
		//
		//if (currentTime == startTimecurrentTime < startTime && nextTime >= startTime) {
			//
		//}
		//else if (currentTime < endTime && nextTime >= endTime) {
			//
		//}
		
		onUpdate(nextTime);
	}
	
	private function setImplicitStartTimes():Void {
		for (tweener in tweeners) {
			if (tweener.implicitStart) {
				
			}
			
			if (tweener.implicitEnd) {
				
			}
		}
	}
	
	private function setImplicitEndTimes():Void {
		for (tweener in tweeners) {
			if (tweener.implicitStart) {
				
			}
			
			if (tweener.implicitEnd) {
				
			}
		}
	}
	
	public function isTimeInBounds(?time:Float):Bool {
		var t:Float = time == null ? currentTime : time;
		return time >= startTime && time <= endTime;
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
	
	private function get_startTime():Float {
		return this.startTime;
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
		return false;
	}
}