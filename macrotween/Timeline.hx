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
	public var relativeDuration:Float;
	public var length(get, never):Int;
	
	private var children:Array<TimelineItem>;

	public function new(startTime:Float = 0, duration:Float = 1, relativeDuration:Float = 1) {
		super(startTime, duration);
		this.relativeDuration = relativeDuration;
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
		var relativeTime:Float = (time - startTime) * relativeDuration / duration;
		
		if (!substep || lastTime == null) {
			for (child in children) {
				child.stepTo(time, substep);
			}
			return;
		}
		
		// TODO could make this more efficient
		var relativeLast:Float = (lastTime - startTime) * relativeDuration / duration;
		
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
				child.stepTo(time, null, substep);
			}
			relativeLast = time;
		}
	}
	
	private function get_length():Int {
		return children.length;
	}
	
	private static inline function clamp(value:Float, ?min:Float, ?max:Float):Float {
		var lowerBound:Float = (min != null && value < min) ? min : value;
		return (max != null && lowerBound > max) ? max : lowerBound;
	}

#end

	public macro function tween(inst:Expr, startTime:Expr, duration:Expr, tweeners:Expr, ?ease:Expr):Expr {
		return macro {
			${inst}.add(Tween.tween($startTime, $duration, $tweeners, $ease));
		};
	}
}