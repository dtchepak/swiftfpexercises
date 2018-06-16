import Foundation
import UIKit
import XCTest

/*
EXERCISE
========
map is a function of the form:

    map : (A -> B) -> F<A> -> F<B>

Arrays and Optionals have valid map implementations:

    map : (A -> B) -> [A] -> [B]
    map : (A -> B) ->  A? ->  B?

For this exercise we will implement and use our own versions of these functions (named "myMap" so they don't conflict with the
built-in functions). Each task is marked with "*** TODO ***" comments. Run the tests after implementing each TODO and make
sure the associated ones pass. (It's probably worth reading the tests as well to see the expected behaviour.)

To be a valid map function an implementation must also obey two laws:

1.  x.map({$0})       = x                       ( map id = id )
2.  x.map({p(q($0))}) = x.map(q).map(p)         ( map (p . q) = map p . map q )

I normally summarise these laws as "valid implementations don't do weird stuff".

Ivory Tower-types call types that have valid map functions "functors".
Functors are more general in Category Theory I think, but this is a useful definition to start with.
*/

extension Array {
    // *** TODO ***
    // Implement without using the built-in map function.
    func myMap<B>(_ f: (Element) -> B) -> [B] {
        return []
    }
}

class Ex01_1_ArrayMapExamples: XCTestCase {
    func testMapEmpty() {
        let a : [Int] = []
        let result = a.myMap(plus1)
        
        XCTAssert( result == [], String(describing: result))
    }
    
    func testMapPlus1() {
        let result = [1,2,3].myMap(plus1)
        
        XCTAssert(result == [2,3,4], String(describing: result))
    }
    
    func testExampleOfFirstLaw() {
        let empty : [Int] = []
        let x = [1,2,3]
        
        assertEqual(x.myMap({$0}), expected: x)
        assertEqual(empty.myMap({$0}), expected: empty)
    }
    
    
    func testExampleOfSecondLaw() {
        let empty : [Int] = []
        let x = [1,2,3]
        
        assertEqual(x.myMap({ times10(plus1($0)) }), expected: x.myMap(plus1).myMap(times10) )
        assertEqual(empty.myMap({ times10(plus1($0)) }), expected: empty.myMap(plus1).myMap(times10) )
    }
}

extension Optional {
    // *** TODO ***
    // Implement without using the built-in map function.
    func myMap<B>(_ f: (Wrapped) -> B) -> B? {
        return .none
    }
}


class Ex01_2_OptionalMapExamples: XCTestCase {
    func testMapEmpty() {
        let a : Int? = nil
        let result = a.myMap(plus1)
        
        XCTAssert(result == nil, String(describing: result))
    }
    
    func testMapPlus1() {
        let a = Optional.some(41)
        let result = a.myMap(plus1)
        
        XCTAssert(result == .some(42), String(describing: result))
    }
    
    func testExampleOfFirstLaw() {
        let empty : Int? = .none
        let x : Int? = .some(42)
        
        assertEqual(x.myMap({$0}), expected: x)
        assertEqual(empty.myMap({$0}), expected: empty)
    }
    
    
    func testExampleOfSecondLaw() {
        let empty : Int? = nil
        let x = Optional.some(42)
        
        assertEqual( x.myMap({ times10(plus1($0)) }), expected: x.myMap(plus1).myMap(times10) )
        assertEqual( empty.myMap({ times10(plus1($0)) }), expected: empty.myMap(plus1).myMap(times10) )
    }
}

class Ex01_3_UsingMap : XCTestCase {
    func toUpper(_ s : String) -> String { return s.uppercased() }
    func even(_ i : Int) -> Bool { return i%2==0 }
    func describeBool(_ prefix: String) -> (Bool) -> String {
        return { b in "\(prefix) \(b)" } }
    
    // *** TODO ***
    // Convert an optional string to uppercase using myMap (no pattern matching allowed)
    func toUpperOpt(_ s : String?) -> String? {
        return .none
    }
    
    func testToUpper() {
        assertEqual(toUpperOpt(.some("hello")), expected: .some("HELLO"))
        assertEqual(toUpperOpt(.none), expected: .none)
    }
    
    // *** TODO ***
    // Convert a list of strings to uppercase using myMap (no explicit loops allowed)
    func toUpperArr(_ s : [String]) -> [String] {
        return []
    }
   
    func testToUpperArr() {
        assertEqual(toUpperArr(["hello", "world"]), expected: ["HELLO", "WORLD"])
        assertEqual(toUpperArr([]), expected: [])
    }
    
    // *** TODO ***
    // Check to see if an optional int is even (no pattern matching allowed). If the input is .none the output should also be .none.
    func isEvenOpt(_ i : Int?) -> Bool? {
        return .none
    }
    
    func testIsEven() {
        assertEqual(isEvenOpt(.some(2)), expected: .some(true))
        assertEqual(isEvenOpt(.some(3)), expected: .some(false))
        assertEqual(isEvenOpt(.none), expected: .none)
    }
    
    // *** TODO ***
    // Take an optional int, then describe it as .some("NUMBER EVEN? TRUE"), .some("NUMBER EVEN? FALSE"), or .none. No pattern matching.
    // The functions toUpper, even and describeBool are provided in this class.
    // Use MULTIPLE calls to Optional.map
    func describeEven(_ i : Int?) -> String? {
        return .none
    }
    
    func testDescribeEven() {
        assertEqual(describeEven(.some(2)), expected: .some("NUMBER EVEN? TRUE"))
        assertEqual(describeEven(.some(3)), expected: .some("NUMBER EVEN? FALSE"))
        assertEqual(describeEven(.none), expected: .none)
    }
    
    // *** TODO ***
    // Take an optional int, then describe it as .some("NUMBER EVEN? TRUE"), .some("NUMBER EVEN? FALSE"), or .none. No pattern matching.
    // Use a SINGLE call to Optional.map.
    // HINT: the second law for map functions will help here
    func describeEvenAgain(_ i : Int?) -> String? {
        return .none
    }

    func testDescribeEvenAgain() {
        assertEqual(describeEvenAgain(.some(2)), expected: .some("NUMBER EVEN? TRUE"))
        assertEqual(describeEvenAgain(.some(3)), expected: .some("NUMBER EVEN? FALSE"))
        assertEqual(describeEvenAgain(.none), expected: .none)
    }
}

///////////////////////////////
// Helper functions

func plus1(_ x : Int) -> Int {
    return x+1
}
func times10(_ x : Int) -> Int {
    return x*10
}

// Assertion helpers
func assertEqual<T : Equatable>(_ actual : [T], expected : [T], file: StaticString = #file, line: UInt = #line) {
    XCTAssert(actual == expected, "Expected: \(expected), Actual: \(actual)", file: file, line: line)
}
func assertEqual<T : Equatable>(_ actual : T?, expected : T?, file: StaticString = #file, line: UInt = #line) {
    XCTAssert(actual == expected, "Expected: \(String(describing: expected)), Actual: \(String(describing: actual))", file: file, line: line)
}

