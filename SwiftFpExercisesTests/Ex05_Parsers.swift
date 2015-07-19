// Parser exercises, based on those written by Tony Morris et al., published under NICTA repo
// https://github.com/NICTA/course/blob/af3e945d5eadcaf0a11a462e2ef7f5378b71d7f7/src/Course/Parser.hs
/*
EXERCISES
=========

The goal is to work through this file replacing calls to TODO() with real implementations, getting
each test to pass along the way.

See FlatMapPattern.md for some context and tips.

*/
import UIKit
import XCTest


public typealias Input = String

public enum ParseError : Printable, Equatable {
    case UnexpectedEof
    case ExpectedEof(Input)
    case UnexpectedChar(Character)
    case Failed(String)
    public var description : String {
        switch self {
        case .UnexpectedChar(let c): return "Unexpected character: \(c)"
        case .UnexpectedEof : return "Unexpected end of stream"
        case .ExpectedEof(let c): return "Expected end of stream, but got >\(c)<"
        case .Failed(let s): return s
        }
    }
}

public enum ParseResult<A> : Printable {
    case ErrorResult(ParseError)
    case Result(Input,Box<A>)
    public var description : String {
        switch self {
        case .ErrorResult(let p) : return p.description
        case .Result(let i, let a): return "Result >\(i)<, \(a.value)"
        }
    }
    public func isError() -> Bool {
        switch self {
        case ErrorResult(_) : return true
        case Result(_): return false
        }
    }
}

// Convenience functions for creating ParseResult<A> values.
public func succeed<A>(remainingInput : Input, value : A) -> ParseResult<A> { return .Result(remainingInput, Box(value)) }
public func failWithUnexpectedEof<A>() -> ParseResult<A> { return .ErrorResult(.UnexpectedEof) }
public func failWithExpectedEof<A>(i : Input) -> ParseResult<A> { return .ErrorResult(.ExpectedEof(i)) }
public func failWithUnexpectedChar<A>(c : Character) -> ParseResult<A> { return .ErrorResult(.UnexpectedChar(c)) }
public func failParse<A>() -> ParseResult<A>{ return .ErrorResult(.Failed("Parse failed")) }
public func failWithParseError<A>(e : ParseError) -> ParseResult<A> { return .ErrorResult(e) }


// A Parser<A> wraps a function that takes some input and returns either:
// * a value of type A, and the remaining input left to parse
// * a parse error
public struct Parser<A> {
    let p : Input -> ParseResult<A>
    init(_ p : Input -> ParseResult<A>) { self.p = p }
    
    public func parse(i : Input) -> ParseResult<A> { return self.p(i) }
}
// Placeholder function - don't change this function itself, just replace all calls to it with real implementations.
public func TODO<A>() -> Parser<A> { return Parser({ i in .ErrorResult(.Failed("*** TODO ***"))}) }

// Produces a parser that always fails with UnexpectedChar given the specified character
public func unexpectedCharParser<A>(c : Character) -> Parser<A> {
    return Parser({ i in failWithUnexpectedChar(c) })
}

// Return a parser that always succeeds with the given value and consumes no input.
// Hint: Use `unexpectedCharParser` as a template for the answer (although rather than failing,
//       it should succeed with the required value)
public func valueParser<A>(a : A) -> Parser<A> {
    return Parser({ i in  succeed(i, a) })
}

class Ex05_01_ValueParserExamples : XCTestCase {
    func testValueParser() {
        let result = valueParser(2).parse("hello")
        assertEqual(result, succeed("hello", 2))
    }
}

// Return a parser that always fails with ParseError.failed.
public func failed<A>() -> Parser<A> {
    return Parser({ _ in failParse() })
}

class Ex05_02_FailedParserExamples : XCTestCase {
    func testFailedParser() {
        let result : ParseResult<Int> = failed().parse("abc")
        assertEqual(result, failParse())
    }
}


// Return a parser that succeeds with a character off the input or fails with an error if the input is empty.
// String manipulation examples:
//      http://sketchytech.blogspot.com.au/2014/08/swift-pure-swift-method-for-returning.html
public func character() -> Parser<Character> {
    return Parser({ i in switch first(i) {
                            case .None: return failWithUnexpectedEof()
                            case .Some(let c): return succeed(dropFirst(i), c)
                            }
    })
}

