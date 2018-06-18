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

For this exercise we will implement and use our own versions of these functions, marked with "*** TODO ***" comments.
Run the tests after implementing each TODO and make sure the associated ones pass. (It's probably worth reading the tests
as well to see the expected behaviour.)
 
To be a valid flatMap function an implementation must obey three laws, but as with map, I normally summarise these as "valid implementations don't do weird stuff".
For more info on the laws: https://en.wikibooks.org/wiki/Haskell/Understanding_monads#Monad_Laws

*/

extension Array {
    // *** TODO ***
    // Implement without using the built-in flatMap function.
    func flatMap<B>(_ f: (Element) -> [B]) -> [B] {
        return []
    }
}

class Ex02_1_ArrayFlatMapExamples : XCTestCase {
    func testFlatMap() {
        let result = [ "hello world", "how are you"].flatMap({ $0.components(separatedBy: " ") })
        XCTAssert(result == ["hello", "world", "how", "are", "you"], String(describing: result))
    }

    func productsForDepartmentId(_ x : Int) -> [String] {
        switch x {
        case 1: return ["tea", "coffee", "cola"]
        case 2: return ["chips", "dip"]
        case 3: return ["iphone", "ipad"]
        case 4: return ["beer", "more beer", "cider"]
        case 5: return ["giant walrus"]
        default: return []
        }
    }

    // *** TODO ***
    // Get list of products. Use Array.flatMap, productsForDepartmentId
    func getProductsForDepartments(_ depts : [Int]) -> [String] {
        return []
    }
    
    func testGetProductsForDepartments() {
        let departments = [1, 4]
        let result = getProductsForDepartments(departments)
        XCTAssert(result == ["tea", "coffee", "cola", "beer", "more beer", "cider"], String(describing: result))
    }
}



extension Optional {
    // *** TODO ***
    // Implement without using the built-in flatMap function.
    func flatMap<B>(_ f: (Wrapped) -> B?) -> B? {
        return .none
    }
}

class Ex02_2_OptionalFlatMapExamples: XCTestCase {
    func ensureEven(_ i : Int) -> Int? {
        return i%2==0 ? .some(i) : .none
    }
    
    func testFlatMap() {
        assertEqual(Int("42").flatMap(ensureEven), expected: .some(42))
        assertEqual(Int("123").flatMap(ensureEven), expected: .none)
        assertEqual(Int("abc").flatMap(ensureEven), expected: .none)
    }
    
    func ensureBetween(start : Int, inclusiveEnd : Int) -> (Int) -> Int? {
        return { i in
            return i>=start && i<=inclusiveEnd ? .some(i) : .none
        }
    }
    
    // *** TODO ***
    // Convert s to .some number between 0 and 9, or return .none.
    // Use flatMap and/or map. Do not use the Swift's built-in `?.` chaining.
    // HINT: - use testFlatMap as a template for your answer
    //       - ensureBetween(x, inclusiveEnd: y) will return a function of type Int -> Int?.
    func maybeSingleDigitNumber(_ s : String) -> Int? {
        return .none
    }
    
