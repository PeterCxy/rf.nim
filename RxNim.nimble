# Package

version       = "0.1.0"
author        = "Peter Cai"
description   = "ReactiveX in Nim"
license       = "MIT"

# Dependencies

requires "nim >= 0.13.0"

task debug, "debug RxNim":
  --run
  setCommand "c", "RxNim"
