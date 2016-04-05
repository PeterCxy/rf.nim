import rx/core/observable

type
  Subscriber*[T] = object of RootObj
    onNext*: proc(x: T)
    onError*: proc(e: ref Exception)
    onComplete*: proc()

proc newSubscriber*[T](next: proc(x: T), complete: proc(), error: proc(e: ref Exception)): Subscriber[T] =
  result.onNext = next
  result.onComplete = complete
  result.onError = error
