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
