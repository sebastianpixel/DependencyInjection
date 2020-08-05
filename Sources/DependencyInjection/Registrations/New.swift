public class New: Registration {
    public let identifier: ObjectIdentifier
    public let aliases: [ObjectIdentifier]?
    public var initializer: () -> Any
    public var arguments = [Any]()

    required public init<T>(typeAliases: [Any.Type]?, initializer: @escaping () -> T) {
        self.identifier = ObjectIdentifier(T.self)
        self.aliases = typeAliases?.map(ObjectIdentifier.init)
        self.initializer = initializer
    }
}
