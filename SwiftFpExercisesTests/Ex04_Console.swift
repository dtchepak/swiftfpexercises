import Foundation
import UIKit
import XCTest

// INTRODUCTION
// ============

// Console<T> is a type representing programs that can interact with the console (i.e. read from stdin, write to stdout),
// to produce a value of some type T.
//
// A Console<()> program is one that returns void ( a.k.a. Unit, written "()" ).
//
// The definition of Console<T> is at the end of this snippet, but for this exercise we only need to know how to create
// and combine Console<T> programs (we don't need to know how any of these things are implemented).
//
// We can combine Console<T> programs using the `map`, `flatMap`, and `then` instance methods of Console<T>:
//
//   func flatMap<B>(f : T -> Console<B>) -> Console<B>
//   func map<B>(f: T -> B) -> Console<B>
//   func then<B>(next : Console<B>) -> Console<B>
//
// FlatMapPattern.md has some tips for using flatMap for the Parser exercise, but it can also be applied to this exercise.
//
// We can create instances of Console<T> programs using the following functions:

// Return a program that reads a line from the console and produces a string
public func readLine() -> Console<String> {
    return ConsoleOperation<String>.ReadLine({ s in s }).toConsole()
}
// Return a program that writes a line to the console
public func writeLine(s : String) -> Console<()> {
    return ConsoleOperation<()>.WriteLine(s, Box(())).toConsole()
}
// Return a program that produces the given value
public func pure<T>(t : T) -> Console<T> {
    return Console(t)
}
// Return a program that does nothing
public func noop() -> Console<()> {
    return pure(())
}

// Finally, we can run a Console<T> program using `interpret` and an implementation of the side-effecty `ConsoleIO` protocol.
// For the tests, we'll be using a a `TestIO` implementation to provide fake stdin inputs, and to record all output.
// These are defined at the end of the exercises if you're interested.

// The ConsoleExamples class have a number of exercises defined. The aim is to tackle each exercise in order by filling out the
// <TODO> ... </TODO> sections. (Don't edit stuff outside the <TODO /> tags.)

// EXERCISES
// =========
class Ex04_Console : XCTestCase {
    
    // Exercise 0: create a program that writes "Hello World!" to the console.
    // Set the `program` variable using one of the creation functions above.
    func testHelloWorld() {
        let io = TestIO()
        
        // <TODO>
        let program : Console<()> = writeLine("Hello World!")
        // </TODO>
        
        interpret(io, program: program)
        let out = io.allOutput()
        XCTAssert(out == ["Hello World!"], out.description)
    }
    
    // Exercise 1: create a program that reads from stdin. Assign that program to the `program` variable.
    func testReadFromStdIn() {
        let io = TestIO()
        io.addToStdIn("monads are yucky")
        
        // <TODO>
        let program : Console<String> = readLine()
        // </TODO>
        
        let result = interpret(io, program: program)
        XCTAssert(result == "monads are yucky", result)
        
    }
    
    // Exercise 2: create a program that will write a message prompt to stdout, then read the input entered.
    // Once implemented `testPrompt()` should pass.
    //
    // HINT: we need to create two console programs, one for writing to stdout, the other to read a line from stdin.
    // Then we need to use one of the combining functions (`flatMap`, `map`, or `then`) to get us the final program.
    // The types of these functions are shown in the comment at the top of this file.
    func prompt(message :String) -> Console<String> {
        // <TODO>
        return writeLine(message).then(readLine())
        // </TODO>
    }
    
    func testPrompt() {
        let io = TestIO()
        io.addToStdIn("blue")
        
        let result = interpret(io, program: prompt("What is your favourite colour?"))
        
        let out = io.allOutput()
        XCTAssert(result == "blue", result)
        XCTAssert(out == ["What is your favourite colour?"], out.description);
    }
    
    // Exercise 3: prompt the user to answer a question, then write the respnse to stdout.
    // HINT: use `prompt`, and one of the combining functions (`flatMap`, `map`, or `then`)
    func testPromptAndWriteAnswerToConsole() {
        let io = TestIO()
        let question = "what is your quest?"
        io.addToStdIn("to learn monads")
        
        // <TODO>
        let program = prompt(question).flatMap(writeLine)
        // </TODO>
        
        interpret(io, program: program)
        let out = io.allOutput()
        XCTAssert(out == ["what is your quest?", "to learn monads"], out.description)
    }
    
    // Exercise 4: create a program that will write a prompt to std out, then read what is entered to stdin.
    // If it is a valid integer, the program should return that, else it should write "Invalid int" and prompt again.
    // Both `testReadInt()` and `testReadIntKeepsPromptingUntilItGetsAnInt()` should pass (although you may want to focus on
    // parsing the former first before going on to the latter.)
    //
    // HINTS:
    // - Use `prompt` to prompt and get the string entered (remember, it will write a prompt AND read the response)
    // - Use `s.toInt()` to attempt to convert the string `s` to an `Int` (returns an `Optional<Int>`)
    // - You can call `self.readInt` recursively
    // - `pure(x)` will return a Console program that produces the value `x`
    func readInt(promptMsg : String) -> Console<Int> {
        // <TODO>
        return prompt(promptMsg)
            .flatMap( { x in switch x.toInt() {
                                case .None: return writeLine("Invalid int").then(self.readInt(promptMsg))
                                case .Some(let i): return pure(i)
                            }
            })
        // </TODO>
    }
    
