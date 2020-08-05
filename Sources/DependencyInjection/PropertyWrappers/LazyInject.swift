@propertyWrapper
public struct LazyInject<T> {
    private var value: T?

    public var wrappedValue: T {
        mutating get {
            if let value = value {
                return value
            } else {
                let value = DIContainer.resolve(T.self)
                self.value = value
                return value
            }
        }
        set {
            value = newValue
        }
    }

    public init() {}
}
