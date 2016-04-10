import future, asyncdispatch
import rf/core/observable, rf/core/subscriber

# flatMap-related operators
# transform the items emitted by an Observable into Observables, then flatten the emissions from those into a single Observable
proc flatMap*[T, I](observable: Observable[T], f: (T) -> Observable[I]): Observable[I] =
  result = newObservable[I](proc(s: Subscriber[I]) =
    var count = 0
    var completeCount = 0
    var parentCompleted = false

    proc checkComplete() =
      if parentCompleted and (count == completeCount):
        s.onComplete()

    observable.subscribe(
      next = proc(x: T) =
        count += 1
        let o2 = f(x)

        o2.subscribe(
          next = proc(y: I) =
            s.onNext(y)
          , complete = proc() =
            completeCount += 1
            checkComplete()
          , error = s.onError
        )
      , complete = proc() =
        parentCompleted = true
        checkComplete()
      , error = s.onError
    )
  )

# Spread emitted sequences
# Shorthand of a specific flatMap operation
proc spread*[T](observable: Observable[seq[T]]): Observable[T] =
  return observable.flatMap((it: seq[T]) => ~it)
