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
	
	override public function onUpdate(time:Float):Void {
		super.onUpdate(time);
		updateChildren(time);
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
	
	private function updateChildren(nextTime:Float):Void {
		nextTime = (nextTime - startTime) * relativeDuration / duration;
		
		for (child in children) {
			child.stepTo(nextTime);
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