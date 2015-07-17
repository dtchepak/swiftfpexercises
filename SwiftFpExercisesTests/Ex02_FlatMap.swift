import Foundation
import UIKit
import XCTest

/*
EXERCISE
========
flatMap is a function of the form:

    flatMap : (A -> M<B>) -> M<A> -> M<B>

Arrays and Options have valid flatMap implementations:

    flatMap : (A -> [B]) -> [A] -> [B]
    flatMap : (A ->  B?) ->  A? ->  B?

For this exercise we will implement our own versions of these functions, marked with "*** TODO ***".

To be a valid flatMap function an implementation must obey three laws, but as with map, I normally summarise these as "valid implementations don't do weird stuff".
For more info on the laws: https://en.wikibooks.org/wiki/Haskell/Understanding_monads#Monad_Laws

*/

extension Array {
    //*** TODO ***
    func flatMap<B>(f: Element -> [B]) -> [B] {
        return []
    }
}

class Ex02_1_ArrayFlatMapExamples : XCTestCase {
    func testFlatMap() {
        let result = [ "hello world", "how are you"].flatMap({ $0.componentsSeparatedByString(" ") })
        XCTAssert(result == ["hello", "world", "how", "are", "you"], toString(result))
    }

    func productsForDepartmentId(x : Int) -> [String] {
        switch x {
        case 1: return ["tea", "coffee", "cola"]
        case 2: return ["chips", "dip"]
        case 3: return ["iphone", "ipad"]
        case 4: return ["beer", "more beer", "cider"]
        case 5: return ["giant walrus"]
        default: return []
        }
    }

    //*** TODO ***
    //Get list of products. Use Array.flatMap, productsForDepartmentId
    func getProductsForDepartments(depts : [Int]) -> [String] {
        return []
    }
    
    func testGetProductsForDepartments() {
        let departments = [1, 4]
        let result = getProductsForDepartments(departments)
        XCTAssert(result == ["tea", "coffee", "cola", "beer", "more beer", "cider"], toString(result))
    }
}



extension Optional {
    //*** TODO ***
    func flatMap<B>(f: T -> B?) -> B? {
        return .None
    }
}

class Ex02_2_OptionalFlatMapExamples: XCTestCase {
    struct Font {
        var name : String
        var size : Int
    }
    struct Style {
        var font : Font?
        func getFont() -> Font? {
            return font;
        }
    }
    struct Widget {
        var style : Style?
        func getStyle() -> Style? {
            return style;
        }
    }
    
    func testFlatMap() {
        let widget = Widget(style: Style(font: Font(name: "Helvetica", size: 12)))
        
        let result =
            widget.getStyle().flatMap( {
                s in s.getFont().flatMap( {
                    font in .Some(font.name) } )
            })
        
        XCTAssert(result == .Some("Helvetica"), toString(result))
    }
    
    func testFlatMapWhenSomethingIsNil() {
        let widget = Widget(style: Style(font: nil))
        
        let result =
            widget.getStyle().flatMap( {
                s in s.getFont().flatMap( {
                    font in .Some(font.name) } )
            })
        
        XCTAssert(result == .None, toString(result))
    }
}

/*
If we have a valid flatMap function for some M, and we also have a function:

    unit : A -> M<A>        (also called return, pure, point)

Then Ivory Tower-types say "M is a monad" (or "there is a monad instance for M").
To say "M is a monad" is to say the type M has flatMap and unit.

Let's implement a unit function for Optional: given a value of type A, return an Optional<A> that passes the test case.
*/

extension Optional {
    //*** TODO ***
    static func unit<A>(x : A) -> A? {
        return .None
    }
}

class Ex02_3_OptionalUnit : XCTestCase {
    func testUnitExamples() {
        let result = Optional<Int>.unit(42)
        let result2 = Optional<String>.unit("hello")

        XCTAssert(result == .Some(42), toString(result))
        XCTAssert(result2 == .Some("hello"), toString(result2))
    }
}

/*
Anything that has flatMap and a unit function also has a map function. In other words, all monads are also functors.

Demonstrate this by implementing Optional.mapUsingFlatMap using Optional.flatMap and Optional.unit.

EXTENSION:
    - prove that Optional.map and Optional.mapUsingFlatMap are equivalent.
*/

extension Optional {
    //*** TODO ***
    //Use Optional.flatMap and Optional.unit
    func mapUsingFlatMap<B>(f : (T -> B)) -> B? {
        return .None
    }
}

class Ex02_4_Map_FlatMap_Relationship: XCTestCase {
    func testMapEmpty() {
        let a : Int? = nil
        let result = a.mapUsingFlatMap(plus1)

        XCTAssert(result == nil, toString(result))
    }

    func testMapPlus1() {
        let a = Optional.Some(41)
        let result = a.mapUsingFlatMap(plus1)

        XCTAssert(result == .Some(42), toString(result))
    }

    func testExampleOfFirstLaw() {
        let empty : Int? = .None
        let x : Int? = .Some(42)

        assertEqual(x.mapUsingFlatMap({$0}), x)
        assertEqual(empty.mapUsingFlatMap({$0}), empty)
    }

    func testExampleOfSecondLaw() {
        let empty : Int? = nil
        let x = Optional.Some(42)

        assertEqual( x.mapUsingFlatMap({ times10(plus1($0)) }), x.mapUsingFlatMap(plus1).mapUsingFlatMap(times10) )
        assertEqual( empty.mapUsingFlatMap({ times10(plus1($0)) }), empty.mapUsingFlatMap(plus1).mapUsingFlatMap(times10) )
    }
}