package macrotween;

// Easing equations in this package are adapted from The Cinder Project (http://libcinder.org/)
// and are provided under the Modified BSD license:
//
// Copyright (c) 2011, The Cinder Project, All rights reserved.
// This code is intended for use with the Cinder C++ library: http://libcinder.org
//
// Redistribution and use in source and binary forms, with or without modification, are permitted provided that
// the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this list of conditions and
// the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and
// the following disclaimer in the documentation and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
// WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
// PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
// TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// ----
//
// Documentation and easeOutIn* algorithms adapted from Qt (http://qt.nokia.com/products/)
//
// Disclaimer for Robert Penner's Easing Equations license:
// TERMS OF USE - EASING EQUATIONS
// Open source under the BSD License.
//
// Copyright © 2001 Robert Penner
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
// * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
// * Neither the name of the author nor the names of contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
// WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
// PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
// TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// ----
//
// Cubic hermite spline interpolator was based on this StackOverflow
// answer by Roman Zenka: http://stackoverflow.com/a/3367593/1333253

class Ease {
	
	// Atan
	public static inline function atanIn(t:Float):Float return atanInAdv.bind(_, 15)(t);
	public static inline function atanInOut(t:Float):Float return atanInOutAdv.bind(_, 15)(t);
	public static inline function atanOut(t:Float):Float return atanOutAdv.bind(_, 15)(t);

	public static inline function atanInAdv(t:Float, a:Float = 15):Float {
		var m:Float = Math.atan(a);
		return Math.atan((t - 1) * a) / m + 1;
	}

	public static inline function atanOutAdv(t:Float, a:Float = 15):Float {
		var m:Float = Math.atan(a);
		return Math.atan(t * a)  / m;
	}

	public static inline function atanInOutAdv(t:Float, a:Float = 15):Float {
		return combine(atanIn, atanOut)(t);
	}
	
	// Back
	public static inline function backIn(t:Float):Float return backInAdv.bind(_, 1.70158)(t);
	public static inline function backOut(t:Float):Float return backOutAdv.bind(_, 1.70158)(t);
	public static inline function backInOut(t:Float):Float return backInOutAdv.bind(_, 1.70158)(t);
	public static inline function backOutIn(t:Float):Float return backOutInAdv.bind(_, 1.70158)(t);
	
	public static inline function backInAdv(t:Float, s:Float = 1.70158):Float {
		return t * t * ((s + 1) * t - s);
	}

	public static inline function backOutAdv(t:Float, s:Float = 1.70158):Float {
		t -= 1;
		return t * t * ((s + 1) * t + s) + 1;
	}

	public static inline function backInOutAdv(t:Float, s:Float = 1.70158):Float {
		t *= 2;
		s *= 1.525;
		return (t < 1) ? 0.5 * (t * t * ((s + 1) * t - s)) : 0.5 * ((t -= 2) * t * ((s + 1) * t + s) + 2);
	}

	public static inline function backOutInAdv(t:Float, s:Float = 1.70158):Float {
		return (t < 0.5) ? backOutAdv(2 * t, s) / 2 : backInAdv(2 * t - 1, s) / 2 + 0.5;
	}
	
	// Bounce
	public static inline function bounceIn(t:Float):Float return bounceInAdv.bind(_, 1.70158)(t);
	public static inline function bounceOut(t:Float):Float return bounceOutAdv.bind(_, 1.70158)(t);
	public static inline function bounceInOut(t:Float):Float return bounceInOutAdv.bind(_, 1.70158)(t);
	public static inline function bounceOutIn(t:Float):Float return bounceOutInAdv.bind(_, 1.70158)(t);

	public static inline function bounceInAdv(t:Float, a:Float = 1.70158):Float {
		return 1 - bounceHelperOut(1 - t, 1, a);
	}

	public static inline function bounceOutAdv(t:Float, a:Float = 1.70158):Float {
		return bounceHelperOut(t, 1, a);
	}

	public static inline function bounceInOutAdv(t:Float, a:Float = 1.70158):Float {
		return (t < 0.5) ? bounceInAdv(2 * t, a) / 2 : (t == 1) ? 1 : bounceOutAdv(2 * t - 1, a) / 2 + 0.5;
	}

	public static inline function bounceOutInAdv(t:Float, a:Float = 1.70158):Float {
		return (t < 0.5) ? bounceHelperOut(t * 2, 0.5, a) : 1 - bounceHelperOut(2 - 2 * t, 0.5, a);
	}

