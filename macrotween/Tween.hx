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
		
		var readExpr;
		var handleAssignment;
		var readArray;
		var handleFunction;
		
		handleAssignment = function(fieldExpr:Expr, key:Expr, v:Expr) {
			// Handle array of keys
			switch (key.expr) {
				case EArrayDecl(keyAr):
					for (arrayKey in keyAr) {
						handleAssignment(fieldExpr, arrayKey, v);
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
					readArray(combinedField, ar);
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
				tween: function (startValue:Float, endValue:Float, tween:Tween, time:Float):Void {
					var progress:Float = tween.ease(Tween.progressFraction(time, tween.startTime, tween.endTime));
					// Sets value by interpolation
					${combinedField} = startValue + progress * (endValue - startValue);
				}
			}});
		}
		
		var handleFunction = function(fieldExpr:Expr, e:Expr, params:Array<Expr>) {
			// Replace ranges in the params with interpolation expressions
			for (i in 0...params.length) {
				switch (params[i].expr) {
					case EBinop(op, e1, e2) if (Type.enumEq(op, OpInterval)):
						params[i] = macro {$e1 + progress * ($e2 - $e1); };
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
					return null;
				},
				tween: function (startValue:Float, endValue:Float, tween:Tween, time:Float):Void {
					var progress:Float = tween.ease(Tween.progressFraction(time, tween.startTime, tween.endTime));
					${callExpr};
				}
			}});
		}
		
		readArray = function(fieldExpr:Expr, ar:Array<Expr>) {
			for (arExp in ar) {
				readExpr(fieldExpr, arExp);
			}
		}
		
		readExpr = function(fieldExpr:Expr, e:Expr) {
			switch (e.expr) {
				// [] Array
				case EArrayDecl(ar):
					readArray(fieldExpr, ar);
				// => Operation
				case EBinop(op, key, v) if (Type.enumEq(op, OpArrow)):
					handleAssignment(fieldExpr, key, v);
				// myFunc(...)
				case ECall(e, params):
					handleFunction(fieldExpr, e, params);
				case _:
					throw("Invalid expression in tween");
			}
		}
		
		
		readExpr(null, tweeners);
		
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