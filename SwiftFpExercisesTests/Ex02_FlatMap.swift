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

Aside
-----
If we have a valid flatMap function for some M, and we also have a function:

    unit : A -> M<A>        (also called return, pure, point)

Then Ivory Tower-types say "M is a monad" (or "there is a monad instance for M").
To say "M is a monad" is to say the type M has flatMap and unit.

An example of the unit function for Optional would be:

    func unit<T>(x : T) -> T? {
      return .Some(x)
    }
*/

extension Array {
    //*** TODO ***
    func flatMap<B>(f: Element -> [B]) -> [B] {
        return []
    }
}

class Ex02_1_ArrayFlatMapExamples : XCTestCase {
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
    
    func testGetProductsForDepartments() {
        let departments = [1, 4]
        let result = [] // *** TODO *** Get list of products. Use Array.flatMap, productsForDepartmentId
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