class Ex05_03_CharacterParserExamples : XCTestCase {
    func testCharacter() {
        let result = character().parse("abcd")
        assertEqual(result, succeed("bcd", "a"))
    }
    func testCharacterWithEmptyInput() {
        let result = character().parse("")
        assertEqual(result, failWithUnexpectedEof())
    }
}

extension Parser {
    // Return a parser that maps any succeeding result with the given function.
    // Hint: will require the construction of a `Parser<B>` and pattern matching on the result of `self.parse`.
    // Reminder: 
    //      enum ParseResult<A> { case ErrorResult(ParseError); case Result(Input,Box<A>) }
    // (watch out for the Box formality. This will no longer be required as of Swift 2)
    public func map<B>(f : A -> B) -> Parser<B> {
//        return Parser<B>({ i in
//            switch self.parse(i) {
//            case .ErrorResult(let e): return failWithParseError(e)
//            case let .Result(ii, a): return succeed(ii, f(a.value))
//            }
//        })
        return self.flatMap(valueParser • f)        // from the relationship between map and flatMap/unit we found earlier
    }
}

class Ex05_04_MapParserExamples : XCTestCase {
    func testMap() {
        let result = character().map(toUpper).parse("abc")
        assertEqual(result, succeed("bc", "A"))
    }
    func testMapAgain() {
        let result = valueParser(10).map({ $0+1 }).parse("abc")
        assertEqual(result, succeed("abc", 11))
    }
    func testMapWithErrorResult() {
        let result = failed().map({ $0 + 1 }).parse("abc")
        assertEqual(result, failParse())
    }
}

extension Parser {
    // Return a parser based on this parser (`self`). The new parser should run its input through
    // this parser, then:
    //
    //   * if this parser succeeds with a value (type A), put that value into the given function
    //     then put the remaining input into the resulting parser.
    //
    //   * if this parser fails with an error the returned parser fails with that error.
    //
    public func flatMap<B>(f : A -> Parser<B>) -> Parser<B> {
        return Parser<B>({ i in
            switch self.parse(i) {
            case .ErrorResult(let e): return failWithParseError(e)
            case let .Result(ii, a): return f(a.value).parse(ii)
            }
        })
    }
}

class Ex05_05_FlatMapParserExamples : XCTestCase {
    let skipOneX : Parser<Character> =
    character().flatMap({ c in
        if c == "x" { return character() } // if c=="x", skip this character and parse the next one
        else { return valueParser(c) }     // else return this character
    })
    func testFlatMap() {
        let result = skipOneX.parse("abcd")
        assertEqual(result, succeed("bcd", "a"))
    }
    func testFlatMapAgain() {
        let result = skipOneX.parse("xabc")
        assertEqual(result, succeed("bc", "a"))
    }
    func testFlatMapWithNoInput() {
        let result = skipOneX.parse("")
        assertEqual(result, failWithUnexpectedEof());
    }
    func testFlatMapRunningOutOfInput() {
        let result = skipOneX.parse("x")
        assertEqual(result, failWithUnexpectedEof());
    }
}

// Return a parser that puts its input into the first parser, then:
//
//   * if that parser succeeds with a value (a), ignore that value
//     but put the remaining input into the second given parser.
//
//   * if that parser fails with an error the returned parser fails with that error.
//
// Hint: Use Parser.flatMap
public func >>><A,B>(first : Parser<A>, second : Parser<B>) -> Parser<B> {
    return first.flatMap({ _ in second })
}

class Ex05_06_SkipParserExamples : XCTestCase {
    func testSkipParser() {
        let result = (character() >>> valueParser("x")).parse("abc")
        assertEqual(result, succeed("bc", "x"))
    }
    func testSkipParserWhenFirstParserFails() {
        let result = (character() >>> valueParser("x")).parse("")
        assertEqual(result, failWithUnexpectedEof())
    }
}

