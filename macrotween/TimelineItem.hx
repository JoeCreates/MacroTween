package macrotween;

class BoundSignal {
	public var listeners:Array<Bool->Void>;
	
	public function new() {
		listeners = new Array<Bool->Void>();
	}
	
	public function add(listener:Bool->Void) {
		listeners.push(listener);
	}
	
	public function remove(listener:Bool->Void) {
		listeners.remove(listener);
	}
	
	public function dispatch(reversed:Bool):Void {
		for (listener in listeners) {
			listener(reversed);
		}
	}
}

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
	private var _wasInBounds:Bool;
	
	public var ease:Float->Float;
	
	public var onEndSignal(get, never):BoundSignal;
	public var onStartSignal(get, never):BoundSignal;
	
	private var _onEndSignal:BoundSignal;
	private var _onStartSignal:BoundSignal;

	private function get_onEndSignal():BoundSignal {if (_onEndSignal == null) {_onEndSignal = new BoundSignal();} return _onEndSignal;}
	private function get_onStartSignal():BoundSignal {if (_onStartSignal == null) {_onStartSignal = new BoundSignal();} return _onStartSignal;}
	
	public function new(?duration:Float = 1, ?startTime:Float = 0, ?ease:Float->Float) {
		_isInBounds = false;
		_isInBoundsDirty = true;
		_wasInBounds = false;
		
		this.currentTime = null;
		this.startTime = startTime;
		this.duration = duration;
		this.ease = ease;
	}
	
	public function onReset():Void {
		
	}
	
	public function onRemoved(from:Timeline):Void {
		
	}
	
	public function onLeftHit(reversed:Bool):Void {
		if (_onStartSignal != null) _onStartSignal.dispatch(reversed);
	}
	
	public function onRightHit(reversed:Bool):Void {
		if (_onEndSignal != null) _onEndSignal.dispatch(reversed);
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
	public inline function step(dt:Float, substep:Bool = false):Void {
		if (currentTime == null) {
			currentTime = 0;
		}
		stepTo(currentTime + dt, substep);
	}
	
	/**
	 * Step to an absolute time on the timeline item
	 */
	// TODO make lastTime a member of the timelineitem!
	public function stepTo(time:Float, ?lastTime:Float, substep:Bool = false):Void {
		_wasInBounds = isCurrentTimeInBounds();
		
		if (lastTime == null) lastTime = currentTime;
		if (lastTime == time) return;
		
		if (!substep) {
			currentTime = time;
			onUpdate(time, lastTime, substep);
			updateBounds(lastTime);
		} else {
		
			var hasLastTime:Bool = lastTime != null;
			var leftCrossed:Bool = hasLastTime &&
				((lastTime < startTime && time > startTime) || (lastTime > startTime && time < startTime));
			var rightCrossed:Bool = lastTime != null &&
				((lastTime < endTime && time > endTime) || (lastTime > endTime && time < endTime));
			var rev:Bool = hasLastTime && lastTime > time;
			
			if (leftCrossed || rightCrossed) {
				var cTime:Float = lastTime;
				if (rev) {
					if (rightCrossed) {
						stepTo(endTime, cTime, substep);
						cTime = endTime;
					}
					if (leftCrossed) {
						stepTo(startTime, cTime, substep);
						cTime = startTime;
					}
					if (time != startTime) stepTo(time, cTime, substep);
				} else {
					if (leftCrossed) {
						stepTo(startTime, cTime, substep);
						cTime = startTime;
					}
					if (rightCrossed) {
						stepTo(endTime, cTime, substep);
						cTime = endTime;
					}
					if (time != endTime) stepTo(time, cTime, substep);
				}
			} else {
				currentTime = time;
				updateBounds(lastTime);
				// TODO no need to update until the end?
				onUpdate(time, lastTime, substep);
			}
		}
	}
	
	public function onUpdate(time:Float, ?lastTime:Float, substep:Bool = false):Void {

	}
	
	public static inline function progressFraction(time:Float, start:Float, end:Float):Float {
		if (start == end) {
			return 0.5;
		}
		return Math.min(1, Math.max(0, (time - start) / (end - start)));
	}
	
	private inline function isTimeInBounds(time:Float):Bool {
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
		var currentTimeInBounds = isCurrentTimeInBounds();
		// If first update
		if (lastTime == null) {
			// If not in bounds, do nothing
			if (!currentTimeInBounds) {
				return;
			}
			// Else if in bounds
			else if (currentTime != startTime && currentTime != endTime) {
				onStartInBounds();
			}
			// Else if starting on bounds
			// Note that a point may have startTime == endTime
			// TODO requires further consideration, what is the value of "reverse"?
			else {
				if (currentTime == startTime) {
					onLeftHit(false);
				}
				if (currentTime == endTime) {
					onRightHit(true);
				}
			}
		}
		// If not first update
		else {
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