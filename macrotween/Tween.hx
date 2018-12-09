package macrotween;

import macrotween.TimelineItem;
import haxe.ds.Vector;

#if macro
import haxe.macro.ExprTools;
import haxe.macro.Printer;
import haxe.macro.TypeTools;
import haxe.macro.TypedExprTools;
import haxe.macro.Expr;
import haxe.macro.Context;
#end

#if macro
class Tween {
#else
class Tween extends TimelineItem {
	public var tweeners:Vector<Tweener>;

	public function new(tweeners:Array<Tweener>, ?duration:Float = 1, ?startTime:Float = 0, ?ease:Float->Float) {
		super(duration, startTime, ease);
		this.tweeners = Vector.fromArrayCopy(tweeners);
	}
	
	override public function onLeftHit(reversed:Bool):Void {
		if (!reversed) {
			setImplicitStartTimes();
		}
	}
	
	override public function onRightHit(reversed:Bool):Void {
		if (reversed) {
			setImplicitEndTimes();
		}
	}
	
	override public function onStartInBounds():Void {
		setImplicitStartTimes();
		setImplicitEndTimes();
	}

	override public function onUpdate(time:Float, ?lastTime:Float, substep:Bool = false):Void {
		if (isTimeInBounds(time)) {
			for (tweener in tweeners) {
				tweener.tween(tweener.startValue, tweener.endValue, this, time);
			}
		}
	}
	
	private function setImplicitStartTimes():Void {
		for (tweener in tweeners) {
			if (tweener.implicitStart) {
				tweener.startValue = tweener.currentValue();
			}
		}
	}
	
	private function setImplicitEndTimes():Void {
		for (tweener in tweeners) {
			if (tweener.implicitEnd) {
				tweener.endValue = tweener.currentValue();
			}
		}
	}
	
#end

