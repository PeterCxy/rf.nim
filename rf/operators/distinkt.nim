import future
import rf/core/observable, rf/core/subscriber

# `distinkt` is for `distinct`
# suppress duplicate items emitted by an Observable
# `keySelector`: a function that generates a key from an element
#   The key will be compared instead of the item itself
proc distinkt*[T, K](observable: Observable[T], keySelector: (T) -> K): Observable[T] =
  result = newObservable(proc(s: Subscriber[T]) =
    var keys: seq[K] = @[]

    observable.subscribe(
      error = s.onError, complete = s.onComplete,
      next = proc(it: T) =
        var k = keySelector(it)
        if not keys.contains(k):
          s.onNext(it)
          keys.add(k)
    )
  )

proc distinkt*[T](observable: Observable[T]): Observable[T] =
  return observable.distinkt((it: T) => it)

# Only compare emitted items from the source Observable against their immediate predecessors in order to determine whether or not they are distinct.
proc distinktUntilChanged*[T, K](observable: Observable[T], keySelector: (T) -> K): Observable[T] =
  result = newObservable[T](proc(s: Subscriber[T]) =
    var first = true
    var last: K

    observable.subscribe(
      error = s.onError, complete = s.onComplete,
      next = proc(it: T) =
        let k = keySelector(it)
        if first or k != last:
          first = false
          last = k
          s.onNext(it)
    )
  )

proc distinktUntilChanged*[T](observable: Observable[T]): Observable[T] =
  observable.distinktUntilChanged((it: T) => it)

