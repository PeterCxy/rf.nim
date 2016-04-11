when compileOption("threads"):
  import asyncdispatch, threadpool, sequtils, future

  type
    Task = proc(): bool
  var tasks: seq[Task] = @[]

  proc loopForever*() =
    while true:
      poll()
      tasks = tasks.filter((t: Task) => not t())

  # Convert a FlowVar to a Future.
  # ONLY FOR REALLY REALLY LONG CALCULATION TASKS
  # Do not use this for I/O operations as it requires a gcsafe proc.
  # If you want to use this, please call loopForever() instead of runForever()
  proc flowToFuture*[T](flow: FlowVar[T]): Future[T] =
    var fut = newFuture[T]()
    var task = proc(): bool =
      if flow.isReady and not fut.finished:
        fut.complete(^flow)
        return true
      else:
        return fut.finished
    tasks.add task
    return fut

  # Shorthand for flowToFuture + spawn
  template spawnAsync*(call: expr): expr {.immediate.} =
    flowToFuture spawn call
