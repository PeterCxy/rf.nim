import future, asyncdispatch

import rx/core/subscriber

type
  Observable*[T] = object of RootObj
    onSubscribe*: proc(s: Subscriber[T])

# An Observable is an object that emits items to its Subscriber
# when a specific event happens. Several Operators can be applied
# to the Observable to transform it before the final subcription.
# Operators are also implemented as middleware-lile Subscribers.
proc newObservable*[T](subscribe: proc(s: Subscriber[T])): Observable[T] =
  result.onSubscribe = subscribe

proc subscribe*[T](observable: Observable[T], next: proc(x: T) = proc(x: T) = discard,
  complete: proc() = proc() = discard,
  error: proc(e: ref Exception) = proc(e: ref Exception) = discard) =

  observable.onSubscribe(newSubscriber[T](next, complete, error))

# Create an Observable that emits items from a sequence or slice.
proc just*[T](item: seq[T] or Slice[T]): Observable[T] =
  result = newObservable[T](proc(s: Subscriber[T]) =
    for i in item:
      try:
        s.onNext(i)
      except:
        s.onError(getCurrentException())
    s.onComplete()
  )

# Create an Observable that emits the result of a Future when it completes.
# This is a non-blocking operator.
proc just*[T](fut: Future[T]): Observable[T] =
  result = newObservable[T]((s: Subscriber[T]) => (
    fut.callback = proc() =
      if fut.failed:
        s.onError(fut.error)
      else:
        s.onNext(fut.read())
      s.onComplete()
  ))

# Shorthands for `just`
template `~`*[T](item: seq[T] or Slice[T] or Future[T]): expr {.immediate.} =
  just(item)

# Buffered Proxy of subscriber
proc newSubscriberProxy*[T](observable: var Observable[T]): Subscriber[T] =
  var orig: Subscriber[T]
  var subscribed, completed: bool
  var error: ref Exception = nil
  var buf: seq[T] = @[]
  result.onNext = proc(x: T) =
    if not subscribed:
      buf.add(x)
    else:
      orig.onNext(x)
  result.onError = proc(e: ref Exception) =
    if not subscribed:
      error = e
    else:
      orig.onError(e)
  result.onComplete = proc() =
    if not subscribed:
      completed = true
    else:
      orig.onComplete()
  observable.onSubscribe = proc(s: Subscriber[T]) =
    orig = s
    subscribed = true

    if error != nil:
      s.onError(error)

    if completed:
      s.onComplete()

    for i in buf:
      s.onNext(i)
