// Custom Operators
infix operator <^> {    // map
associativity left
precedence 138
}
infix operator <*> {    // apply
associativity left
precedence 138
}
infix operator >>- {    // flatMap
associativity left
precedence 90
}
infix operator >>> {    // skip
associativity left
precedence 90
}
infix operator ||| {    // or
associativity left
precedence 100
}
infix operator >=> {    // Kleisli composition
associativity right
precedence 90
}
infix operator • {      // compose
associativity right
}

public func •<A,B,C> (f : B->C, g : A->B) -> (A->C) {
    return  { (x : A) in f(g(x)) }
}
