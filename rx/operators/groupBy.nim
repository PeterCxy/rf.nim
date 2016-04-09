import future
import rx/core/observable, rx/core/subscriber

# divide an Observable into a set of Observables that each emit a different subset of items from the original Observable
proc groupBy*[T, K, I](observable: Observable[T], keySelector: (T) -> K,
  elemSelector: (T) -> I): Observable[Observable[I]] =

  result = newObservable[Observable[I]](proc(s: Subscriber[Observable[I]]) =
    var obs: seq[tuple[key: K, val: Subscriber[I]]] = @[]

    proc searchOrAdd(key: K): Subscriber[I] =
      for i in obs:
        if i.key == key:
          return i.val
      var o = newObservable[I](nil)
      result = newSubscriberProxy(o)
      obs.add((key, result))
      s.onNext(o)

    observable.subscribe(
      error = s.onError, next = proc(it: T) =
        let key = keySelector(it)
        let sub = searchOrAdd(key)
        sub.onNext(elemSelector(it))
      , complete = proc() =
        for i in obs:
          i.val.onComplete()
        s.onComplete()
    )
  )

# Shorthand: without elemSelector
proc groupBy*[T, K](observable: Observable[T], keySelector: (T) -> K): Observable[Observable[T]] {.inline.} =
  return groupBy(observable, keySelector, (x: T) => x)
