import rf/core/observable, rf/core/subscriber
import rf/operators/map, rf/operators/flatMap, rf/operators/filter,
  rf/operators/doOnCompleted, rf/operators/reduce, rf/operators/scan,
  rf/operators/groupBy

when isMainModule:
  import future, asyncdispatch, asyncfile, strutils, httpclient

  just(0..10)
    .where((x: int) => x > 5)
    .map((x: int) => $x & " testmap")
    .toArray()
    .subscribe((x: seq[string]) => echo x)

  just(1..5)
    .reduce((x: int, y: int) => x + y)
    .subscribe((x: int) => echo x)

  just(1..20)
    .groupBy((x: int) => x mod 5)
    .flatMap((it: Observable[int]) => it.toArray())
    .subscribe((it: seq[int]) => echo it)

  just(1..5)
    .scan((x: seq[int], y: int) => (
      var s = if x == nil: @[] else: x;
      s.add(y);
      s
    ))
    .subscribe((x: seq[int]) => echo x)

  just(@["http://example.com", "http://nim-lang.org"])
    .flatMap((url: string) =>
      ~newAsyncHttpClient().request(url))
    .subscribe((resp: Response) => echo resp.body,
      () => echo "complete")
  
  var file1 = openAsync("rf.nim", fmRead)

  just(file1.readAll())
    .subscribe((x: string) => (
      file1.close();
      echo x
    ))

  just(@["rf.nimble", "rf.nim"])
    .flatMap((it: string) => (
      let file2 = openAsync(it);
      just(file2.readAll()).doOnCompleted(() => file2.close) # Do not forget to close it!
    ))
    .map((it: string) => it.splitLines)
    .spread()
    .map((it: string) => "[" & it & "]")
    .subscribe((x: string) => (
      echo x
    ), () => echo "complete")

  runForever() # Necessary for async procedures
