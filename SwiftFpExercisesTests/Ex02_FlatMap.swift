import Foundation
import UIKit
import XCTest

/*
EXERCISE
========
flatMap is a function of the form:

    flatMap : (A -> M<B>) -> M<A> -> M<B>

Arrays and Optionals have valid flatMap implementations:

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
        XCTAssert(result == ["hello", "world", "how", "are", "you"], String(result))
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
        XCTAssert(result == ["tea", "coffee", "cola", "beer", "more beer", "cider"], String(result))
    }
}



extension Optional {
    //*** TODO ***
    func flatMap<B>(f: Wrapped -> B?) -> B? {
        return .None
    }
}

class Ex02_2_OptionalFlatMapExamples: XCTestCase {
    func ensureEven(i : Int) -> Int? {
        return i%2==0 ? .Some(i) : .None
    }
    
    func testFlatMap() {
        assertEqual(Int("42").flatMap(ensureEven), expected: .Some(42))
        assertEqual(Int("123").flatMap(ensureEven), expected: .None)
        assertEqual(Int("abc").flatMap(ensureEven), expected: .None)
    }
    
    func ensureBetween(start : Int, inclusiveEnd : Int)(i : Int) -> Int? {
        return i>=start && i<=inclusiveEnd ? .Some(i) : .None
    }
    
    //*** TODO ***
    //Convert s to .Some number between 0 and 9, or return .None.
    //HINT: - use testFlatMap as a template for your answer
    //      - ensureBetween(x, inclusiveEnd: y) will return a function of type Int -> Int?.
    func maybeSingleDigitNumber(s : String) -> Int? {
        return .None
    }
    
    func testMaybeSingleDigitNumber() {
        assertEqual(maybeSingleDigitNumber("9"), expected: .Some(9))
        assertEqual(maybeSingleDigitNumber("0"), expected: .Some(0))
        assertEqual(maybeSingleDigitNumber("abc"), expected: .None)
        assertEqual(maybeSingleDigitNumber("42"), expected: .None)
    }
    
    struct Font {
        let name : String
        let size : Int
    }
    struct Style {
        let font : Font?
    }
    struct Widget {
        let style : Style?
    }
    
    // Example: using flatmap to chain together multiple calls that can return .None.
    func getFontName(widget : Widget) -> String? {
        return widget.style.flatMap( {
                 s in s.font.flatMap( {
                   font in .Some(font.name) } )
        })
    }
    
    func testGetFontNameFromWidget() {
        let widget = Widget(style: Style(font: Font(name: "Helvetica", size: 12)))
        let unstylishWidget = Widget(style: Style(font: nil))

        assertEqual(getFontName(widget), expected: .Some("Helvetica"))
        assertEqual(getFontName(unstylishWidget), expected: .None)
    }
    
    //*** TODO ***
    // If widget has a style and font, return .Some(true) if the font size is over 12, or .Some(false) if less than or equal to 12.
    // If the widget has no style, or a style without a font specified, return .None.
    // HINT: Use getFontName as a template for your answer
    func hasFontLargerThan12(widget : Widget) -> Bool? {
        return .None
    }
    
    func testFontSizeCheck() {
        let smallFontWidget = Widget(style: Style(font: Font(name: "Helvetica", size: 12)))
        let largeFontWidget = Widget(style: Style(font: Font(name: "Helvetica", size: 42)))
        let noFontWidget = Widget(style: Style(font: nil))
        
        assertEqual(hasFontLargerThan12(smallFontWidget), expected: .Some(false))
        assertEqual(hasFontLargerThan12(largeFontWidget), expected: .Some(true))
        assertEqual(hasFontLargerThan12(noFontWidget), expected: .None)
    }
    
    //*** TODO ***
    // Try to convert both first and second strings to integers (using str.toInt()).
    // If both conversions succeed, return the result of adding the two numbers. Otherwise return .None
    func maybeAdd(first : String, _ second : String) -> Int? {
        return .None
    }
    
    func testMaybeAdd() {
        assertEqual(maybeAdd("42", "100"), expected: .Some(142))
        assertEqual(maybeAdd("42", "aaa"), expected: .None)
        assertEqual(maybeAdd("zz", "100"), expected: .None)
        assertEqual(maybeAdd("zz", "aaa"), expected: .None)
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

        XCTAssert(result == .Some(42), String(result))
        XCTAssert(result2 == .Some("hello"), String(result2))
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
    func mapUsingFlatMap<B>(f : (Wrapped -> B)) -> B? {
        return .None
    }
}

class Ex02_4_Map_FlatMap_Relationship: XCTestCase {
    func testMapEmpty() {
        let a : Int? = nil
        let result = a.mapUsingFlatMap(plus1)

        XCTAssert(result == nil, String(result))
    }

    func testMapPlus1() {
        let a = Optional.Some(41)
        let result = a.mapUsingFlatMap(plus1)

        XCTAssert(result == .Some(42), String(result))
    }

    func testExampleOfFirstLaw() {
        let empty : Int? = .None
        let x : Int? = .Some(42)

        assertEqual(x.mapUsingFlatMap({$0}), expected: x)
        assertEqual(empty.mapUsingFlatMap({$0}), expected: empty)
    }

    func testExampleOfSecondLaw() {
        let empty : Int? = nil
        let x = Optional.Some(42)

        assertEqual( x.mapUsingFlatMap({ times10(plus1($0)) }), expected: x.mapUsingFlatMap(plus1).mapUsingFlatMap(times10) )
        assertEqual( empty.mapUsingFlatMap({ times10(plus1($0)) }), expected: empty.mapUsingFlatMap(plus1).mapUsingFlatMap(times10) )
    }
}
