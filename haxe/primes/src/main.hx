class Main
{
    public static function main()
    {
        var start:Float = Date.now().getTime();
        trace(new Primes().take(10).toList());
        var elapsed = Date.now().getTime() - start;
        trace(elapsed + " MS elapsed");
    }
}

class Primes
{
    var iter:Iterator<Int>;

    public function new()
    {
        iter = new PrimesIter();
    }

    public function skip(n:Int) : Primes
    {
        iter = new SkipIter(n, iter);
        return this;
    }

    public function take(n:Int) : Primes
    {
        iter = new TakeIter(n, iter);
        return this;
    }

    public function toList() : Array<Int>
    {
        var result:Array<Int> = [];
        for (p in iter) {
            result.push(p);
        }
        return result;
    }
}

class PrimesIter
{
    var n:Int = 0;
    var primesSoFar:Array<Int>;

    static var cache:Map<Int, Bool> = new Map<Int, Bool>();

    public function new()
    {
        primesSoFar = new Array<Int>();
    }

    public function hasNext() : Bool
    {
        return true;
    }

    public function next() : Int
    {
        while (true) {
            n++;
            if (memoized_isPrime(n)) {
                primesSoFar.push(n);
                return n;
            }
        }
    }

    function isPrime(n:Int) : Bool
    {
        if (n <= 0) throw "Invalid argument";
        if (n == 1 || n == 2) return true;
        var i:Int = Math.ceil(n / 2);
        for (i in 1...primesSoFar.length) {
            if (n % primesSoFar[i] == 0) {
                return false;
            }
        }
        return true;
    }

    function memoized_isPrime(n:Int) : Bool
    {
        if (cache[n] == null) {
            cache[n] = isPrime(n);
        }
        return cache[n];
    }
}

class SkipIter<T>
{
    var n:Int;
    var iter:Iterator<T>;

    public function new(n:Int, iter:Iterator<T>)
    {
        this.n = n;
        this.iter = iter;
    }

    public function hasNext() : Bool
    {
        return iter.hasNext();
    }

    public function next() : T
    {
        while (n-- > 0) {
            iter.next();
        }
        return iter.next();
    }
}

class TakeIter<T>
{
    var n:Int;
    var iter:Iterator<T>;

    public function new(n:Int, iter:Iterator<T>)
    {
        this.n = n;
        this.iter = iter;
    }

    public function hasNext() : Bool
    {
        return n > 0 && iter.hasNext();
    }

    public function next() : T
    {
        n--;
        return iter.next();
    }
}
