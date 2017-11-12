package tests;

import macrotween.Tween;

class CallbackTween extends Tween {
	public var leftHit:Bool->Void;
	public var rightHit:Bool->Void;
	
	public function new(startTime:Float, duration:Float, tweeners:Array<Tweener>, ?ease:Float->Float) {
		super(startTime, duration, tweeners, ease);
	}
	
	override public function onLeftHit(rev:Bool):Void {
		super.onLeftHit(rev);
		if (leftHit != null) leftHit(rev);
	}
	override public function onRightHit(rev:Bool):Void {
		super.onRightHit(rev);
		if (rightHit != null) rightHit(rev);
	}
}

abstract HelperAbstractFloat(Float) to Float from Float {
	inline public function new(f:Float) {
		this = f;
	}
}

class HelperObject {
	public function new() {
	}
	public var floatValue:Float = 0;
	public var nullableFloatValue:Null<Float> = 0;
	public var integerValue:Int = 0;
	
	public var floatProperty(default, set):Float = 0;
	public function set_floatProperty(f:Float):Float {
		return this.floatProperty = f;
	}
	
	public var unaryFunction = function(x:Float) {};
	public var unaryFunctionWithOptionalParam = function(?x:Null<Float>) {};
	public var unaryFunctionWithDefaultParam = function(x:Float = 0) {};
	
	static public var staticFunction = function(x:Float, y:Float) {};
	static public var staticFunctionWithOptionalParams = function(?x:Null<Float>, ?y:Null<Float>) {};
	static public var staticFunctionWithDefaultParams = function(x:Float = 0, y:Float = 0) {};
}
