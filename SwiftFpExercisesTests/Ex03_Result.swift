import Foundation
import UIKit
import XCTest

/*
EXERCISE
========

Result represents the result of an operation that can fail with some Error E, or succeed with a Value of type A.
See the `success` and `failure` functions for easy ways to create these values.

Uncomment the code-block marked "TODO: Uncomment..." as prompted by `testUncommentTheCodeForThisExercise()`, then
implement Result.map and Result.flatMap.
 
ResultTests has some examples of how these functions can be used.
*/
public enum Result<E,A> : CustomStringConvertible {
    case Error(E)
    case Value(A)
    
    // This function is to give an example of how to pattern match on Result values.
    // You don't have to use it and can safely ignore it.
    // ---------------------------
    // This will transform any Result into a value of some type B.
    // It works by handling each case of Result. If we tell it how to
    // convert an Error to type B, and a Value to type B, then we can convert
    // any Result to type B.
    public func reduce<B>(_ onError: (E) -> B, _ onValue: (A) -> B) -> B {
        switch self {
        case .Error(let e): return onError(e)
        case .Value(let v): return onValue(v)
        }
    }
    
    // Helper property and functions for test assertions. You can safely ignore these.
    public var description : String {
        return self.reduce({ e in "Error: \(e)" }, { v in "Value: \(v)" })
    }
    public func getValue() -> A? {
        return self.reduce({ _ in .none }, { a in .some(a) })
    }
    public func getError() -> E? {
        return self.reduce({ e in .some(e) }, { _ in .none })
    }
}

func success<E,A>(_ value : A) -> Result<E,A> {
    return .Value(value)
}
func failure<E,A>(_ err : E) -> Result<E,A> {
    return .Error(err)
}

class Ex03_Result: XCTestCase {
    func testUncommentTheCodeForThisExercise() {
        let areTestsUncommented = true // *** TODO ***
        XCTAssert(
            areTestsUncommented,
            "TODO: uncomment the block of code and tests in Ex03_Result.swift, then update areTestsUncommented in this test and continue Ex03.")
    }
}

// TODO: Uncomment the code below (to the end of the file) and get the tests to pass:
// ============================================================================================
extension Result {
    public func map<B>(_ f : (A) -> B) -> Result<E,B> {
        // *** TODO ***
        return flatMap { success(f($0)) }
    }

    public func flatMap<B>(_ f : (A) -> Result<E,B>) -> Result<E, B> {
        // *** TODO ***
        return reduce({ failure($0) }, { f($0) })
    }
}

class Ex03_ResultExamples: XCTestCase {
    func testMapOverValue() {
        let result : Result<String,Int> = success(41).map({ x in x + 1 })

        XCTAssert(result.getValue() == .some(42), result.description)
    }
    func testMapOverError() {
        let result : Result<String,Int> = failure("Something went wrong").map({ x in x + 1 })

        XCTAssert(result.getError() == .some("Something went wrong"), result.description)
    }

    func parseInt(_ s : String) -> Result<String, Int> {
        switch Int(s) {
        case .some(let x): return success(x)
        case .none: return failure("Could not convert '\(s)' to int")
        }
    }

    func between(min : Int, max : Int) -> (Int) -> Result<String, Int> {
        return { x in
            if x >= min && x <= max {
                return success(x)
            } else {
                return failure("Expected between \(min) and \(max), but was \(x)")
            }
        }
    }

    func parseIntBetweenZeroAndTen(_ s : String) -> Result<String,Int> {
        return parseInt(s).flatMap(between(min: 0, max: 10))
    }

    func testFlatMap() {
        let validResult = parseIntBetweenZeroAndTen("5")
        let invalidIntResult = parseIntBetweenZeroAndTen("lots")
        let outOfRangeResult = parseIntBetweenZeroAndTen("42")

        XCTAssert(validResult.getValue() == .some(5), validResult.description)
        XCTAssert(invalidIntResult.getError() == .some("Could not convert 'lots' to int"), invalidIntResult.description)
        XCTAssert(outOfRangeResult.getError() == .some("Expected between 0 and 10, but was 42"), outOfRangeResult.description)
    }

    // *** TODO ***
    // Write a function that attempts to parse an even number between 0 and 100 from a string. It should pass `testEvenFrom0To100()`.
    // HINTS:
    // - Use parseIntBetweenZeroAndTen() as an example to help you get started.
    // - Consider writing a helper function `even : Int -> Result<String, Int>`. For odd numbers this should report a `failure()` with
    //   the message expected by `testEvenFrom0To100`.

    func even(_ i: Int) -> Result<String, Int> {
        if i%2==0 {
            return success(i)
        } else {
            return failure("Expected even number, but was \(i)")
        }
    }
    
    func evenFrom0To100(_ s : String) -> Result<String, Int> {
        // Sample answer:
        //return parseInt(s).flatMap(even).flatMap(between(min: 0, max: 100))
        
        // EXTENSION 1 sample answer:
        //return parseInt(s)
        //    >>- even
        //    >>- between(min: 0, max: 100)
        
        // EXTENSION 2 sample answer:
        let parse = parseInt >=> even >=> between(min: 0, max: 100)
        return parse(s)
    }

    func testEvenFrom0To100() {
        let validResult = evenFrom0To100("42")
        let invalidIntResult = evenFrom0To100("lots")
        let outOfRangeResult = evenFrom0To100("102")
        let oddResult = evenFrom0To100("43")

        XCTAssert(validResult.getValue() == .some(42), validResult.description)
        XCTAssert(invalidIntResult.getError() == .some("Could not convert 'lots' to int"), invalidIntResult.description)
        XCTAssert(outOfRangeResult.getError() == .some("Expected between 0 and 100, but was 102"), outOfRangeResult.description)
        XCTAssert(oddResult.getError() == .some("Expected even number, but was 43"), oddResult.description)
        // Note: these tests don't specify what needs to be checked first: evenness or range. Either way is fine for this exercise.
    }
}
// ============================================================================================

// EXTENSIONS:
// 1. Create a function `>>-` which is an alias for Result.flatMap (the operator is already declared in Operators.swift).
//        >>- : (Result<E,A>, A -> Result<E,B>) -> Result<E,B>
//    Re-write evenFrom0To100 using this operator.
//
// 2. Create a function `>=>` (the operator is already declared in Operators.swift):
//        >=> : (A -> Result<E,B>, B -> Result<E,C>) -> (A -> Result<E,C>)
//    You will probably need to mark these closures as @escaping to keep the Swift compiler happy.
//    Re-write evenFrom0To100 using this operator.

func >>-<E,A,B>(_ result: Result<E,A>, _ f : (A) -> Result<E,B>) -> Result<E,B> {
    return result.flatMap(f)
}

func >=><E,A,B,C>(_ f: @escaping (A) -> Result<E,B>, _ g : @escaping (B) -> Result<E,C>) -> (A) -> Result<E,C> {
    return { a in f(a).flatMap(g) }
}
