// Custom Operators
infix operator <^> : MapApplyPrecedence    // map
infix operator <*> : MapApplyPrecedence   // apply

precedencegroup MapApplyPrecedence {
    associativity: left
    higherThan: RangeFormationPrecedence
}

infix operator >>- : FlatMapPrecedence    // flatMap
infix operator >>> : FlatMapPrecedence    // skip

precedencegroup FlatMapPrecedence {
    associativity: left
    higherThan: FunctionArrowPrecedence
}


infix operator ||| : LogicalDisjunctionPrecedence   // or

infix operator >=> : KleisliCompositionPrecedence    // Kleisli composition

precedencegroup KleisliCompositionPrecedence {
    associativity: right
    higherThan: FunctionArrowPrecedence
}

infix operator • : CompositionPrecedence // compose

precedencegroup CompositionPrecedence {
    associativity: right
}

public func •<A,B,C> (f : @escaping (B)->C, g : @escaping (A)->B) -> (A) -> C {
    return  { (x : A) in f(g(x)) }
}
