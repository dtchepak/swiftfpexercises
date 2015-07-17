
/// Originally from: https://github.com/typelift/Swiftx/blob/e0997a4b43fab5fb0f3d76506f7c2124b718920e/Swiftx/Box.swift
/// Edit: removed autoclosure due to change in Swift 1.2 (trying to keep compatibility with 1.2 and 1.1)
/// An immutable reference type holding a singular value.
///
/// Boxes are often used when the Swift compiler cannot infer the size of a struct or enum because
/// one of its generic types is being used as a member.
public final class Box<T> {
    public let value : T
    public init(_ value : T) {
        self.value = value
    }
}