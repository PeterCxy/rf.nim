import future
import rx/core/observable, rx/core/subscriber

# emit only those items from an Observable that pass a predicate test
proc filter*[T](observable: Observable[T], f: (T) -> bool): Observable[T] =
  result = newObservable[T](proc(s: Subscriber[T]) =
    observable.subscribe(
      next = proc(it: T) =
        if f(it):
          s.onNext(it)
      , error = proc(e: ref Exception) = s.onError(e)
      , complete = proc() = s.onComplete()
    )
  )

# Alias of filter
template where*[T](observable: Observable[T], f: (T) -> bool): expr =
  filter(observable, f)
