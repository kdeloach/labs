class Main
{
    public static function main()
    {
        var started:Float;
        var elapsed:Float;

        elapsed = 0;
        started = Date.now().getTime();
        Primes.first(2000);
        elapsed = Date.now().getTime() - started;
        trace(elapsed + " MS elapsed");

        elapsed = 0;
        started = Date.now().getTime();
        Primes.first(2000);
        elapsed = Date.now().getTime() - started;
        trace(elapsed + " MS elapsed");
    }
}

class Primes
{
    public static function first(n:Int) : Array<Int>
    {
        var result:Array<Int> = [];
        var iter:PrimesIter = new PrimesIter();
        for (i in 1...n) {
            result.push(iter.next());
        }
        return result;
    }
}

class PrimesIter
{
    var n:Int = 0;
    static var cache:Map<Int, Bool> = new Map<Int, Bool>();

    public function new()
    {
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
                return n;
            }
        }
    }

    function isPrime(n:Int) : Bool
    {
        if (n <= 0) throw "Invalid argument";
        if (n == 1 || n == 2) return true;
        var i:Int = n - 1;
        while (i > 1) {
            if (n % i == 0) {
                return false;
            }
            i--;
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
