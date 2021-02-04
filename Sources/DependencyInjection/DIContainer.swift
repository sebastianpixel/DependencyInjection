import Foundation

public final class DIContainer {
    public static var register: Registrar { shared }
    public static var resolve: Resolver { shared }

    static var shared = DIContainer()

    private let queue = ReentrantSyncQueue(label: "dependency_injection")

    private var registrations = [ObjectIdentifier: Registration]()
    private var sharedInstances = [ObjectIdentifier: Any]()
    private var typeAliases = [ObjectIdentifier: ObjectIdentifier]()

    private lazy var registerDependenciesOnce: Void = {
        if let registering = DIContainer.self as? DependencyRegistering.Type {
            registering.registerDependencies()
        }
    }()

    func cleanUpForTesting() {
        registrations.removeAll()
        sharedInstances.removeAll()
        typeAliases.removeAll()
    }
}

extension DIContainer: Registrar {
    public func callAsFunction(_ registration: Registration) {
        queue.sync {
            registration.aliases?.forEach {
                typeAliases[$0] = registration.identifier
            }

            // Identifier is an alias for itself in case a previously
            // registered alias should be overridden e.g. for a test.
            typeAliases[registration.identifier] = registration.identifier

            registrations[registration.identifier] = registration
        }
    }

    public func callAsFunction(_ module: Module) {
        module.registrations.forEach(callAsFunction)
    }
}

extension DIContainer: Resolver {

    public func callAsFunction<T>() -> T {
        callAsFunction(T.self)
    }

    public func callAsFunction<T>(_: T.Type) -> T {
        callAsFunction(T.self, arguments: [])
    }

    public func callAsFunction<T>(_: T.Type, arguments: [Any]) -> T {
        let identifier = self.identifier(T.self)

        return queue.sync {
            _ = registerDependenciesOnce

            guard var registration = registrations[identifier] else {
                return handleOptionalFallback(T.self)
            }
            registration.arguments = arguments

            if registration is New {
                return initialize(registration.initializer)
            } else {
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
    }

    private func handleOptionalFallback<T>(_ type: T.Type) -> T {
        if let optional = T.self as? (ExpressibleByNilLiteral & OptionalProtocol).Type {
            return optional.init(nilLiteral: ()) as! T // swiftlint:disable:this force_cast
        } else {
            fatalError("Configuration error: No initializer registered for type \"\(T.self)\".")
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

private protocol OptionalProtocol {
    static var wrappedObjectIdentifier: ObjectIdentifier { get }
}

extension Optional: OptionalProtocol {
    static var wrappedObjectIdentifier: ObjectIdentifier {
        .init(Wrapped.self)
    }
}