// Return a parser that tries the first parser for a successful value.
//
//   * If the first parser succeeds then use this parser.
//
//   * If the first parser fails, try the second parser.
public func |||<A>(first: Parser<A>, second:Parser<A>) -> Parser<A> {
    return Parser<A>({ i in
        switch first.parse(i) {
        case .ErrorResult(let e) : return second.parse(i)
        case (let result): return result
        }
    })
}

class Ex05_07_OrParserExamples : XCTestCase {
    func testOrWhenFirstSucceeds() {
        let result = (character() ||| valueParser("v")).parse("abc")
        assertEqual(result, succeed("bc", "a"))
    }
    func testOrWhenFirstFails() {
        let result = (failed() ||| valueParser("v")).parse("")
        assertEqual(result, succeed("", "v"))
    }
    func testOrWhenFirstFailsDueToLackOfInput() {
        let result = (character() ||| valueParser("v")).parse("")
        assertEqual(result, succeed("", "v"))
    }
}


// Return a parser that continues producing a list of values from the given parser.
// If there are no values that can be parsed from `p`, the returned parser should produce an empty list.
//
// Hint: - Use valueParser, |||, and atLeast1 parser (defined below).
//       - list and atLeast1 are mutually recursive calls!
public func list<A>(p : Parser<A>) -> Parser<[A]> {
    return atLeast1(p) ||| valueParser([])
}
// Return a parser that produces at least one value from the given parser then
// continues producing a list of values from the given parser (to ultimately produce a non-empty list).
// The returned parser fails if the input is empty.
//
// Hint: - Use flatMap, valueParser, and list (defined above)
//       - list and atLeast1 are mutually recursive calls!
public func atLeast1<A>(p : Parser<A>) -> Parser<[A]> {
    return p.flatMap({ a in list(p).map(cons2(a)) })
}

// list and atLeast1 should both be completed before these examples should pass
class Ex05_08_ListParserExamples : XCTestCase {
    func testList() {
        let result = list(character()).parse("abc")
        assertEqual(result, succeed("", ["a", "b", "c"]))
    }
    func testListWithNoInput() {
        let result = list(character()).parse("")
        assertEqual(result, succeed("", []))
    }
    func testAtLeastOne() {
        let result = atLeast1(character()).parse("abc")
        assertEqual(result, succeed("", ["a", "b", "c"]))
    }
    func testAtLeast1WithNoInput() {
        let result = atLeast1(character()).parse("")
        assertEqual(result, failWithUnexpectedEof())
    }
}

// Return a parser that produces a character but fails if
//
//   * The input is empty.
//   * The character does not satisfy the given predicate.
//
// Hint: The flatMap, valueParser, unexpectedCharParser and character functions will be helpful here.
public func satisfy(p : Character -> Bool) -> Parser<Character> {
    return character().flatMap({ p($0) ? valueParser($0) : unexpectedCharParser($0) })
}
class Ex05_09_SatisfyParserExamples : XCTestCase {
    func testParseUpper() {
        let result = satisfy(isUpperCase).parse("Abc")
        assertEqual(result, succeed("bc", "A"))
    }
    func testParseUpperWithLowercaseInput() {
        let result = satisfy(isUpperCase).parse("abc")
        assertEqual(result, failWithUnexpectedChar("a"))
    }
}

// Return a parser that produces the given character but fails if
//
//   * The input is empty.
//   * The produced character is not equal to the given character.
//
// Hint: Use the satisfy function.
public func charIs(c : Character) -> Parser<Character> {
    return satisfy( { c == $0 } )
}

class Ex05_10_CharIsParserExamples : XCTestCase {
    func testCharIs() {
        let result = charIs("x").parse("xyz")
        assertEqual(result, succeed("yz", "x"))
    }
    func testCharIsWhenItIsnt() {
        let result = charIs("x").parse("abc")
        assertEqual(result, failWithUnexpectedChar("a"))
    }
}

// Return a parser that produces a character between "0" and "9" but fails if
//
//   * The input is empty.
//   * The produced character is not a digit.
//
// Hint: - Use the satisfy and isDigit functions.
//       - This returns a Parser<Character>, not a Parser<Int>
public func digit() -> Parser<Character> {
    return satisfy(isDigit)
}

