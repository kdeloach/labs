class Main
{
    public static function main()
    {
        var start:Float = Date.now().getTime();
        trace(Primes.first(20));
        var elapsed = Date.now().getTime() - start;
        trace(elapsed + " MS elapsed");
    }
}

class Primes
{
    public static function first(n:Int) : Array<Int>
    {
        var result:Array<Int> = [];
        var iter:PrimesIter = new PrimesIter();
        for (i in 0...n) {
            result.push(iter.next());
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

    public function hasNext()
    {
        return true;
    }

    public function next()
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
