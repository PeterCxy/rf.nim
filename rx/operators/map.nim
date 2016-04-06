import future, asyncdispatch
import rx/core/observable, rx/core/subscriber

# Map operators

# X -> Y for every emitted item
proc map*[T, I](observable: Observable[T], f: (T) -> I): Observable[I] =
  result = newObservable[I](proc(s: Subscriber[I]) =
    observable.subscribe(
      next = proc(it: T) =
        try:
          s.onNext(f(it))
        except:
          s.onError(getCurrentException())
      , error = proc(e: ref Exception) = s.onError(e)
      , complete = proc() = s.onComplete()
    )
  )

# Do something on complete but keep it an Observable. e.g. close a file after a flatMap operation
# It is actually kind of map, so I put it here.
# Do not subscribe directly because an Observable accepts only one Subscriber.
proc then*[T](observable: Observable[T], f: () -> void): Observable[T] =
  result = newObservable[T](proc(s: Subscriber[T]) =
    observable.subscribe(
      next = s.onNext, error = s.onError, complete = proc() =
        f()
        s.onComplete()
    )
  )
