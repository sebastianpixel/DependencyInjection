@propertyWrapper
public struct Inject<T> {
    public var wrappedValue: T

    public init() {
        wrappedValue = DIContainer.resolve(T.self)
    }
}