    func testMaybeSingleDigitNumber() {
        assertEqual(maybeSingleDigitNumber("9"), expected: .some(9))
        assertEqual(maybeSingleDigitNumber("0"), expected: .some(0))
        assertEqual(maybeSingleDigitNumber("abc"), expected: .none)
        assertEqual(maybeSingleDigitNumber("42"), expected: .none)
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
    struct Contraption {
        let widget : Widget?
    }
    
    // Example: using flatmap to chain together multiple calls that can return .none.
    func getFontName(_ contraption : Contraption) -> String? {
        return contraption.widget.flatMap { widget in
            widget.style.flatMap { s in
                s.font.flatMap { font in
                    .some(font.name)
                }}}
    }
    // EXTENSION: replace `s.font.flatMap { ... }` with a call to `s.font.map { ... }` in the `getFontName` code above.

    func testGetFontNameFromContraption() {
        let contraption = Contraption(widget: Widget(style: Style(font: Font(name: "Helvetica", size: 12))))
        let unstylishContraption = Contraption(widget: Widget(style: Style(font: nil)))

        assertEqual(getFontName(contraption), expected: .some("Helvetica"))
        assertEqual(getFontName(unstylishContraption), expected: .none)
    }

    // Example: for Swift Optionals we can also use optional chaining with `?.`.
    func getFontNameChained(_ contraption : Contraption) -> String? {
        return contraption.widget?.style?.font?.name
    }
    // For cases like `getFontName` this can be a lot neater than flatMap, but flatMap can do extra things that `?.` can't:
    //
    // - with flatMap we can make a decision at each point in the chain (which we'll do in the hasFontLargerThan12 example below)
    // - we can use flatMap with lot more types than just Optional
    // - we can implement flatMap for our own types — we do not need a special case built into the compiler.
    //
    // We'll avoid using `?.` for the rest of these exercises, but it is worth noting that `getFontNameChained` and `getFontName`
    // are logically equivalent.
    func testGetFontNameChainedAndFlatMapped() {
        let contraption = Contraption(widget: Widget(style: Style(font: Font(name: "Helvetica", size: 12))))
        let unstylishContraption = Contraption(widget: Widget(style: Style(font: nil)))

        assertEqual(getFontName(contraption), expected: getFontNameChained(contraption))
        assertEqual(getFontName(unstylishContraption), expected: getFontNameChained(unstylishContraption))
    }
    
    // *** TODO ***
    // If contraption has a widget, style and font, return .some(true) if the font size is over 12, or .some(false) if less than or equal to 12.
    // If the widget has no style, or a style without a font specified, return .none.
    //
    // Use flatMap and/or map. Do not use the Swift's built-in `?.` chaining.
    //
    // HINT: Use getFontName as a template for your answer
    func hasFontLargerThan12(_ contraption : Contraption) -> Bool? {
        return .none
    }
    
    func testFontSizeCheck() {
        let smallFontContraption = Contraption(widget: Widget(style: Style(font: Font(name: "Helvetica", size: 12))))
        let largeFontContraption = Contraption(widget: Widget(style: Style(font: Font(name: "Helvetica", size: 42))))
        let noFontContraption = Contraption(widget: Widget(style: Style(font: nil)))
        
        assertEqual(hasFontLargerThan12(smallFontContraption), expected: .some(false))
        assertEqual(hasFontLargerThan12(largeFontContraption), expected: .some(true))
        assertEqual(hasFontLargerThan12(noFontContraption), expected: .none)
    }
    
    // *** TODO ***
    // Try to convert both first and second strings to integers (using `Int(s: String)`).
    // If both conversions succeed, return the result of adding the two numbers. Otherwise return .none
    // Use flatMap and/or map. Do not use the Swift's built-in `?.` chaining.
    func maybeAdd(_ first : String, _ second : String) -> Int? {
        return .none
    }
    
    func testMaybeAdd() {
        assertEqual(maybeAdd("42", "100"), expected: .some(142))
        assertEqual(maybeAdd("42", "aaa"), expected: .none)
        assertEqual(maybeAdd("zz", "100"), expected: .none)
        assertEqual(maybeAdd("zz", "aaa"), expected: .none)
    }
}

/*
If we have a valid flatMap function for some M, and we also have a function:

    unit : A -> M<A>        (also called return, pure, point)

Then Ivory Tower-types say "M is a monad" (or "there is a monad instance for M").
To say "M is a monad" is to say the type M has flatMap and unit.

Let's implement a unit function for Array: given a value of type A, return an Array<A> that passes the test case.
*/

extension Array {
    // *** TODO ***
    static func unit<A>(_ x : A) -> [A] {
        return []
    }
}

class Ex02_3_ArrayUnit : XCTestCase {
    func testUnitExamples() {
        let result = Array<Int>.unit(42)
        let result2 = Array<String>.unit("hello")
        
        XCTAssert(result == [42], String(describing: result))
        XCTAssert(result2 == ["hello"], String(describing: result2))
    }
}

/*
Optionals also have flatMap and unit.
Implement a unit function for Optional: given a value of type A, return a A? that passes the test case.
*/

extension Optional {
    // *** TODO ***
    static func unit<A>(_ x : A) -> A? {
        return .none
    }
}

class Ex02_4_OptionalUnit : XCTestCase {
    func testUnitExamples() {
        let result = Optional<Int>.unit(42)
        let result2 = Optional<String>.unit("hello")
        
        XCTAssert(result == .some(42), String(describing: result))
        XCTAssert(result2 == .some("hello"), String(describing: result2))
    }
}


/*
Anything that has flatMap and a unit function also has a map function. In other words, all monads are also functors.

Demonstrate this by implementing:
 -  Array.mapUsingFlatMap using only Array.flatMap and Array.unit.
 -  Optional.mapUsingFlatMap using only Optional.flatMap and Optional.unit.
*/

extension Array {
    // *** TODO ***
    // Use Array.flatMap and Array.unit.
    //
    // NOTE: No deprecation warnings or Array.concatMap allowed!
    func mapUsingFlatMap<B>(_ f : (Element) -> B) -> [B] {
        return []
    }
}

extension Optional {
    // *** TODO ***
    // Use Optional.flatMap and Optional.unit
    //
    // NOTE: Swift auto-casts B to B?. If you ignore this and explicitly use Optional.unit instead, you should see
    // a nice comparison to your Array.mapUsingFlatMap implementation.
    func mapUsingFlatMap<B>(_ f : (Wrapped) -> B) -> B? {
        return .none
    }
}

class Ex02_5_Map_FlatMap_Relationship: XCTestCase {
    func testMapEmptyArray() {
        let a : [Int] = []
        let result = a.mapUsingFlatMap(plus1)
        
        XCTAssert(result == [], String(describing: result))
    }
    
