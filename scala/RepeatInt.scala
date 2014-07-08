import scala.language.implicitConversions

class RepeatInt(n: Int) {
  def times(fn: => Any) = for(i <- 0 until n) fn
  def times(fn: Int => Any) = for(i <- 0 until n) fn(i)
}

implicit def intToRepeatInt(n: Int) = new RepeatInt(n)

2 times {
  println("test")
}

3 times { i: Int =>
  println(if (i % 2 == 0) "foo" else "bar")
}
