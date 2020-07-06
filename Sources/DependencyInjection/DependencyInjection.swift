import Foundation

@propertyWrapper
public struct Inject<T> {
    public let wrappedValue: T

    public init() {
        wrappedValue = DIContainer.resolve(T.self)
    }
}

@propertyWrapper
public class LazyInject<T> {
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

public final class DIContainer {
    private var registrations = [ObjectIdentifier: Registration]()
    private var sharedInstances = [ObjectIdentifier: Any]()
    private var typeAliases = [ObjectIdentifier: ObjectIdentifier]()

    private static let shared = DIContainer()

    static func cleanUpForTesting() {
        shared.registrations.removeAll()
        shared.sharedInstances.removeAll()
        shared.typeAliases.removeAll()
    }

    public static let register = shared as Registrar
    public static let resolve = shared as Resolver

    private init() {}

    fileprivate static let semaphore = DispatchSemaphore(value: 1)
}

public protocol Resolver {
    func callAsFunction<T>() -> T
    func callAsFunction<T>(_: T.Type) -> T
}

extension DIContainer: Resolver {

    public func callAsFunction<T>() -> T {
        callAsFunction(T.self)
    }

    public func callAsFunction<T>(_: T.Type) -> T {
        Self.semaphore.wait()
        defer { Self.semaphore.signal() }

        let identifier = (T.self as? OptionalProtocol.Type)?.wrappedObjectIdentifier ?? .init(T.self)
        let type = typeAliases[identifier, default: identifier]
        let registration: Registration

        if let reg = registrations[type] {
            registration = reg
        } else if let optional = T.self as? ExpressibleByNilLiteral.Type {
            // As "only the `Optional` type conforms to `ExpressibleByNilLiteral`"
            // it's safe to assume that T is an Optional for which no initializer
            // was registered.
            return optional.init(nilLiteral: ()) as! T
        } else {
            fatalError("Configuration error: No initializer registered for type \"\(T.self)\".")
        }

        if registration is New {
            return initialize(registration.initializer)
        } else {
            if !sharedInstances.isEmpty,
                let sharedInstance = sharedInstances[type] as? T {
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

@_functionBuilder
public struct RegistrationBuilder {
    public static func buildBlock(_ registrations: Registration...) -> [Registration] {
        registrations
    }
}

public protocol Registrar {
    func callAsFunction(@RegistrationBuilder _ registrations: () -> [Registration])
    func callAsFunction(@RegistrationBuilder _ registration: () -> Registration)
    func callAsFunction(_ registration: Registration)
}

extension DIContainer: Registrar {
    public func callAsFunction(@RegistrationBuilder _ registrations: () -> [Registration]) {
        registrations().forEach(callAsFunction)
    }

    public func callAsFunction(_ registration: () -> Registration) {
        callAsFunction(registration())
    }

    public func callAsFunction(_ registration: Registration) {
        registration.aliases?.forEach {
            typeAliases[$0] = registration.identifier
        }

        // Identifier is an alias for itself in case a previously
        // registered alias should be overridden e.g. for a test.
        typeAliases[registration.identifier] = registration.identifier

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
        self.init { initializer(DIContainer.resolve) }
    }

    init<T>(_ initializer: @escaping () -> T, as typeAliases: Any.Type...) {
        self.init(typeAliases: typeAliases, initializer: initializer)
    }

    init<T>(_ initializer: @autoclosure @escaping () -> T, as typeAliases: Any.Type...) {
        self.init(typeAliases: typeAliases, initializer: initializer)
    }

    init<T>(_ initializer: @escaping (Resolver) -> T, as typeAliases: Any.Type...) {
        self.init(typeAliases: typeAliases) { initializer(DIContainer.resolve) }
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

fileprivate protocol OptionalProtocol {
    static var wrappedObjectIdentifier: ObjectIdentifier { get }
}

extension Optional: OptionalProtocol {
    static var wrappedObjectIdentifier: ObjectIdentifier {
        return .init(Wrapped.self)
    }
}
