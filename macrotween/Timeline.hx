package macrotween;

/**
 * The Timeline class helps organize multiple timeline items, such as Tweens,
 * allowing them to be managed and manipulated as a group.
 * Timelines are themselves timeline items, and so can be nested within each other.
 */

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
class Timeline extends TimelineItem {
	private var children:List<TimelineItem>;
	public var relativeDuration:Float;

	public function new(startTime:Float = 0, duration:Float = 1) {
		super(startTime, duration);
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

	public function add(child:TimelineItem):Timeline {
		children.add(child);
		return this;
	}

	public function remove(child:TimelineItem):Timeline {
		children.remove(child);
		child.onRemoved(this);
		return this;
	}

	public function clear():Void {
		children = new List<TimelineItem>();
	}
	
	private function updateChildren(nextTime:Float):Void {
		nextTime = (nextTime - startTime) * relativeDuration / duration;
		
		for (child in children) {
			child.stepTo(nextTime);
		}
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