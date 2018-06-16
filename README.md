
This is a collection of ad hoc exercises written to illustrate some FP concepts in Swift, which I've tried to assemble into something relatively cohesive.

The original exercises were designed to be done with guidance from an instructor, so if you get stuck it is not your fault! Any time you run into an exercise that doesn't make sense from the context/comments alone or seems like too big a leap then please leave feedback via [Github Issues](https://github.com/dtchepak/swiftfpexercises/issues).

Requires Swift 4+/Xcode 9.

* See [swift-2 branch](https://github.com/dtchepak/swiftfpexercises/tree/swift-2) for Swift 2+/Xcode 7+ version.
* See [swift-1.2 branch](https://github.com/dtchepak/swiftfpexercises/tree/swift-1.2) for the original exercises targeting Swift 1.2.

# Instructions

The SwiftFpExercisesTests folder in the project contains a number of exercises, starting with `Ex01_Map.swift`. The aim is to fill in all the TODO comments and calls with valid implementations. Each time a TODO is completed one or more of the tests should start passing. Once all the TODOs are gone and the tests are passing then move on to the next exercise.

Some of the exercises also contain one or more EXTENSION comments. These are additional tasks thrown in for fun⁕, usually quite abruptly and with very little guidance, for those who'd like to try something a bit different. While the main exercises are intended to be completed in order, the extensions can safely be skipped. 

⁕ YMMV :)

# Swift Parser Exercises
The Parser combinators exercise in this repository is a port of an [exercise by Tony Morris/NICTA written in Haskell](https://github.com/NICTA/course/blob/af3e945d5eadcaf0a11a462e2ef7f5378b71d7f7/src/Course/Parser.hs). Please direct all credit to that original project, and attribute any mistakes to me.

The licence/copyright information for the original exercises is [included below](#licence-for-original-parser-exercises).

## Licence for original Parser exercises

[Licence source](https://github.com/NICTA/course/blob/af3e945d5eadcaf0a11a462e2ef7f5378b71d7f7/etc/LICENCE)

```
Copyright 2010-2013 Tony Morris
Copyright 2012-2015 National ICT Australia Limited 2012-2014
Copyright 2012      James Earl Douglas
Copyright 2012      Ben Sinclair

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. Neither the name of the author nor the names of his contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE.
```
