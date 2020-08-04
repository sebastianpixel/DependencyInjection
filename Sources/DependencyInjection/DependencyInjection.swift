import Foundation

@propertyWrapper
public struct Inject<T> {
    public var wrappedValue: T

    public init() {
        wrappedValue = DIContainer.resolve(T.self)
    }
}

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

public final class DIContainer {
    public static let register = shared as Registrar
    public static let resolve = shared as Resolver

    private static let shared = DIContainer()

    private let queue = ReentrantSyncQueue(label: "dependency_injection_resolving")

    private var registrations = [ObjectIdentifier: Registration]()
    private var sharedInstances = [ObjectIdentifier: Any]()
    private var typeAliases = [ObjectIdentifier: ObjectIdentifier]()

    private init() {}

    static func cleanUpForTesting() {
        shared.registrations.removeAll()
        shared.sharedInstances.removeAll()
        shared.typeAliases.removeAll()
    }
}

public protocol Resolver {
    func callAsFunction<T>() -> T
    func callAsFunction<T>(_: T.Type) -> T
    func callAsFunction<T, A0>(_: T.Type, withParameters: A0)
}

extension DIContainer: Resolver {

    public func callAsFunction<T>() -> T {
        callAsFunction(T.self)
    }

    public func callAsFunction<T, A0>(_: T.Type, withParameters: A0) {

    }

    public func callAsFunction<T>(_: T.Type) -> T {
        let identifier = self.identifier(T.self)

        guard let registration = registrations[identifier] else {
            if let optional = T.self as? (ExpressibleByNilLiteral & OptionalProtocol).Type {
                return optional.init(nilLiteral: ()) as! T // swiftlint:disable:this force_cast
            } else {
                fatalError("Configuration error: No initializer registered for type \"\(T.self)\".")
            }
        }

        return registration is New
            ? initialize(registration.initializer)
            : queue.sync {
                let value = sharedInstances[identifier]
                if value != nil,
                    let sharedInstance = value as? T {
                    return sharedInstance
                }
                let instance = initialize(registration.initializer) as T
                sharedInstances[identifier] = instance
                return instance
        }
    }

    private func identifier<T>(_ type: T.Type) -> ObjectIdentifier {
        let identifier = (T.self as? OptionalProtocol.Type)?.wrappedObjectIdentifier ?? .init(T.self)
        return typeAliases[identifier, default: identifier]
    }

    private func initialize<T>(_ initializer: () -> Any) -> T {
        let instance = initializer()
        if let instance = instance as? T {
            return instance
        } else {
            // swiftlint:disable:next line_length
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

@_functionBuilder
public struct ModuleBuilder {
    public static func buildBlock(_ modules: Module...) -> [Module] {
        modules
    }
}

public protocol Registrar {
    func callAsFunction(@RegistrationBuilder _ registrations: () -> [Registration])
    func callAsFunction(@RegistrationBuilder _ registration: () -> Registration)
    func callAsFunction(_ registration: Registration)

    func callAsFunction(@ModuleBuilder _ modules: () -> [Module])
    func callAsFunction(@ModuleBuilder _ module: () -> Module)
    func callAsFunction(_ module: Module)
}

extension Registrar {
    public func callAsFunction(@RegistrationBuilder _ registrations: () -> [Registration]) {
        registrations().forEach(callAsFunction)
    }

    public func callAsFunction(_ registration: () -> Registration) {
        callAsFunction(registration())
    }

    public func callAsFunction(@ModuleBuilder _ modules: () -> [Module]) {
        modules().forEach(callAsFunction)
    }

    public func callAsFunction(_ modules: () -> Module) {
        callAsFunction(modules())
    }
}

extension DIContainer: Registrar {
    public func callAsFunction(_ registration: Registration) {
        registration.aliases?.forEach {
            typeAliases[$0] = registration.identifier
        }

        // Identifier is an alias for itself in case a previously
        // registered alias should be overridden e.g. for a test.
        typeAliases[registration.identifier] = registration.identifier

        self.registrations[registration.identifier] = registration
    }

    public func callAsFunction(_ module: Module) {
        module.registrations.forEach(callAsFunction)
    }
}

public struct Module {
    let registrations: [Registration]

    public init(registration: Registration) {
        registrations = [registration]
    }

    public init(@RegistrationBuilder _ registration: () -> Registration) {
        self.init(registration: registration())
    }

    public init(@RegistrationBuilder _ registrations: () -> [Registration]) {
        self.registrations = registrations()
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

    init<T>(_ initializer: @escaping @autoclosure () -> T, as typeAliases: Any.Type...) {
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

private protocol OptionalProtocol {
    static var wrappedObjectIdentifier: ObjectIdentifier { get }
}

extension Optional: OptionalProtocol {
    static var wrappedObjectIdentifier: ObjectIdentifier {
        .init(Wrapped.self)
    }
}
