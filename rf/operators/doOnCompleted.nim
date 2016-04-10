import future
import rf/core/observable, rf/core/subscriber

# The doOnCompleted operator registers an Action which will be called if the resulting Observable terminates normally, calling onCompleted.
proc doOnCompleted*[T](observable: Observable[T], f: () -> void): Observable[T] =
  result = newObservable[T](proc(s: Subscriber[T]) =
    observable.subscribe(
      next = s.onNext, error = s.onError, complete = proc() =
        f()
        s.onComplete()
    )
  )
