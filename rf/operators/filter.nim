import future
import rf/core/observable, rf/core/subscriber

# emit only those items from an Observable that pass a predicate test
proc filter*[T](observable: Observable[T], f: (T) -> bool): Observable[T] =
  result = newObservable[T](proc(s: Subscriber[T]) =
    observable.subscribe(
      next = proc(it: T) =
        if f(it):
          s.onNext(it)
      , error = s.onError
      , complete = s.onComplete
    )
  )

# Alias of filter
template where*[T](observable: Observable[T], f: (T) -> bool): expr =
  filter(observable, f)
