rf.nim
---
A ReactiveX-like reactive programming library for Nim.

This is under heavy development for now.

Most of the concepts come from [ReactiveX](http://reactivex.io).
But this is not a complete implementation of the ReactiveX API in Nim. It implements a subset of ReactiveX's APIs.

Some of the ReactiveX functions are not implemented due to the limitations of the Nim language or because it is unncessary for Nim.
For details on the Observable and the Operators, see the `ReactiveX` website above.

What is missing:

- Scheduler
- Subject
- Single
- Some of the operators

What will not be implemented:

- Multi-thread schedulers (I'd prefer depending on the `asyncdispatch` module)

What needs implementation:

- The complete set of operators provided by ReactiveX
- Subject
