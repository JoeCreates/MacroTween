/**
	Easing equations in this package were adapted from The Cinder Project (http://libcinder.org/) held under the Modified BSD license:

	// Begin Cinder Project LICENSE block

	Copyright (c) 2011, The Cinder Project, All rights reserved.
	This code is intended for use with the Cinder C++ library: http://libcinder.org

	Redistribution and use in source and binary forms, with or without modification, are permitted provided that
	the following conditions are met:

	* Redistributions of source code must retain the above copyright notice, this list of conditions and
	the following disclaimer.
	* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and
	the following disclaimer in the documentation and/or other materials provided with the distribution.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
	PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
	ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
	TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
	HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.

	Documentation and easeOutIn* algorithms adapted from Qt: http://qt.nokia.com/products/

	Disclaimer for Robert Penner's Easing Equations license:
	TERMS OF USE - EASING EQUATIONS
	Open source under the BSD License.

	Copyright © 2001 Robert Penner
	All rights reserved.

	Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
	* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
	* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
	* Neither the name of the author nor the names of contributors may be used to endorse or promote products derived from this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

	// End Cinder Project LICENSE block

	Cubic hermite spline interpolator was based on this StackOverflow answer by Roman Zenka: http://stackoverflow.com/a/3367593/1333253
**/

package macrotween;


class Ease {
	
	// Atan
	public inline static function makeInAtan(a:Float = 15):Float->Float {
		return inAtan.bind(_, a);
	}
	public inline static function makeOutAtan(a:Float = 15):Float->Float {
		return outAtan.bind(_, a);
	}
	public inline static function makeInOutAtan(a:Float = 15):Float->Float {
		return inOutAtan.bind(_, a);
	}

	public inline static function atanIn(t:Float, a:Float = 15):Float {
		var m:Float = Math.atan(a);
		return Math.atan((t - 1) * a) / m + 1;
	}

	public inline static function atanOut(t:Float, a:Float = 15):Float {
		return Math.atan(t * a)  / 2;
	}

	public inline static function atanInOut(t:Float, a:Float = 15):Float {
		var m:Float = Math.atan(0.5 * a);
		return Math.atan((t - 0.5) * a) / (2 * m) + 0.5;
	}
	
	// Back
	public inline static function makeInBack(s:Float = 1.70158):Float->Float {
		return inBack.bind(_, s);
	}

	public inline static function makeOutBack(s:Float = 1.70158):Float->Float {
		return outBack.bind(_, s);
	}

	public inline static function makeInOutBack(s:Float = 1.70158):Float->Float {
		return inOutBack.bind(_, s);
	}

	public inline static function makeOutInBack(s:Float = 1.70158):Float->Float {
		return outInBack.bind(_, s);
	}

	public inline static function backIn(t:Float, s:Float = 1.70158):Float {
		return t * t * ((s + 1) * t - s);
	}

	public inline static function backOut(t:Float, s:Float = 1.70158):Float {
		t -= 1;
		return t * t * ((s + 1) * t + s) + 1;
	}

	public inline static function backInOut(t:Float, s:Float = 1.70158):Float {
		t *= 2;
		s *= 1.525;
		return (t < 1) ? 0.5 * (t * t * ((s + 1) * t - s)) : 0.5 * ((t -= 2) * t * ((s + 1) * t + s) + 2);
	}

	public inline static function backOutIn(t:Float, s:Float = 1.70158):Float {
		return (t < 0.5) ? backOut(2 * t, s) / 2 : backIn(2 * t - 1, s) / 2 + 0.5;
	}
	
	// Bounce
	public inline static function makeInBounce(a:Float = 1.70158):Float->Float {
		return inBounce.bind(_, a);
	}

	public inline static function makeOutBounce(a:Float = 1.70158):Float->Float {
		return outBounce.bind(_, a);
	}

	public inline static function makeInOutBounce(a:Float = 1.70158):Float->Float {
		return inOutBounce.bind(_, a);
	}

	public inline static function makeOutInBounce(a:Float = 1.70158):Float->Float {
		return outInBounce.bind(_, a);
	}

	public inline static function bounceIn(t:Float, a:Float = 1.70158):Float {
		return 1 - bounceHelperOut(1 - t, 1, a);
	}

	public inline static function bounceOut(t:Float, a:Float = 1.70158):Float {
		return bounceHelperOut(t, 1, a);
	}

	public inline static function bounceInOut(t:Float, a:Float = 1.70158):Float {
		return (t < 0.5) ? bounceIn(2 * t, a) / 2 : (t == 1) ? 1 : bounceOut(2 * t - 1, a) / 2 + 0.5;
	}

	public inline static function bounceOutIn(t:Float, a:Float = 1.70158):Float {
		return (t < 0.5) ? bounceHelperOut(t * 2, 0.5, a) : 1 - bounceHelperOut(2 - 2 * t, 0.5, a);
	}

