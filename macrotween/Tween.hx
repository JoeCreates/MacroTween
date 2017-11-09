package macrotween;

import haxe.macro.ExprTools;
import haxe.macro.Printer;
import haxe.macro.TypeTools;
import haxe.macro.TypedExprTools;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

#if macro
class Tween {
#else
class Tween extends TimelineItem {
	public var ease:Float->Float;
	public var tweeners:Array<Tweener>;

	public function new(startTime:Float, duration:Float, tweeners:Array<Tweener>, ?ease:Float->Float) {
		super(null, startTime, duration);
		this.ease = ease;
		this.tweeners = tweeners;
		for (tweener in tweeners) {
			if (tweener.implicitStart) {
				left.add(function(rev:Bool, count:Int) {
					if (!rev) tweener.startValue = tweener.currentValue();
				});
			}
			if (tweener.implicitEnd) {
				right.add(function(rev:Bool, count:Int) {
					if (rev) tweener.endValue = tweener.currentValue();
				});
			}
		}
	}

	override public function onUpdate(time:Float):Void {
		this.currentTime = time;
		
		if (isTimeInBounds(time)) {
			for (tweener in tweeners) {
				tweener.tween(tweener.startValue, tweener.endValue, this, time);
			}
		}
	}

	public static function progressFraction(time:Float, start:Float, end:Float):Float {
		if (start == end) {
			return 0.5;
		}

		return Math.min(1, Math.max(0, (time - start) / (end - start)));
	}
	
#end
	
	public static macro function tween(startTime:Expr, duration:Expr, tweeners:Expr, ease:Expr):Expr {
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
			tweenerObjects.push(macro {{
				startValue: $startValue,
				endValue: $endValue,
				implicitStart: $implicitStart,
				implicitEnd: $implicitEnd,
				currentValue: function():Float {
					return ${combinedField};
				},
				tween: function (_macroTween_startValue:Float, _macroTween_endValue:Float, _macroTween_tween:Tween, _macroTween_time:Float):Void {
					var _macroTween_progress:Float = _macroTween_tween.ease(
						Tween.progressFraction(_macroTween_time, _macroTween_tween.startTime, _macroTween_tween.endTime));
					// Sets value by interpolation
					${combinedField} = _macroTween_startValue + _macroTween_progress * (_macroTween_endValue - _macroTween_startValue);
				}
			}});
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
			tweenerObjects.push(macro {{//TODO what to do with unneeded values
				startValue: 0,
				endValue: 0,
				implicitStart: false,
				implicitEnd: false,
				currentValue: function():Float {
					return 0;//TODO what to do with this?
				},
				tween: function (_macroTween_startValue:Float, _macroTween_endValue:Float, _macroTween_tween:Tween, _macroTween_time:Float):Void {
					var _macroTween_progress:Float = _macroTween_tween.ease(
						Tween.progressFraction(_macroTween_time, _macroTween_tween.startTime, _macroTween_tween.endTime));
					${callExpr};
				}
			}});
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
					throw("Invalid expression in tween");
			}
		}
		
		handleExpr(null, tweeners);
		
		// Return the new Tween object
		return macro {new Tween(${startTime}, ${duration}, $a{tweenerObjects}, ${ease});};
	}
	
}

typedef Tweener = {
	startValue:Float,
	endValue:Float,
	currentValue:Void->Float,
	implicitStart:Bool,
	implicitEnd:Bool,
	tween:Float->Float->Tween->Float->Void
}