class Ex05_11_DigitParserExamples : XCTestCase {
    func testDigit() {
        let result = digit().parse("123")
        assertEqual(result, succeed("23", "1"))
    }
    func testDigitWhenItIsnt() {
        let result = digit().parse("abc")
        assertEqual(result, failWithUnexpectedChar("a"))
    }
}

// Return a parser that produces zero or a positive integer but fails if
//
//   * The input is empty.
//   * The input does not produce a valid series of digits
//
// Hint: Use atLeast1, digit, map, and parseIntOr0
public func natural() -> Parser<Int> {
    return atLeast1(digit()).map(parseIntOr0)
}

class Ex05_12_NaturalParserExamples : XCTestCase {
    func testParseNatural() {
        let result = natural().parse("123")
        assertEqual(result, succeed("", 123))
    }
    func testParseNaturalWithLeftOverInput() {
        let result = natural().parse("42abc")
        assertEqual(result, succeed("abc", 42))
    }
    func testParseNaturalWithNoDigitsInInput() {
        let result = natural().parse("abc")
        assertEqual(result, failWithUnexpectedChar("a"))
    }
    func testParseNaturalWithEmptyInput() {
        let result = natural().parse("")
        assertEqual(result, failWithUnexpectedEof())
    }
}

// Return a parser that produces a space character but fails if
//
//   * The input is empty.
//   * The produced character is not a space.
//
// Hint: Use the satisfy and isSpace functions.
public func space() -> Parser<Character> {
    return satisfy(isSpace)
}

class Ex05_13_SpaceParserExamples : XCTestCase {
    func testParseSpace() {
        let result = space().parse(" 123")
        assertEqual(result, succeed("123", " "))
    }
    func testParseSpaceWhenInputHasNoSpace() {
        let result = space().parse("123")
        assertEqual(result, failWithUnexpectedChar("1"))
    }
    func testParseSpaceWithEmptyInput() {
        let result = space().parse("")
        assertEqual(result, failWithUnexpectedEof())
    }
}

// Return a parser that produces one or more space characters
// (consuming until the first non-space) but fails if
//
//   * The input is empty.
//   * The first produced character is not a space.
//
// Hint: Use the atLeast1, space, map, and charsToString functions.
public func spaces() -> Parser<String> {
    return atLeast1(space()).map(charsToString)
}

class Ex05_14_SpacesParserExamples : XCTestCase {
    func testParseSpaces() {
        let result = spaces().parse("    123")
        assertEqual(result, succeed("123", "    "))
    }
    func testParseSpaceWhenInputHasNoSpace() {
        let result = spaces().parse("123")
        assertEqual(result, failWithUnexpectedChar("1"))
    }
    func testParseSpaceWithEmptyInput() {
        let result = spaces().parse("")
        assertEqual(result, failWithUnexpectedEof())
    }
}

// The next three parsers have tests/examples in a single fixture.

// Return a parser that produces a lower-case character but fails if
//
//   * The input is empty.
//   * The produced character is not lower-case.
//
// Hint: Use the satisfy and isLowerCase functions
public func lower() -> Parser<Character> {
    return satisfy(isLowerCase)
}

// Return a parser that produces an upper-case character but fails if
//
//   * The input is empty.
//   * The produced character is not upper-case.
//
// Hint: Use the satisfy and isUpperCase functions
public func upper() -> Parser<Character> {
    return satisfy(isUpperCase)
}

// Return a parser that produces an alpha character but fails if
//
//   * The input is empty.
//   * The produced character is not an alpha.
//
// Hint: Use the satisfy and isAlpha functions
public func alpha() -> Parser<Character> {
    return satisfy(isAlpha)
}

class Ex05_15_LowerUpperAlphaExamples : XCTestCase {
    func testLower() {
        testParser(lower(), passWith: ("abc", "bc", "a"), failWith: ("XYZ", "X"))
    }
    func testUpper() {
        testParser(upper(), passWith: ("Def", "ef", "D"), failWith: ("zzz", "z"))
    }
    func testAlpha() {
        testParser(alpha(), passWith: ("alpha", "lpha", "a"), failWith: ("123", "1"))
    }
    
