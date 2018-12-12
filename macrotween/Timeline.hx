package macrotween;

 #if macro
import haxe.macro.ExprTools;
import haxe.macro.Printer;
import haxe.macro.TypeTools;
import haxe.macro.TypedExprTools;
import haxe.macro.Expr;
import haxe.macro.Context;
#end

#if macro
class Timeline {
#else
/**
 * The Timeline class helps organize multiple timeline items, such as Tweens,
 * allowing them to be managed and manipulated as a group.
 * Timelines are themselves timeline items, and so can be nested within each other.
 */
class Timeline extends TimelineItem {
	public var children(default, null):Array<TimelineItem>;

	// TODO auto grow/shrink timelines duration based on children?
	
	public function new(?duration:Float = 1, ?startTime:Float = 0, ?ease:Float->Float) {
		super(duration, startTime, ease);
		this.children = new Array<TimelineItem>();
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
	
	override public function onUpdate(time:Float, ?lastTime:Float, substep:Bool = false):Void {
		updateChildren(time, lastTime, substep);
	}

	public function add(child:TimelineItem):Timeline {
		children.push(child);
		return this;
	}

	public function remove(child:TimelineItem):Timeline {
		children.remove(child);
		child.onRemoved(this);
		return this;
	}

	public function clear():Void {
		children.splice(0, children.length);
	}
	
	private function updateChildren(time:Float, ?lastTime:Float, substep:Bool = false):Void {
		// TODO get rid of these, use eased versions instead
		var actualTime:Float = time;
		var actualLastTime:Null<Float> = lastTime;
		
		if (ease != null) {
			time = ease(time);
		}
		if (lastTime != null && ease != null) {
			lastTime = ease(lastTime);
		}
		
		if (!substep || lastTime == null) {
			for (child in children) {
				child.stepTo(time, substep);
			}
			return;
		}
		
		// TODO could make this more efficient
		var relativeTime:Float = (actualTime - startTime);
		var relativeLast:Float = (lastTime - startTime);
		
		if (ease != null) {
			relativeTime = ease(relativeTime);
			relativeLast = ease(relativeLast);
		}
		
		// TODO doesn't account for functions that change relative ordering of times
		var times:Array<Float> = [ relativeTime ];
		for (child in children) {
			if (time < lastTime) {
				if (child.startTime <= relativeLast && child.startTime >= relativeTime) {
					times.push(child.startTime);
				}
				if (child.endTime <= relativeLast && child.endTime >= relativeTime) {
					times.push(child.endTime);
				}
			} else {
				if (child.startTime >= relativeLast && child.startTime <= relativeTime) {
					times.push(child.startTime);
				}
				if (child.endTime >= relativeLast && child.endTime <= relativeTime) {
					times.push(child.endTime);
				}
			}
		}
		
		if (time < lastTime) {
			times.sort(function(a:Float, b:Float):Int {
				if (a < b) return 1;
				else if (a > b) return -1;
				return 0;
			});
		} else {
			times.sort(function(a:Float, b:Float):Int {
				if (a < b) return -1;
				else if (a > b) return 1;
				return 0;
			});
		}
		
		for (time in times) {
			if (relativeLast == time) {
				continue;
			}
			for (child in children) {
				child.stepTo(ease != null ? ease(time) : time, null, substep);
			}
			relativeLast = time;
		}
	}

#end

	public macro function tween(inst:Expr, tweeners:Expr, ?duration:Expr, ?startTime:Expr, ?ease:Expr):Expr {
		if (duration == null) duration = macro null;
		if (startTime == null) startTime = macro null;
		
		return macro {
			${inst}.add(Tween.tween($tweeners, $duration, $startTime, $ease));
		};
	}
}