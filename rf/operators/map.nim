import future, asyncdispatch
import rf/core/observable, rf/core/subscriber

# Map operators

# X -> Y for every emitted item
proc map*[T, I](observable: Observable[T], f: (T) -> I): Observable[I] =
  result = newObservable[I](proc(s: Subscriber[I]) =
    observable.subscribe(
      next = proc(it: T) =
        s.onNext(f(it))
      , error = s.onError
      , complete = s.onComplete
    )
  )
