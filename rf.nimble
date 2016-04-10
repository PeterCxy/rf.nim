# Package

version       = "0.1.0"
author        = "Peter Cai"
description   = "ReactiveX-like reactive programming library designed for Nim"
license       = "MIT"

# Dependencies

requires "nim >= 0.13.0"

task debug, "debug rf.nim":
  --run
  setCommand "c", "rf"
  switch "o", "rf.debug"