    func testParser(p : Parser<Character>, passWith : (String, String, Character), failWith : (String, Character)) {
        let passResult = p.parse(passWith.0)
        let failResult = p.parse(failWith.0)
        
        assertEqual(passResult, succeed(passWith.1, passWith.2))
        assertEqual(failResult, failWithUnexpectedChar(failWith.1))
    }
}

// Return a parser that sequences the given list of parsers by producing all their results
// but fails on the first failing parser of the list.
//
// Hint: - Use flatMap, valueParser and Array.reduceRight.
//       - There is a `cons : (A, [A]) -> [A]` helper function if that helps.
public func sequenceParser<A>(pp : [Parser<A>]) -> Parser<[A]> {
    // Initial version:
    //    return pp.reduceRight(valueParser([]), combine: { (p, acc) in p.flatMap({ a in acc.map(cons2(a)) }) })
    // Extension using apply/<*>
    return pp.reduceRight(valueParser([]), combine: { (p, acc) in cons2 <^> p <*> acc })
}

class Ex05_16_SequenceParserExamples : XCTestCase {
    let exampleParsers = [ character(), charIs("x"), upper() ]
    func testSequence() {
        let result = sequenceParser(exampleParsers).map(charsToString).parse("axCdef")
        assertEqual(result, succeed("def", "axC"))
    }
    func testSequenceWithUnexpectedChar() {
        let result = sequenceParser(exampleParsers).map(charsToString).parse("abCdef")
        assertEqual(result, failWithUnexpectedChar("b"))
    }
}

// Return a parser that produces the given number of values off the given parser.
// This parser fails if the given parser fails in the attempt to produce the given number of values.
//
// Hint: Use sequenceParser and replicate (replicate : (Integer, A) -> [A])
public func thisMany<A>(n : Int, p : Parser<A>) -> Parser<[A]> {
    return sequenceParser(replicate(n, p))
}

class Ex05_17_ThisManyExamples : XCTestCase {
    func testThisMany() {
        let result = thisMany(4, upper()).map(charsToString).parse("ABCDefg")
        assertEqual(result, succeed("efg", "ABCD"))
    }
    func testThisManyWithUnexpectedChar() {
        let result = thisMany(4, upper()).map(charsToString).parse("AbCDefg")
        assertEqual(result, failWithUnexpectedChar("b"))
    }
}


// Suppose we have a data structure to represent a person. The person data structure has these attributes:
//     * Age: positive integer
//     * First Name: non-empty string that starts with a capital letter and is followed by zero or more lower-case letters
//     * Surname: string that starts with a capital letter and is followed by 5 or more lower-case letters
//     * Smoker: Boolean value. When parsing, this is represented as a character that must be 'y' or 'n'
//     * Phone: string of digits, dots or hyphens but must start with a digit and end with a hash (#)
public struct Person : Printable, Equatable {
    let age : Int
    let firstName : String
    let surname : String
    let smoker : Bool
    let phone : String
    public var description : String {
        return "Person { age: \(self.age), firstName: \(self.firstName), surname: \(self.surname), smoker: \(self.smoker), phone: \(self.phone) }"
    }
    public static func create(age:Int)(firstName:String)(surname:String)(smoker:Bool)(phone:String) -> Person {
        return Person(age: age, firstName: firstName, surname: surname, smoker: smoker, phone: phone)
    }
}

// Return a parser for age. Age must be a positive integer.
public func ageParser() -> Parser<Int> {
    return natural()
}

// Return a parser for first name.
// First name must be non-empty, start with a capital letter, and be followed by zero or more lower-case letters
//
// Hint: use parser.map(charsToString) to convert a parser of [Character] to a parser of String.
public func firstNameParser() -> Parser<String> {
    return upper().flatMap({ x in list(lower()).map(cons2(x)) })
                  .map(charsToString)
}

