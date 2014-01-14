(function () { "use strict";
var Main = function() { }
Main.__name__ = true;
Main.main = function() {
	var start = new Date().getTime();
	console.log(Primes.first(20));
	var elapsed = new Date().getTime() - start;
	console.log(elapsed + " MS elapsed");
}
var Primes = function() { }
Primes.__name__ = true;
Primes.first = function(n) {
	var result = [];
	var iter = new PrimesIter();
	var _g = 0;
	while(_g < n) {
		var i = _g++;
		result.push(iter.next());
	}
	return result;
}
var PrimesIter = function() {
	this.n = 0;
	this.primesSoFar = new Array();
};
PrimesIter.__name__ = true;
PrimesIter.prototype = {
	memoized_isPrime: function(n) {
		if(PrimesIter.cache.get(n) == null) {
			var v = this.isPrime(n);
			PrimesIter.cache.set(n,v);
			v;
		}
		return PrimesIter.cache.get(n);
	}
	,isPrime: function(n) {
		if(n <= 0) throw "Invalid argument";
		if(n == 1 || n == 2) return true;
		var i = Math.ceil(n / 2);
		var _g1 = 1, _g = this.primesSoFar.length;
		while(_g1 < _g) {
			var i1 = _g1++;
			if(n % this.primesSoFar[i1] == 0) return false;
		}
		return true;
	}
	,next: function() {
		while(true) {
			this.n++;
			if(this.memoized_isPrime(this.n)) {
				this.primesSoFar.push(this.n);
				return this.n;
			}
		}
	}
	,hasNext: function() {
		return true;
	}
	,__class__: PrimesIter
}
var IMap = function() { }
IMap.__name__ = true;
var haxe = {}
haxe.ds = {}
haxe.ds.IntMap = function() {
	this.h = { };
};
haxe.ds.IntMap.__name__ = true;
haxe.ds.IntMap.__interfaces__ = [IMap];
haxe.ds.IntMap.prototype = {
	get: function(key) {
		return this.h[key];
	}
	,set: function(key,value) {
		this.h[key] = value;
	}
	,__class__: haxe.ds.IntMap
}
var js = {}
js.Boot = function() { }
js.Boot.__name__ = true;
js.Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0, _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js.Boot.__interfLoop(cc.__super__,cl);
}
js.Boot.__instanceof = function(o,cl) {
	if(cl == null) return false;
	switch(cl) {
	case Int:
		return (o|0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return typeof(o) == "boolean";
	case String:
		return typeof(o) == "string";
	case Dynamic:
		return true;
	default:
		if(o != null) {
			if(typeof(cl) == "function") {
				if(o instanceof cl) {
					if(cl == Array) return o.__enum__ == null;
					return true;
				}
				if(js.Boot.__interfLoop(o.__class__,cl)) return true;
			}
		} else return false;
		if(cl == Class && o.__name__ != null) return true;
		if(cl == Enum && o.__ename__ != null) return true;
		return o.__enum__ == cl;
	}
}
Math.__name__ = ["Math"];
Math.NaN = Number.NaN;
Math.NEGATIVE_INFINITY = Number.NEGATIVE_INFINITY;
Math.POSITIVE_INFINITY = Number.POSITIVE_INFINITY;
Math.isFinite = function(i) {
	return isFinite(i);
};
Math.isNaN = function(i) {
	return isNaN(i);
};
String.prototype.__class__ = String;
String.__name__ = true;
Array.prototype.__class__ = Array;
Array.__name__ = true;
Date.prototype.__class__ = Date;
Date.__name__ = ["Date"];
var Int = { __name__ : ["Int"]};
var Dynamic = { __name__ : ["Dynamic"]};
var Float = Number;
Float.__name__ = ["Float"];
var Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = { __name__ : ["Class"]};
var Enum = { };
PrimesIter.cache = new haxe.ds.IntMap();
Main.main();
})();
