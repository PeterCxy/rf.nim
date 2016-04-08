import rx/core/observable, rx/core/subscriber
import rx/operators/map, rx/operators/flatMap, rx/operators/filter,
  rx/operators/doOnCompleted

when isMainModule:
  import future, asyncdispatch, asyncfile, strutils, httpclient

  just(0..10)
    .where((x: int) => x > 5)
    .map((x: int) => $x & " testmap")
    .subscribe((x: string) => echo x)

  just(@["http://example.com", "http://nim-lang.org"])
    .flatMap((url: string) =>
      ~newAsyncHttpClient().request(url))
    .subscribe((resp: Response) => echo resp.body,
      () => echo "complete")
  
  var file1 = openAsync("RxNim.nim", fmRead)

  just(file1.readAll())
    .subscribe((x: string) => (
      file1.close();
      echo x
    ))

  just(@["RxNim.nimble", "RxNim.nim"])
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
