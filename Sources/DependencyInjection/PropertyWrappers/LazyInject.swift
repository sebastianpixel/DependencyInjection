@propertyWrapper
public final class LazyInject<T> {
    private var value: T?

    public var wrappedValue: T {
        if let value = value {
            return value
        } else {
            let value = DIContainer.resolve(T.self)
            self.value = value
            return value
        }
    }

    public init() {}
}
