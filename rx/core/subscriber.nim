import rx/core/observable

type
  Subscriber*[T] = object of RootObj
    onNext*: proc(x: T)
    onError*: proc(e: ref Exception)
    onComplete*: proc()

proc newSubscriber*[T](next: proc(x: T), complete: proc(), error: proc(e: ref Exception)): Subscriber[T] =
  var res: Subscriber[T]
  res.onNext = proc(x: T) =
    try:
      next(x)
    except:
      res.onError(getCurrentException())
  res.onComplete = complete
  res.onError = error
  return res