    func testReadInt() {
        let io = TestIO()
        io.addToStdIn("42")
        
        let result = interpret(io, program: readInt("Enter int"))
        
        let out = io.allOutput()
        
        XCTAssert(result == 42, result.description)
        XCTAssert(out == ["Enter int"], out.description)
    }
    
    func testReadIntKeepsPromptingUntilItGetsAnInt() {
        let io = TestIO()
        io.addToStdIn("no")
        io.addToStdIn("i don't want to")
        io.addToStdIn("12")
        
        let result = interpret(io, program: readInt("Enter int"))
        
        let out = io.allOutput()
        
        XCTAssert(result == 12, result.description)
        XCTAssert(out == ["Enter int", "Invalid int", "Enter int", "Invalid int", "Enter int"], out.description)
    }
    
    // Exercise 5: Create a program that:
    // - reads an integer from stdin after prompting "Enter X:"
    // - reads an integer from stdin after prompting "Enter Y:"
    // - writes the result to stdout
    //
    // HINT: use `readInt`, `flatMap` and `writeLine`
    func testCalculator() {
        let enteredX = Int(arc4random_uniform(100))
        let enteredY = Int(arc4random_uniform(100))
        let sumXY = enteredX + enteredY
        let io = TestIO()
        
        io.addToStdIn(enteredX.description)
        io.addToStdIn(enteredY.description)
        
        // <TODO>
        let program : Console<()> =
        readInt("Enter X:")
        .flatMap({ x in self.readInt("Enter Y:")
        .flatMap({ y in writeLine( (x+y).description ) }) })
        // </TODO>
        
        interpret(io, program: program)
        let out = io.allOutput()
        XCTAssert(out == ["Enter X:", "Enter Y:", sumXY.description], out.description)
    }
}

// END EXERCISES. HOORAY!

/* **************** */
/* Supporting types */
/* **************** */


// Some info on Console and other supporting types:
//   http://www.davesquared.net/2013/11/freedom-from-side-effects-fsharp.html

public class Console<T> {
    // <BOILERPLATE>
    let op : Either<T, ConsoleOperation<Console<T>>>
    init(_ pure :T) { self.op = .Left(Box(pure)) }
    init(_ op : ConsoleOperation<Console<T>>) { self.op = .Right(Box(op))  }
    func getOp() -> Either<T,ConsoleOperation<Console<T>>> { return self.op }
    // </BOILERPLATE>
    
    
    // USEFUL STUFF WE CAN DO WITH CONSOLE PROGRAMS
    
    // Use this operation's output to get the next operation to run.
    public func flatMap<B>(f : T -> Console<B>) -> Console<B> {
        return op.reduce(
            onLeft: { t in f(t) },
            onRight: { (c:ConsoleOperation<Console<T>>) in
                let cb : ConsoleOperation<Console<B>> = c.map({ t in t.flatMap(f) })
                return Console<B>(cb)
        })
    }
    
    // Ignore this operation's output and use the next operation.
    public func then<B>(next : Console<B>) -> Console<B> {
        return self.flatMap({ _ in next })
    }
    
    // Modify this operation to produce a value of type B.
    public func map<B>(f: T -> B) -> Console<B> {
        return flatMap({ t in Console<B>(f(t)) })
    }
}

public enum Either<L,R> {
    case Left(Box<L>)
    case Right(Box<R>)
    public func reduce<A>(#onLeft: L -> A, onRight: R->A) -> A {
        switch self {
        case .Left(let l): return onLeft(l.value)
        case .Right(let r): return onRight(r.value)
        }
    }
}
public enum ConsoleOperation<T> {
    case WriteLine (String, Box<T>)
    case ReadLine (String -> T)
    public func map<B>(f : T -> B) -> ConsoleOperation<B> {
        switch self {
        case .WriteLine(let (s, t)): return .WriteLine(s, Box(f(t.value)))
        case .ReadLine(let r): return .ReadLine( { s in f(r(s)) } )
        }
    }
    public func toConsole() -> Console<T> {
        return Console(self.map({ x in Console<T>(x) }))
    }
}

protocol ConsoleIO {
    func readStdIn() -> String;
    func writeStdOut(s : String) -> ();
}

class TestIO : ConsoleIO {
    var input : [String] = []
    var output : [String] = []
    
    func addToStdIn(s : String) {
        self.input.append(s)
    }
    func readStdIn() -> String {
        if input.isEmpty {
            return ""
        } else {
            return self.input.removeAtIndex(0)
        }
    }
    func allOutput() -> [String] { return self.output }
    func lastOutput() -> String? { return self.output.last }
    func writeStdOut(s :String) {
        self.output.append(s)
    }
}

func interpret<T>(io : ConsoleIO, #program : Console<T>) -> T {
    let op = program.getOp()
    switch op {
    case .Left(let l) : return l.value
    case .Right(let r):
        switch r.value {
        case .WriteLine(let (s, next)):
            io.writeStdOut(s)
            return interpret(io, program: next.value)
        case .ReadLine(let f):
            let s = io.readStdIn()
            return interpret(io, program: f(s))
        }
    }
}


