import Foundation

@propertyWrapper
public struct Inject<T> {
    public let wrappedValue: T

    public init() {
        wrappedValue = DIContainer.shared.resolve(T.self)
    }
}

@propertyWrapper
public class LazyInject<T> {

    private var value: T?

    public var wrappedValue: T {
        if let value = value {
            return value
        } else {
            let value = DIContainer.shared.resolve(T.self)
            self.value = value
            return value
        }
    }

    public init() {}
}

public protocol Resolver {
    func resolve<T>() -> T
    func resolve<T>(_: T.Type) -> T
}

public final class DIContainer {
    private var registrations = [ObjectIdentifier: Registration]()
    private var sharedInstances = [ObjectIdentifier: Any]()
    private var typeAliases = [ObjectIdentifier: ObjectIdentifier]()

    public static let shared = DIContainer()

    private init() {}
}

extension DIContainer: Resolver {

    public func resolve<T>() -> T {
        resolve(T.self)
    }

    public func resolve<T>(_: T.Type) -> T {
        let identifier = ObjectIdentifier(T.self)
        let type = typeAliases[identifier] ?? identifier

        guard let registration = registrations[type] else {
            fatalError("Configuration error: No initializer registered for type \"\(T.self)\".")
        }

        if registration is New {
            return initialize(registration.initializer)
        } else {
            if let sharedInstance = sharedInstances[type] as? T {
                return sharedInstance
            }
            let instance = initialize(registration.initializer) as T
            sharedInstances[type] = instance
            return instance
        }
    }

    private func initialize<T>(_ initializer: () -> Any) -> T {
        let instance = initializer()
        if let instance = instance as? T {
            return instance
        } else {
            fatalError("Configuration error: Could not cast instance of type \"\(type(of: instance))\" to type \"\(T.self)\".")
        }
    }
}

extension DIContainer {

    @_functionBuilder
    public struct RegistrationBuilder {
        public static func buildBlock(_ routes: Registration...) -> [Registration] {
            routes
        }
    }

    public func register(@RegistrationBuilder _ registrations: () -> [Registration]) {
        registrations().forEach(register)
    }

    public func register(_ registration: Registration) {
        registration.aliases?.forEach {
            typeAliases[$0] = registration.identifier
        }
        self.registrations[registration.identifier] = registration
    }
}

public protocol Registration {
    var identifier: ObjectIdentifier { get }
    var aliases: [ObjectIdentifier]? { get }
    var initializer: () -> Any { get }

    init<T>(typeAliases: [Any.Type]?, initializer: @escaping () -> T)
}

public extension Registration {
    init<T>(_ initializer: @escaping () -> T) {
        self.init(typeAliases: nil, initializer: initializer)
    }

    init<T>(_ initializer: @escaping @autoclosure () -> T) {
        self.init(initializer)
    }

    init<T>(_ initializer: @escaping (Resolver) -> T) {
        self.init { initializer(DIContainer.shared) }
    }

    init<T>(_ initializer: @escaping () -> T, as typeAliases: Any.Type...) {
        self.init(typeAliases: typeAliases, initializer: initializer)
    }

    init<T>(_ initializer: @autoclosure @escaping () -> T, as typeAliases: Any.Type...) {
        self.init(typeAliases: typeAliases, initializer: initializer)
    }

    init<T>(_ initializer: @escaping (Resolver) -> T, as typeAliases: Any.Type...) {
        self.init(typeAliases: typeAliases) { initializer(DIContainer.shared) }
    }
}

public struct New: Registration {
    public let identifier: ObjectIdentifier
    public let aliases: [ObjectIdentifier]?
    public let initializer: () -> Any

    public init<T>(typeAliases: [Any.Type]?, initializer: @escaping () -> T) {
        self.identifier = ObjectIdentifier(T.self)
        self.aliases = typeAliases?.map(ObjectIdentifier.init)
        self.initializer = initializer
    }
}

public struct Shared: Registration {
    public let identifier: ObjectIdentifier
    public let aliases: [ObjectIdentifier]?
    public let initializer: () -> Any

    public init<T>(typeAliases: [Any.Type]?, initializer: @escaping () -> T) {
        self.identifier = ObjectIdentifier(T.self)
        self.aliases = typeAliases?.map(ObjectIdentifier.init)
        self.initializer = initializer
    }
}