	private static inline function bounceHelperOut(t:Float, b:Float, c:Float):Float {
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
	public static inline function circIn(t:Float):Float {
		return -(Math.sqrt(1 - t * t) - 1);
	}

	public static inline function circOut(t:Float):Float {
		t -= 1;
		return Math.sqrt(1 - t * t);
	}

	public static inline function circInOut(t:Float):Float {
		return combine(circIn, circOut)(t);
	}

	public static inline function circOutIn(t:Float):Float {
		return (t < 0.5) ? circOut(2 * t) / 2 : circIn(2 * t - 1) / 2 + 0.5;
	}
	
	// Cubic Hermite
	public static inline function hermite(t:Float, accelTime:Float, cruiseTime:Float, decelTime:Float):Float {
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

	private static inline function cubicHermite(t:Float, start:Float, end:Float, stan:Float, etan:Float):Float {
		var t2 = t * t;
		var t3 = t2 * t;
		return (2 * t3 - 3 * t2 + 1) * start + (t3 - 2 * t2 + t) * stan + ( -2 * t3 + 3 * t2) * end + (t3 - t2) * etan;
	}
	
	// Elastic
	public static inline function elasticIn(t:Float):Float return elasticInAdv.bind(_, 1, 0.4)(t);
	public static inline function elasticOut(t:Float):Float return elasticOutAdv.bind(_, 1, 0.4)(t);
	public static inline function elasticInOut(t:Float):Float return elasticInOutAdv.bind(_, 1, 0.4)(t);
	public static inline function elasticOutIn(t:Float):Float return elasticOutInAdv.bind(_, 1, 0.4)(t);
	
	public static inline function elasticInAdv(t:Float, amp:Float, period:Float):Float {
		return elasticHelperIn(t, 0, 1, 1, amp, period);
	}

	public static inline function elasticOutAdv(t:Float, amp:Float, period:Float):Float {
		return elasticHelperOut(t, 0, 1, 1, amp, period);
	}

	public static function elasticInOutAdv(t:Float, amp:Float, period:Float):Float {
		return combine(elasticInAdv.bind(_, amp, period), elasticOutAdv.bind(_, amp, period))(t);
	}

	public static inline function elasticOutInAdv(t:Float, amp:Float, period:Float):Float {
		return combine(elasticOutAdv.bind(_, amp, period), elasticInAdv.bind(_, amp, period))(t);
	}

	private static inline function elasticHelperIn(t:Float, b:Float, c:Float, d:Float, a:Float, p:Float):Float {
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

	private static inline function elasticHelperOut(t:Float, b:Float, c:Float, d:Float, a:Float, p:Float):Float {
		if (t == 0) return 0;
		if (t == 1) return c;

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
	public static inline function expoIn(t:Float):Float {
		return (t == 0) ? 0 : Math.pow(2, 10 * (t - 1));
	}

	public static inline function expoOut(t:Float):Float {
		return (t == 1) ? 1 : - Math.pow(2, -10 * t) + 1;
	}

	public static inline function expoInOut(t:Float):Float {
		return combine(expoIn, expoOut)(t);
	}

	public static inline function expoOutIn(t:Float):Float {
		return combine(expoOut, expoIn)(t);
	}
	
	// Linear
	public static inline function linear(t:Float):Float {
		return t;
	}
	
	// Quad
	public static inline function quadIn(t:Float):Float {
		return t * t;
	}

	public static inline function quadOut(t:Float):Float {
		return -t * (t - 2);
	}

	public static inline function quadInOut(t:Float):Float {
		return combine(quadIn, quadOut)(t);
	}

	public static inline function quadOutIn(t:Float):Float {
		return combine(quadOut, quadIn)(t);
	}
	
	// Cubic
	public static inline function cubicIn(t:Float):Float {
		return t * t * t;
	}

	public static inline function cubicOut(t:Float):Float {
		t -= 1;
		return t * t * t + 1;
	}

	public static inline function cubicInOut(t:Float):Float {
		return combine(cubicIn, cubicOut)(t);
	}

	public static inline function cubicOutIn(t:Float):Float {
		return combine(cubicOut, cubicIn)(t);
	}
	
	// Quart
	public static inline function quartIn(t:Float):Float {
		return t * t * t * t;
	}

	public static inline function quartOut(t:Float):Float {
		t -= 1;
		return -(t * t * t * t - 1);
	}

	public static inline function quartInOut(t:Float):Float {
		return combine(quartIn, quartOut)(t);
	}

	public static inline function quartOutIn(t:Float):Float {
		return combine(quartOut, quartIn)(t);
	}
	
	// Quint
	public static inline function quintIn(t:Float):Float {
		return t * t * t * t * t;
	}

	public static inline function quintOut(t:Float):Float {
		t -= 1;
		return t * t * t * t * t + 1;
	}

	public static inline function quintInOut(t:Float):Float {
		return combine(quintIn, quintOut)(t);
	}

	public static inline function quintOutIn(t:Float):Float {
		return combine(quintOut, quintIn)(t);
	}
	
	// Sine
	public static inline function sineIn(t:Float):Float {
		return -Math.cos(t * Math.PI / 2.0) + 1;
	}

	public static inline function sineOut(t:Float):Float {
		return Math.sin(t * Math.PI / 2.0);
	}

	public static inline function sineInOut(t:Float):Float {
		return -0.5 * (Math.cos(Math.PI * t) - 1);
	}

	public static inline function sineOutIn(t:Float):Float {
		return (t < 0.5) ? sineOut(2 * t) / 2 : sineIn(2 * t - 1) / 2 + 0.5;
	}
	
	// Continuous piecewise linear, equal-length pieces (2 or more pieces required)
	public static inline function piecewiseLinear(t:Float, pieces:Array<Float>):Float {
		inline function lerp(a:Float, b:Float, f:Float):Float {
			return a + f * (b - a);
		};
		
		var segments:Int = pieces.length - 1;
		var segmentLength:Float = 1 / segments;
		
		t = Math.min(1, Math.max(0, t));
		var segmentIdx:Int = Math.floor(t * segments);
		
		var basePoint:Int = segmentIdx;
		var nextPoint:Int = segmentIdx + 1;
		
		var p1:Float = pieces[basePoint];
		var p2:Float = pieces[nextPoint];
		
		var segmentT:Float = (t - (segmentLength * segmentIdx)) / segmentLength;
		return lerp(p1, p2, segmentT);
	}
	
	public static inline function combine(ease1:Float->Float, ease2:Float->Float):Float->Float {
		return function(t:Float):Float {return t < 0.5 ? 0.5 * ease1(t * 2) : (0.5 + 0.5 * ease2((t - 0.5) * 2));};
	}
}