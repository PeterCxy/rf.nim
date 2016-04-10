import future
import rf/core/observable, rf/core/subscriber

# apply a function to each item emitted by an Observable, sequentially, and emit each successive value
proc scan*[T, I](observable: Observable[T], f: (I, T) -> I): Observable[I] =
  result = newObservable[I](proc(s: Subscriber[I]) =
    var last: I
    observable.subscribe(
      error = s.onError, complete = s.onComplete
      , next = proc(it: T) =
        last = f(last, it)
        s.onNext(last)
    )
  )
