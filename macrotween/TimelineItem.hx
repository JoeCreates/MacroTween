package macrotween;

/**
 * The TimelineItem class is the base class for any object that can go on a timeline.
 */
class TimelineItem {
	/** Setting this will skip boundary triggering */
	public var currentTime(default, set):Null<Float>;
	
	@:isVar public var startTime(get, set):Float;
	@:isVar public var duration(get, set):Float;
	public var endTime(get, never):Float;

	private var _isInBounds:Bool;
	private var _isInBoundsDirty:Bool;
	
	public function new(startTime:Float, duration:Float) {
		_isInBounds = false;
		_isInBoundsDirty = true;
		
		this.currentTime = null;
		this.startTime = startTime;
		this.duration = duration;
	}
	
	public function onReset():Void {
		
	}
	
	public function onRemoved(from:Timeline):Void {
		
	}
	
	public function onLeftHit(reversed:Bool):Void {
		
	}
	
	public function onRightHit(reversed:Bool):Void {
		
	}
	
	// If we initially stepTo within the bounds, we cannot infer
	// what direction we came from, so call this
	public function onStartInBounds():Void {
		
	}

	public function reset():Void {

	}
	
	/**
	 * Step to a relative time on the timeline item
	 * @param	dt Time delta
	 */
	public function step(dt:Float):Void {
		stepTo(currentTime + dt);
	}
	
	/**
	 * Step to an absolute time on the timeline item
	 * @param	nextTime Absolute time
	 */
	public function stepTo(time:Float, ?lastTime:Float):Void {
		if (lastTime == null) lastTime = currentTime;
		if (lastTime == time) return;
		
		var leftCrossed:Bool = lastTime != null &&
			((lastTime < startTime && time > startTime) || (lastTime > startTime && time < startTime));
		var rightCrossed:Bool = lastTime != null &&
			((lastTime < endTime && time > endTime) || (lastTime > endTime && time < endTime));
		var rev:Bool = lastTime != null && lastTime > time;
		
		if (leftCrossed || rightCrossed) {
			var cTime:Float = lastTime;
			if (rev) {
				if (rightCrossed) {
					stepTo(endTime, cTime);
					cTime = endTime;
				}
				if (leftCrossed) {
					stepTo(startTime, cTime);
					cTime = startTime;
				}
				if (time != startTime) stepTo(time, cTime);
			} else {
				if (leftCrossed) {
					stepTo(startTime, cTime);
					cTime = startTime;
				}
				if (rightCrossed) {
					stepTo(endTime, cTime);
					cTime = endTime;
				}
				if (time != endTime) stepTo(time, cTime);
			}
		} else {
			currentTime = time;
			updateBounds(lastTime);
			
			onUpdate(time, lastTime);
		}
	}
	
	public function onUpdate(time:Float, ?lastTime:Float):Void {

	}
	
	public static inline function progressFraction(time:Float, start:Float, end:Float):Float {
		if (start == end) {
			return 0.5;
		}
		return Math.min(1, Math.max(0, (time - start) / (end - start)));
	}
	
	private function isTimeInBounds(time:Float):Bool {
		return time >= startTime && time <= endTime;
	}
	
	public function isCurrentTimeInBounds():Bool {
		if (currentTime == null) {
			return false;
		}
		if (!_isInBoundsDirty) {
			return _isInBounds;
		}
		
		_isInBounds = isTimeInBounds(currentTime);
		_isInBoundsDirty = false;
		
		return _isInBounds;
	}
	
	private function updateBounds(lastTime:Null<Float>):Void {
		// First update - if we are in bounds, but don't know what direction we came from
		var currentTimeInBounds = isCurrentTimeInBounds();
		if (lastTime == null && !currentTimeInBounds) {
			return;
		} else if (lastTime == null && currentTimeInBounds && currentTime != startTime && currentTime != endTime) {
			onStartInBounds();
		} else { // Not the first update, and we can work out what direction we came from
			
			if (lastTime == null) {
				if (currentTime == startTime) {
					onLeftHit(false);
				}
				if (currentTime == endTime) {
					onRightHit(true);
				}
				return;
			}
			
			if (currentTime >= startTime && lastTime < startTime) {
				onLeftHit(false);
			}
			
			if (currentTime >= endTime && lastTime < endTime) {
				onRightHit(false);
			}
			
			if (currentTime <= startTime && lastTime > startTime) {
				onLeftHit(true);
			}
			
			if (currentTime <= endTime && lastTime > endTime) {
				onRightHit(true);
			}
		}
	}
	
	private function set_currentTime(time:Null<Float>):Null<Float> {
		_isInBoundsDirty = true;
		return this.currentTime = time;
	}

	private function get_duration():Float {
		return this.duration;
	}

	private function set_duration(duration:Float):Float {
		if (this.duration == duration) {
			return this.duration;
		}
		
		_isInBoundsDirty = true;
		
		this.duration = Math.max(0, duration);
		return duration;
	}
	
	private function get_startTime():Float {
		return this.startTime;
	}

	private function set_startTime(startTime:Float):Float {
		if (this.startTime == startTime) {
			return this.startTime;
		}
		
		_isInBoundsDirty = true;
		
		this.startTime = startTime;
		return startTime;
	}

	private function get_endTime():Float {
		return startTime + duration;
	}
}