class Ex05_18_FirstNameParserExamples : XCTestCase {
    func testFirstNameParser() {
        let result = firstNameParser().parse("Daniel")
        assertEqual(result, succeed("", "Daniel"))
    }
    func testParseUntilUnmatchedCharacter() {
        let result = firstNameParser().parse("RobeRt")
        assertEqual(result, succeed("Rt", "Robe"))
    }
    func testParseUntilUnmatchedCharacter2() {
        let result = firstNameParser().parse("Matt$1")
        assertEqual(result, succeed("$1", "Matt"))
    }
    func testFailOnNonMatching() {
        let result = firstNameParser().parse("timothy")
        assertEqual(result, failWithUnexpectedChar("t"))
    }
}

// Return a parser for surname.
// Surname starts with a capital letter and is followed by 5 or more lower-case letters
public func surnameParser() -> Parser<String> {
    return upper()              .flatMap({ c in
           thisMany(5, lower()) .flatMap({ cs in
           list(lower())        .flatMap({ rest in
                valueParser(cons(c, cs) + rest)
            })})}).map(charsToString)
}

class Ex05_19_SurnameParserExamples : XCTestCase {
    func testFirstNameParser() {
        let result = surnameParser().parse("Something")
        assertEqual(result, succeed("", "Something"))
    }
    func testParseUntilUnmatchedCharacter() {
        let result = surnameParser().parse("Something2")
        assertEqual(result, succeed("2", "Something"))
    }
    func testFailOnNonMatchingCapital() {
        let result = surnameParser().parse("lowercase")
        assertEqual(result, failWithUnexpectedChar("l"))
    }
    func testFailOnNotLongEnough() {
        let result = surnameParser().parse("Last ")
        assertEqual(result, failWithUnexpectedChar(" "))
    }
    func testFailOnNotLongEnough2() {
        let result = surnameParser().parse("LastName 1")
        assertEqual(result, failWithUnexpectedChar("N"))
    }
    func testFailOnNotLongEnough3() {
        let result = surnameParser().parse("Last")
        assertEqual(result, failWithUnexpectedEof())
    }
}


// Return a bool indicating whether a person is a smoker.
// Smoker field is true if "y", or non-smoker if "n"
//
// Hint: use charIs, ||| and valueParser
public func smokerParser() -> Parser<Bool> {
    return (charIs("y") >>> valueParser(true)) ||| (charIs("n") >>> valueParser(false))
}

class Ex20_SmokerParserExamples : XCTestCase {
    func testY() {
        let result = smokerParser().parse("y")
        assertEqual(result, succeed("", true))
    }
    func testN() {
        let result = smokerParser().parse("n")
        assertEqual(result, succeed("", false))
    }
    func testUnexpectedChar() {
        let result = smokerParser().parse("x")
        assertEqual(result, failWithUnexpectedChar("x"))
    }
    func testUnexpectedEof() {
        let result = smokerParser().parse("")
        assertEqual(result, failWithUnexpectedEof())
    }
}


// Write part of a parser for the body of Person's phone number field.
// This parser will only produce a string of digits, dots or hyphens.
// It will ignore the overall requirement of a phone number to
// start with a digit and end with a hash (#).
//
// Hint: Use list, digit, ||| and charIs.
public func phoneBodyParser() -> Parser<String> {
    return list( digit() ||| charIs(".") ||| charIs("-") ).map(charsToString)
}

class Ex21_PhoneBodyExamples : XCTestCase {
    func testPhoneBodyParser() {
        let result = phoneBodyParser().parse("123-456")
        assertEqual(result, succeed("", "123-456"))
    }
    func testParseUntilUnmatchedCharacter() {
        let result = phoneBodyParser().parse("123-4a56")
        assertEqual(result, succeed("a56", "123-4"))
    }
    func testParseUntilUnmatchedCharacter2() {
        let result = phoneBodyParser().parse("a123-456")
        assertEqual(result, succeed("a123-456", ""))
    }
}

// Write a parser for Person.phone. Uses phoneBody, but must start with a digit
// and end with a hash (#). The parser should parse up to and included the "#",
// but not include the hash in the final output. e.g. "123-456#" -> "123-456.
//
// Hint: - Use flatMap, valueParser, digit, phoneBodyParser and charIs.
//       - Use String(c) to convert a Character c to a String.
public func phoneParser() -> Parser<String> {
    return digit().flatMap({ start in
           phoneBodyParser().flatMap( { body in
           charIs("#") >>> valueParser(String(start) + body)
        })})
}

