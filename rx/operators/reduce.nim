import future
import rx/core/observable, rx/core/subscriber

# apply a function to each item emitted by an Observable, sequentially, and emit the final value
proc reduce*[T, I](observable: Observable[T], seed: I, f: (I, T) -> I): Observable[I] =
  result = newObservable[I](proc(s: Subscriber[I]) =
    var last = seed
    observable.subscribe(
      error = s.onError
      , next = proc(it: T) =
        last = f(last, it)
      , complete = proc() =
        s.onNext(last)
        s.onComplete()
    )
  )

proc reduce*[T, I](observable: Observable[T], f: (I, T) -> I): Observable[I] =
  var seed: I
  result = reduce(observable, seed, f)

# Variant of reduce() that uses a mutable data structure as a seed
proc collect*[T, I](observable: Observable[T], seed: var I, f: (x: var I, y: T) -> void): Observable[I] =
  var collection = seed
  result = newObservable[I](proc(s: Subscriber[I]) =
    observable.subscribe(
      error = s.onError
      , next = proc(it: T) =
        f(collection, it)
      , complete = proc() =
        s.onNext(collection)
        s.onComplete()
    )
  )

# Shorthand of collect() that collects items into a sequence
proc toArray*[T](observable: Observable[T]): Observable[seq[T]] =
  var s: seq[T] = @[]
  result = observable.collect(s, (x: var seq[T], y: T) => x.add(y))