	private inline static function bounceHelperOut(t:Float, b:Float, c:Float):Float {
		if (t == 1) {
			return b;
		} else if (t < (4 / 11)) {
			return b * (7.5625 * t * t);
		} else if (t < (8 / 11)) {
			t -= 6 / 11;
			return -c * (1 - (7.5625 * t * t + 0.75)) + b;
		} else if (t < (10 / 11)) {
			t -= 9 / 11;
			return -c * (1 - (7.5625 * t * t + 0.9375)) + b;
		} else {
			t -= 21 / 22;
			return -c * (1 - (7.5625 * t * t + 0.984375)) + b;
		}
	}
	
	// Circular
	public inline static function circIn(t:Float):Float {
		return -(Math.sqrt(1 - t * t) - 1);
	}

	public inline static function circOut(t:Float):Float {
		t -= 1;
		return Math.sqrt(1 - t * t);
	}

	public inline static function circInOut(t:Float):Float {
		t *= 2;
		return (t < 1) ? -0.5 * (Math.sqrt(1 - t * t) - 1) : 0.5 * (Math.sqrt(1 - (t -= 2) * t) + 1);
	}

	public inline static function circOutIn(t:Float):Float {
		return (t < 0.5) ? circOut(2 * t) / 2 : circIn(2 * t - 1) / 2 + 0.5;
	}
	
	// Cubic
	public inline static function cubicIn(t:Float):Float {
		return t * t * t;
	}

	public inline static function cubicOut(t:Float):Float {
		t -= 1;
		return t * t * t + 1;
	}

	public inline static function cubicInOut(t:Float):Float {
		t *= 2;
		return (t < 1) ? 0.5 * t * t * t : 0.5 * ((t -= 2)* t * t + 2);
	}

	public inline static function cubicOutIn(t:Float):Float {
		return (t < 0.5) ? cubicOut(2 * t) / 2 : cubicIn(2 * t - 1) / 2 + 0.5;
	}
	
	// Cubic Hermite
	public inline static function makeHermite(accelTime:Float, cruiseTime:Float, decelTime:Float):Float->Float {
		return hermite.bind(_, accelTime, cruiseTime, decelTime);
	}

	public inline static function hermite(t:Float, accelTime:Float, cruiseTime:Float, decelTime:Float):Float {
		var v:Float = 1 / (accelTime / 2 + cruiseTime + decelTime / 2);
		var x1:Float = v * accelTime / 2;
		var x2:Float = v * cruiseTime;
		var x3:Float = v * decelTime / 2;

		if (t < accelTime) {
			return cubicHermite(t / accelTime, 0, x1, 0, x2 / cruiseTime * accelTime);
		} else if (t <= accelTime + cruiseTime) {
			return x1 + x2 * (t - accelTime) / cruiseTime;
		} else {
			return cubicHermite((t - accelTime - cruiseTime) / decelTime, x1 + x2, 1, x2 / cruiseTime * decelTime, 0);
		}
	}

	private inline static function cubicHermite(t:Float, start:Float, end:Float, stan:Float, etan:Float):Float {
		var t2 = t * t;
		var t3 = t2 * t;
		return (2 * t3 - 3 * t2 + 1) * start + (t3 - 2 * t2 + t) * stan + ( -2 * t3 + 3 * t2) * end + (t3 - t2) * etan;
	}
	
	// Elastic
	public inline static function makeInElastic(amp:Float, period:Float):Float->Float {
		return inElastic.bind(_, amp, period);
	}

	public inline static function makeOutElastic(amp:Float, period:Float):Float->Float {
		return outElastic.bind(_, amp, period);
	}

	public inline static function makeInOutElastic(amp:Float, period:Float):Float->Float {
		return inOutElastic.bind(_, amp, period);
	}

	public inline static function makeOutInElastic(amp:Float, period:Float):Float->Float {
		return outInElastic.bind(_, amp, period);
	}

	public inline static function elasticIn(t:Float, amp:Float, period:Float):Float {
		return elasticHelperIn(t, 0, 1, 1, amp, period);
	}

	public inline static function elasticOut(t:Float, amp:Float, period:Float):Float {
		return elasticHelperOut(t, 0, 1, 1, amp, period);
	}

	public static function elasticInOut(t:Float, amp:Float, period:Float):Float {
		if (t == 0) {
			return 0;
		}
		t *= 2;
		if (t == 2) {
			return 1;
		}

		var s:Float;
		if (amp < 1) {
			amp = 1;
			s = period / 4;
		} else {
			s = period / (2 * Math.PI) * Math.asin(1 / amp);
		}

		if (t < 1) {
			return -0.5 * (amp * Math.pow(2, 10 * (t - 1)) * Math.sin(t - 1 - s) * ((2 * Math.PI) / period));
		}

		return amp * Math.pow(2, -10 * (t - 1)) * Math.sin((t - 1 - s) * (2 * Math.PI) / period) * 0.5 + 1;
	}

