import future, asyncdispatch
import rx/core/observable, rx/core/subscriber

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
        var o2: Observable[I]
        try:
          o2 = f(x)
        except:
          s.onError(getCurrentException())

        o2.subscribe(
          next = proc(y: I) =
            s.onNext(y)
          , complete = proc() =
            completeCount += 1
            checkComplete()
          , error = proc(e: ref Exception) = s.onError(e)
        )
      , complete = proc() =
        parentCompleted = true
        checkComplete()
      , error = proc(e: ref Exception) = s.onError(e)
    )
  )