    func testMapPlus1Array() {
        let a = [41, 10, 102]
        let result = a.mapUsingFlatMap(plus1)
        
        XCTAssert(result == [42, 11, 103], String(describing: result))
    }
    
    func testExampleOfFirstLawArray() {
        let empty : [Int] = []
        let x : [Int] = [42, 11, 103]
        
        assertEqual(x.mapUsingFlatMap { $0 }, expected: x)
        assertEqual(empty.mapUsingFlatMap { $0 }, expected: empty)
    }
    
    func testExampleOfSecondLawArray() {
        let empty : [Int] = []
        let x = [42, 11, 103]
        
        assertEqual( x.mapUsingFlatMap(times10 ∘ plus1), expected: x.mapUsingFlatMap(plus1).mapUsingFlatMap(times10) )
        assertEqual( empty.mapUsingFlatMap(times10 ∘ plus1), expected: empty.mapUsingFlatMap(plus1).mapUsingFlatMap(times10) )
    }

    func testMapEmptyOptional() {
        let a : Int? = nil
        let result = a.mapUsingFlatMap(plus1)

        XCTAssert(result == nil, String(describing: result))
    }

    func testMapPlus1Optional() {
        let a = Optional.some(41)
        let result = a.mapUsingFlatMap(plus1)
        
        XCTAssert(result == .some(42), String(describing: result))
    }

    func testExampleOfFirstLawOptional() {
        let empty : Int? = .none
        let x : Int? = .some(42)
        
        assertEqual(x.mapUsingFlatMap { $0 }, expected: x)
        assertEqual(empty.mapUsingFlatMap { $0 }, expected: empty)
    }

    func testExampleOfSecondLawOptional() {
        let empty : Int? = nil
        let x = Optional.some(42)
        
        assertEqual( x.mapUsingFlatMap(times10 ∘ plus1), expected: x.mapUsingFlatMap(plus1).mapUsingFlatMap(times10) )
        assertEqual( empty.mapUsingFlatMap(times10 ∘ plus1), expected: empty.mapUsingFlatMap(plus1).mapUsingFlatMap(times10) )
    }
}
