import Foundation
import UIKit
import XCTest

/*
EXERCISE
========
map is a function of the form:

    map : (A -> B) -> F<A> -> F<B>

Arrays and Options have valid map implementations:

    map : (A -> B) -> [A] -> [B]
    map : (A -> B) ->  A? ->  B?

For this exercise we will implement our own versions of these functions (named "myMap" so it doesn't conflict with built-in functions).
These are marked with "*** TODO ***".

To be a valid map function an implementation must also obey two laws:

1.  x.map({$0})       = x                       ( map id = id )
2.  x.map({p(q($0))}) = x.map(q).map(p)         ( map (p . q) = map p . map q )

I normally summarise these laws as "valid implementations don't do weird stuff".

Ivory Tower-types call types that have valid map functions "functors".
Functors are more general in Category Theory I think, but this is a useful definition to start with.
*/

extension Array {
    //*** TODO ***
    func myMap<B>(f: Element -> B) -> [B] {
        return []
    }
}

class Ex01_1_ArrayMapExamples: XCTestCase {
    func testMapEmpty() {
        let a : [Int] = []
        let result = a.myMap(plus1)
        
        XCTAssert( result == [], toString(result))
    }
    
    func testMapPlus1() {
        let result = [1,2,3].myMap(plus1)
        
        XCTAssert(result ==  [2,3,4], toString(result))
    }
    
    func testExampleOfFirstLaw() {
        let empty : [Int] = []
        let x = [1,2,3]
        
        assertEqual(x.myMap({$0}), x)
        assertEqual(empty.myMap({$0}), empty)
    }
    
    
    func testExampleOfSecondLaw() {
        let empty : [Int] = []
        let x = [1,2,3]
        
        assertEqual( x.myMap({ times10(plus1($0)) }), x.myMap(plus1).myMap(times10) )
        assertEqual( empty.myMap({ times10(plus1($0)) }), empty.myMap(plus1).myMap(times10) )
    }
}

extension Optional {
    //*** TODO ***
    func myMap<B>(f: T -> B) -> B? {
        return .None
    }
}


class Ex01_2_OptionalMapExamples: XCTestCase {
    func testMapEmpty() {
        let a : Int? = nil
        let result = a.map(plus1)
        
        XCTAssert(result == nil, toString(result))
    }
    
    func testMapPlus1() {
        let a = Optional.Some(41)
        let result = a.map(plus1)
        
        XCTAssert(result == .Some(42), toString(result))
    }
    
    func testExampleOfFirstLaw() {
        let empty : [Int] = []
        let x = [1,2,3]
        
        assertEqual(x.myMap({$0}), x)
        assertEqual(empty.myMap({$0}), empty)
    }
    
    
    func testExampleOfSecondLaw() {
        let empty : Int? = nil
        let x = Optional.Some(42)
        
        assertEqual( x.myMap({ times10(plus1($0)) }), x.myMap(plus1).myMap(times10) )
        assertEqual( empty.myMap({ times10(plus1($0)) }), empty.myMap(plus1).myMap(times10) )
    }
}





///////////////////////////////
// Helper functions

func plus1(x : Int) -> Int {
    return x+1
}
func times10(x : Int) -> Int {
    return x*10
}

// Assertion helpers
func assertEqual<T : Equatable>(actual : [T], expected : [T], file: String = __FILE__, line: UInt = __LINE__) {
    XCTAssert(actual == expected, "Expected: \(expected), Actual: \(actual)", file: file, line: line)
}
func assertEqual<T : Equatable>(actual : T?, expected : T?, file: String = __FILE__, line: UInt = __LINE__) {
    XCTAssert(actual == expected, "Expected: \(expected), Actual: \(actual)", file: file, line: line)
}