class Ex22_PhoneParserExamples : XCTestCase {
    func testValidPhone() {
        let result = phoneParser().parse("123-456#")
        assertEqual(result, succeed("", "123-456"))
    }
    func testValidPhoneWithLeftOvers() {
        let result = phoneParser().parse("123-456#abc")
        assertEqual(result, succeed("abc", "123-456"))
    }
    func testPhoneNumberWithoutTerminatingHash() {
        let result = phoneParser().parse("123-456")
        assertEqual(result, failWithUnexpectedEof())
    }
    func testPhoneNumberWithInvalidChar() {
        let result = phoneParser().parse("a123-456")
        assertEqual(result, failWithUnexpectedChar("a"))
    }
}

// Write a parser for Person with age, firstname, surname, smoker, phone fields separated by one
// or more spaces. Example of valid Person record: "123 Fred Clarkson y 123-456.789#"
//
// Hint Use flatMap,
//          valueParser,
//          (>>>),
//          spaces,
//          ageParser,
//          firstNameParser,
//          surnameParser,
//          smokerParser,
//          phoneParser.
public func personParser() -> Parser<Person> {
    return Person.create
            <^> ageParser()
            <*> (spaces() >>> firstNameParser())
            <*> (spaces() >>> surnameParser())
            <*> (spaces() >>> smokerParser())
            <*> (spaces() >>> phoneParser())
}

class Ex23_PersonParserExamples : XCTestCase {
    func testValid() {
        let result = personParser().parse("123 Fred Clarkson y 123-456.789#")
        let expected = Person(age: 123, firstName: "Fred", surname: "Clarkson", smoker: true, phone: "123-456.789")
        assertEqual(result, succeed("", expected))
    }
    func testValidWithLeftOvers() {
        let result = personParser().parse("123 Fred Clarkson y 123-456.789# rest")
        let expected = Person(age: 123, firstName: "Fred", surname: "Clarkson", smoker: true, phone: "123-456.789")
        assertEqual(result, succeed(" rest", expected))
    }
    func testEmptyInput() {
        let result = personParser().parse("")
        assertEqual(result, failWithUnexpectedEof())
    }
    func testInvalidAge() {
        let result = personParser().parse("12x Fred Clarkson y 123-456.789#")
        assertEqual(result, failWithUnexpectedChar("x"))
    }
    func testInvalidFirstName() {
        let result = personParser().parse("123 fred Clarkson y 123-456.789#")
        assertEqual(result, failWithUnexpectedChar("f"))
    }
    func testInvalidLastName() {
        let result = personParser().parse("123 Fred clarkson y 123-456.789#")
        assertEqual(result, failWithUnexpectedChar("c"))
    }
    func testLastNameTooShort() {
        let result = personParser().parse("123 Fred Cla y 123-456.789#")
        assertEqual(result, failWithUnexpectedChar(" "))
    }
    func testInvalidSmokerField() {
        let result = personParser().parse("123 Fred Clarkson x 123-456.789#")
        assertEqual(result, failWithUnexpectedChar("x"))
    }
    func testInvalidPhone() {
        let result = personParser().parse("123 Fred Clarkson y -123-456.789#")
        assertEqual(result, failWithUnexpectedChar("-"))
    }
    func testUnterminatedPhone() {
        let result = personParser().parse("123 Fred Clarkson y 123-456.789")
        assertEqual(result, failWithUnexpectedEof())
    }
}


// EXTENSIONS
// - implement apply operator <*>
public func <*><A,B>(f : Parser<A->B>, p: Parser<A>) -> Parser<B> {
    return f.flatMap({ ff in p.map({ ff($0) }) })
}
// - implement sequenceParser using the apply operator <*>. Use reduceRight, valueParser, <*> and cons2 (curried cons function)
// - implement personParser using the apply operator and a curried Person constructor

// END EXERCISES


