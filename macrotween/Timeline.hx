package macrotween;

/**
 * The Timeline class helps organize multiple timeline items, such as Tweens,
 * allowing them to be managed and manipulated as a group.
 * Timelines are themselves timeline items, and so can be nested within each other.
 */
class Timeline extends TimelineItem {
	private var children:List<TimelineItem>;
	public var relativeDuration:Float;

	public function new() {
		super(0, 0);
		children = new List<TimelineItem>();
		relativeDuration = 1;
	}
	
	/**
	 * Resets all the children of the timeline
	 */
	override public function reset():Void {
		super.reset();

		for (child in children) {
			child.reset();
		}
		
		onReset();
	}
	
	override public function onUpdate(time:Float):Void {
		updateChildren(time);
	}

	public function add(child:TimelineItem):Void {
		children.add(child);
	}

	public function remove(child:TimelineItem):Void {
		children.remove(child);
		child.onRemoved(this);
	}

	public function clear():Void {
		children = new List<TimelineItem>();
	}
	
	private function updateChildren(nextTime:Float):Void {
		//nextTime -= startTime;
		// TODO
		
		for (child in children) {
			child.stepTo(nextTime);
		}
	}
	
	
	
	private static inline function clamp(value:Float, ?min:Float, ?max:Float):Float {
		var lowerBound:Float = (min != null && value < min) ? min : value;
		return (max != null && lowerBound > max) ? max : lowerBound;
	}
}