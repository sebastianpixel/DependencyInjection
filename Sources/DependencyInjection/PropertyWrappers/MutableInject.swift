@propertyWrapper
public struct MutableInject<T> {
    public var wrappedValue: T

    public init() {
        wrappedValue = DIContainer.resolve(T.self)
    }
}