	public static macro function tween(tweeners:Expr, ?duration:Expr, ?startTime:Expr, ?ease:Expr, ?tweenType:TypePath):Expr {
		var tweenerObjects:Array<Expr> = [];
		
		var p = new Printer();
		var combineFieldExpr = function(e1:Expr, e2:Expr) {
			return Context.parseInlineString(p.printExprs([e1, e2], "."), Context.currentPos());
		}
		
		var handleExpr;
		var handleArrow;
		var handleArray;
		var handleFunction;
		
		handleArrow = function(fieldExpr:Expr, key:Expr, v:Expr) {
			// Handle array of keys
			switch (key.expr) {
				case EArrayDecl(keyAr):
					for (arrayKey in keyAr) {
						handleArrow(fieldExpr, arrayKey, v);
					}
					return;
				case _:
			}
			
			var startValue:Expr = macro 0;
			var endValue:Expr = macro 0;
			var implicitStart:Expr = macro false;
			var implicitEnd:Expr = macro false;
			
			// Combination of current field expr and map key
			var combinedField:Expr;
			if (fieldExpr == null) {
				combinedField = key;
			} else {
				combinedField = combineFieldExpr(fieldExpr, key);
			}
			
			// Interpret value expressions
			switch (v.expr) {
				// [] means recurse passing down current field expr
				case EArrayDecl(ar):
					handleArray(combinedField, ar);
					return;
				// a...b means tween from a to b
				case EBinop(op, e1, e2) if (Type.enumEq(op, OpInterval)):
					if (Type.enumEq(e1.expr, (macro _).expr)) {
						implicitStart = macro true;
					} else {
						startValue = e1;
					}
					if (Type.enumEq(e2.expr, (macro _).expr)) {
						implicitEnd = macro true;
					} else {
						endValue = e2;
					}
					
				// By default, use the whole expression as end value
				case _:
					implicitStart = macro true;
					endValue = v;
			}
			
			// Makes the tweener object and adds it to array
			tweenerObjects.push(macro {
				new Tweener($startValue, $endValue, $implicitStart, $implicitEnd,
					function():Float {
						return ${combinedField};
					},
					function (_macroTween_startValue:Float, _macroTween_endValue:Float, _macroTween_tween:Tween, _macroTween_time:Float):Void {
						var _macroTween_progress:Float =
							macrotween.TimelineItem.progressFraction(_macroTween_time, _macroTween_tween.startTime, _macroTween_tween.endTime);
						if (_macroTween_tween.ease != null) _macroTween_progress = _macroTween_tween.ease(_macroTween_progress);
						// Sets value by interpolation
						${combinedField} = _macroTween_startValue + _macroTween_progress * (_macroTween_endValue - _macroTween_startValue);
					}
				);
			});
		}
		
		var handleFunction = function(fieldExpr:Expr, e:Expr, params:Array<Expr>) {
			// Replace ranges in the params with interpolation expressions
			for (i in 0...params.length) {
				switch (params[i].expr) {
					case EBinop(op, e1, e2) if (Type.enumEq(op, OpInterval)):
						params[i] = macro {$e1 + _macroTween_progress * ($e2 - $e1); };
					case _:
				}
			}
			
			// Make full function call expr
			var funcExpr = fieldExpr != null ? combineFieldExpr(fieldExpr, e) : e;
			var callExpr:Expr = macro {$funcExpr($a{params}); };
			
			// Makes the tweener object and adds it to array
			tweenerObjects.push(macro {//TODO what to do with unneeded values
				new Tweener(0, 0, false, false,
					function():Float {
						return 0;//TODO what to do with this?
					},
					function (_macroTween_startValue:Float, _macroTween_endValue:Float, _macroTween_tween:Tween, _macroTween_time:Float):Void {
						var _macroTween_progress:Float =
							macrotween.TimelineItem.progressFraction(_macroTween_time, _macroTween_tween.startTime, _macroTween_tween.endTime);
						if (_macroTween_tween.ease != null) _macroTween_progress = _macroTween_tween.ease(_macroTween_progress);//TODO remove repetition
						${callExpr};
					}
				);
			});
		}
		
		handleArray = function(fieldExpr:Expr, ar:Array<Expr>) {
			for (arExp in ar) {
				handleExpr(fieldExpr, arExp);
			}
		}
		
		handleExpr = function(fieldExpr:Expr, e:Expr) {
			switch (e.expr) {
				// [] Array
				case EArrayDecl(ar):
					handleArray(fieldExpr, ar);
				// => Arrow
				case EBinop(op, key, v) if (Type.enumEq(op, OpArrow)):
					handleArrow(fieldExpr, key, v);
				// myFunc(...) Function call
				case ECall(e, params):
					handleFunction(fieldExpr, e, params);
				case _:
					trace(fieldExpr + " " + e);
					throw("Invalid expression in tweeners");
			}
		}
		
		handleExpr(null, tweeners);
		
		if (duration == null) duration = macro null;
		if (startTime == null) startTime = macro null;
		if (ease == null) ease = macro null;
		if (tweenType == null) tweenType = {pack: ["macrotween"], name: "Tween"};
		
		// Return the new Tween object
		return macro {
			new $tweenType($a{tweenerObjects}, ${duration}, ${startTime}, ${ease});};
	}
	
}

class Tweener {
	public var startValue:Float;
	public var endValue:Float;
	public var currentValue:Void->Float;
	public var implicitStart:Bool;
	public var implicitEnd:Bool;
	public var tween:Float->Float->Tween->Float->Void;
	
	public function new(startValue:Float, endValue:Float, iStart:Bool, iEnd:Bool, currentValue:Void->Float, tween:TweenerFunc){
		this.startValue = startValue;
		this.endValue = endValue;
		this.implicitEnd = iEnd;
		this.implicitStart = iStart;
		this.currentValue = currentValue;
		this.tween = tween;
	}
}

typedef TweenerFunc = Float->Float->Tween->Float->Void;