// Misc helper functions
func toUpper(c : Character) -> Character {
    return first(String(c).uppercaseString) ?? c
}
let isUpperCase = charIsInSet(NSCharacterSet.uppercaseLetterCharacterSet())
let isLowerCase = charIsInSet(NSCharacterSet.lowercaseLetterCharacterSet())
let isSpace = charIsInSet(NSCharacterSet.whitespaceCharacterSet())
let isAlpha = charIsInSet(NSCharacterSet.letterCharacterSet())
func isDigit(c : Character) -> Bool {
    return ("0"..."9") ~= c
}
func parseIntOr0(cc : [Character]) -> Int {
    return charsToString(cc).toInt() ?? 0
}
func charsToString(cc : [Character]) -> String {
    return String(cc)
}
func charIsInSet(cset : NSCharacterSet)(c : Character) -> Bool {
    let s = String(c).utf16
    // If unicode char has a component in this set, let's say it is a member.
    // No idea if this is correct, but it at least works for the inputs in this file.
    for codeUnit in s {
        if cset.characterIsMember(codeUnit) {
            return true
        }
    }
    return false
}
func cons<A>(a :A, aa:[A]) -> [A] {
    return [a] + aa
}
func cons2<A>(a :A)-> [A] -> [A] {
    return { aa in [a] + aa }
}
extension Array {
    func reduceRight<A>(defaultValue: A, combine: (T, A) -> A) -> A {
        var v = defaultValue
        for item in self.reverse() {
            v = combine(item, v)
        }
        return v
    }
}
func replicate<A>(n : Int, a :A) -> [A] {
    return (1...n).map({ _ in a })
}


// Assertion helpers
func assertEqual<T : Equatable>(actual : ParseResult<T>, expected : ParseResult<T>, file: String = __FILE__, line: UInt = __LINE__) {
    XCTAssert(actual == expected, "Expected: \(expected.description), Actual: \(actual.description)", file: file, line: line)
}
func assertEqual<T : Equatable>(actual : ParseResult<[T]>, expected : ParseResult<[T]>, file: String = __FILE__, line: UInt = __LINE__) {
    XCTAssert(actual == expected, "Expected: \(expected.description), Actual: \(actual.description)", file: file, line: line)
}

// Equality operators
public func ==(lhs: ParseError, rhs: ParseError) -> Bool {
    let p = (lhs, rhs)
    switch p {
    case (.UnexpectedEof, .UnexpectedEof): return true
    case (.ExpectedEof(let i1), .ExpectedEof(let i2)): return i1 == i2
    case (.UnexpectedChar(let c1), .UnexpectedChar(let c2)): return c1 == c2
    case (.Failed(let s1), .Failed(let s2)): return s1 == s2
    default: return false
    }
}
public func ==<A: Equatable>(lhs: ParseResult<A>, rhs: ParseResult<A>) -> Bool {
    switch (lhs, rhs) {
    case (.ErrorResult(let e1), .ErrorResult(let e2)): return e1 == e2
    case (.Result(let i1, let a1), .Result(let i2, let a2)): return i1 == i2 && a1.value == a2.value
    default: return false
    }
}
public func ==<A: Equatable>(lhs: ParseResult<[A]>, rhs: ParseResult<[A]>) -> Bool {
    switch (lhs, rhs) {
    case (.ErrorResult(let e1), .ErrorResult(let e2)): return e1 == e2
    case (.Result(let i1, let a1), .Result(let i2, let a2)): return i1 == i2 && a1.value == a2.value
    default: return false
    }
}
public func ==(lhs: Person, rhs: Person) -> Bool {
    return lhs.age       == rhs.age
        && lhs.firstName == rhs.firstName
        && lhs.surname   == rhs.surname
        && lhs.smoker    == rhs.smoker
        && lhs.phone     == rhs.phone
}

// Custom Operators
public func <^><A,B>(f : A->B, p: Parser<A>) -> Parser<B> {
    return p.map(f)
}
public func >>-<A,B>(p : Parser<A>, f : A -> Parser<B>) -> Parser<B> {
    return p.flatMap(f)
}
