import Foundation
import UIKit
import XCTest

/*
EXERCISE
========

Result represents the result of an operation that can fail with some Error E, or succeed with a Value of type A.
See the `success` and `failure` functions for easy ways to create these values.
(Ignore the Box thing, it is to help the compiler deal with both primitive and non-primitive types, and will no longer be required as of Swift 2).

Uncomment the code-block marked "TODO: Uncomment", then implement Result.map and Result.flatMap. ResultTests has some examples of how these can be used.
*/
public enum Result<E,A> : Printable {
    case Error(Box<E>)
    case Value(Box<A>)
    
    // This function is to give an example of how to pattern match on Result values.
    // You don't have to use it and can safely ignore it.
    // ---------------------------
    // This will transform any Result into a value of some type B.
    // It works by handling each case of Result. If we tell it how to
    // convert an Error to type B, and a Value to type B, then we can convert
    // any Result to type B.
    public func reduce<B>(onError: E -> B, _ onValue: A -> B) -> B {
        switch self {
        case .Error(let e): return onError(e.value)
        case .Value(let v): return onValue(v.value)
        }
    }
}

func success<E,A>(value : A) -> Result<E,A> {
    return .Value(Box(value))
}
func failure<E,A>(err : E) -> Result<E,A> {
    return .Error(Box(err))
}

// TODO: Uncomment code block below and get the tests to pass:
// ============================================================================================
//extension Result {
//    public func map<B>(f : A -> B) -> Result<E,B> {
//        // *** TODO ***
//        fatalError("*** TODO ***");
//    }
//    
//    public func flatMap<B>(f : A -> Result<E,B>) -> Result<E, B> {
//        // *** TODO ***
//        fatalError("*** TODO ***");
//    }
//}
//
//
//class Ex03_ResultExamples: XCTestCase {
//    func testMapOverValue() {
//        let result : Result<String,Int> = success(41).map({ x in x + 1 })
//        
//        XCTAssert(result.getValue() == .Some(42), result.description)
//    }
//    func testMapOverError() {
//        let result : Result<String,Int> = failure("Something went wrong").map({ x in x + 1 })
//        
//        XCTAssert(result.getError() == .Some("Something went wrong"), result.description)
//    }
//    
//    func parseInt(s : String) -> Result<String, Int> {
//        switch s.toInt() {
//        case .Some(let x): return success(x)
//        case .None: return failure("Could not convert '\(s)' to int")
//        }
//    }
//
//    func between(#min : Int, max :Int)(x : Int) -> Result<String, Int> {
//        if x >= min && x <= max {
//            return success(x)
//        } else {
//            return failure("Expected between \(min) and \(max), but was \(x)")
//        }
//    }
//    
//    func parseIntBetweenZeroAndTen(s : String) -> Result<String,Int> {
//        return parseInt(s).flatMap(between(min: 0, max: 10))
//    }
//    
//    func testFlatMap() {
//        let validResult = parseIntBetweenZeroAndTen("5")
//        let invalidIntResult = parseIntBetweenZeroAndTen("lots")
//        let outOfRangeResult = parseIntBetweenZeroAndTen("42")
//        
//        XCTAssert(validResult.getValue() == .Some(5), validResult.description)
//        XCTAssert(invalidIntResult.getError() == .Some("Could not convert 'lots' to int"), invalidIntResult.description)
//        XCTAssert(outOfRangeResult.getError() == .Some("Expected between 0 and 10, but was 42"), outOfRangeResult.description)
//    }
//    
//    //*** TODO ***
//    //Using testFlatMap() as an example, write a function that attempts to parse an even number between 0 and 100 from a string.
//    //Consider writing a function `even : Int -> Result<String, Int>` to help.
//    func evenFrom0To100(s : String) -> Result<String, Int> {
//        return failure("*** TODO ***");
//    }
//    
//    func testEvenFrom0To100() {
//        let validResult = evenFrom0To100("42")
//        let invalidIntResult = evenFrom0To100("lots")
//        let outOfRangeResult = evenFrom0To100("102")
//        let oddResult = evenFrom0To100("43")
//        
//        XCTAssert(validResult.getValue() == .Some(42), validResult.description)
//        XCTAssert(invalidIntResult.getError() == .Some("Could not convert 'lots' to int"), invalidIntResult.description)
//        XCTAssert(outOfRangeResult.getError() == .Some("Expected between 0 and 100, but was 102"), outOfRangeResult.description)
//        XCTAssert(oddResult.getError() == .Some("Expected even number, but was 43"), oddResult.description)
//        // Note: these tests don't specify what needs to be checked first: evenness or range. Either way is fine for this exercise.
//    }
//  
//    // EXTENSIONS:
//    // 1. Create a function `>>-` which is an alias for Result.flatMap (the operator is already declared in Operators.swift).
//    //        >>- : (Result<E,A>, A -> Result<E,B>) -> Result<E,B>
//    //    Re-write evenFrom0To100 using this operator.
//    //
//    // 2. Create a function `>=>` (the operator is already declared in Operators.swift):
//    //        >=> : (A -> Result<E,B>, B -> Result<E,C>) -> (A -> Result<E,C>)
//    //    Re-write evenFrom0To100 using this operator.
//}
// ============================================================================================




// Helper functions for testing. Feel free to ignore.
extension Result {
    public func getValue() -> A? {
        return self.reduce({ _ in .None }, { a in .Some(a) })
    }
    public func getError() -> E? {
        return self.reduce({ e in .Some(e) }, { _ in .None })
    }
    public var description : String {
        return self.reduce({ e in "Error: \(e)" }, { v in "Value: \(v)" })
    }
}