	public inline static function elasticOutIn(t:Float, amp:Float, period:Float):Float {
		if (t < 0.5) {
			return elasticHelperOut(t * 2, 0, 0.5, 1.0, amp, period);
		}
		return elasticHelperIn(2 * t - 1.0, 0.5, 0.5, 1.0, amp, period);
	}

	private inline static function elasticHelperIn(t:Float, b:Float, c:Float, d:Float, a:Float, p:Float):Float {
		if (t == 0) {
			return b;
		}
		var adj:Float = t / d;
		if (adj == 1) {
			return b + c;
		}

		var s:Float;
		if (a < Math.abs(c)) {
			a = c;
			s = p / 4.0;
		} else {
			s = p / (2 * Math.PI) * Math.asin(c / a);
		}

		adj -= 1;
		return -(a * Math.pow(2, 10 * adj) * Math.sin((adj * d - s) * (2 * Math.PI) / p)) + b;
	}

	private inline static function elasticHelperOut(t:Float, b:Float, c:Float, d:Float, a:Float, p:Float):Float {
		if (t == 0) {
			return 0;
		}
		if (t == 1) {
			return c;
		}

		var s:Float;
		if (a < c) {
			a = c;
			s = p / 4.0;
		} else {
			s = p / (2 * Math.PI) * Math.asin(c / a);
		}

		return a * Math.pow(2, -10 * t) * Math.sin((t - s) * (2 * Math.PI) / p ) + c;
	}
	
	// Expo
	public inline static function expoIn(t:Float):Float {
		return (t == 0) ? 0 : Math.pow(2, 10 * (t - 1));
	}

	public inline static function expoOut(t:Float):Float {
		return (t == 1) ? 1 : - Math.pow(2, -10 * t) + 1;
	}

	public inline static function expoInOut(t:Float):Float {
		if (t == 0) {
			return t;
		}
		if (t == 1) {
			return t;
		}
		t *= 2;
		if (t < 1) {
			return 0.5 * Math.pow(2, 10 * (t - 1));
		}
		return 0.5 * ( -Math.pow(2, -10 * (t - 1)) + 2);
	}

	public inline static function expoOutIn(t:Float):Float {
		return (t < 0.5) ? expoOut(2 * t) / 2 : expoIn(2 * t - 1) / 2 + 0.5;
	}
	
	// Linear
	public inline static function none(t:Float):Float {
		return t;
	}
	
	// Quad
	public inline static function quadIn(t:Float):Float {
		return t * t;
	}

	public inline static function quadOut(t:Float):Float {
		return -t * (t - 2);
	}

	public inline static function quadInOut(t:Float):Float {
		t *= 2;
		return (t < 1) ? 0.5 * t * t : -0.5 * ((t - 1) * (t - 3) - 1);
	}

	public inline static function quadOutIn(t:Float):Float {
		return (t < 0.5) ? quadOut(t * 2) * 0.5 : quadIn((t * 2) - 1) * 0.5 + 0.5;
	}
	
	// Quart
	public inline static function quartIn(t:Float):Float {
		return t * t * t * t;
	}

	public inline static function quartOut(t:Float):Float {
		t -= 1;
		return -(t * t * t * t - 1);
	}

	public inline static function quartInOut(t:Float):Float {
		t *= 2;
		return (t < 1) ? 0.5 * t * t * t * t : -0.5 * ((t -= 2) * t * t * t - 2);
	}

	public inline static function quartOutIn(t:Float):Float {
		return (t < 0.5) ? quartOut(2 * t) / 2 : quartIn(2 * t - 1) / 2 + 0.5;
	}
	
	// Quint
	public inline static function quintIn(t:Float):Float {
		return t * t * t * t * t;
	}

	public inline static function quintOut(t:Float):Float {
		t -= 1;
		return t * t * t * t * t + 1;
	}

	public inline static function quintInOut(t:Float):Float {
		t *= 2;
		return (t < 1) ? 0.5 * t * t * t * t * t : 0.5 * ((t -= 2) * t * t * t * t + 2);
	}

	public inline static function quintOutIn(t:Float):Float {
		return (t < 0.5) ? quintOut(2 * t) / 2 : quintIn(2 * t - 1) / 2 + 0.5;
	}
	
	// Sine
	public inline static function sineIn(t:Float):Float {
		return -Math.cos(t * Math.PI / 2.0) + 1;
	}

	public inline static function sineOut(t:Float):Float {
		return Math.sin(t * Math.PI / 2.0);
	}

	public inline static function sineInOut(t:Float):Float {
		return -0.5 * (Math.cos(Math.PI * t) - 1);
	}

	public inline static function sineOutIn(t:Float):Float {
		return (t < 0.5) ? sineOut(2 * t) / 2 : sineIn(2 * t - 1) / 2 + 0.5;
	}
	
	
	
}