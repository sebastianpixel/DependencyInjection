public protocol Registration {
    var identifier: ObjectIdentifier { get }
    var aliases: [ObjectIdentifier]? { get }
    var initializer: () -> Any { get set }
    var arguments: [Any] { get set }

    init<T>(typeAliases: [Any.Type]?, initializer: @escaping () -> T)
}

// MARK: - Convenience Initializers

public extension Registration {
    init<T>(_ initializer: @escaping () -> T) {
        self.init(typeAliases: nil, initializer: initializer)
    }

    init<T>(_ initializer: @escaping @autoclosure () -> T) {
        self.init(typeAliases: nil, initializer: initializer)
    }

    init<T>(_ initializer: @escaping (Resolver) -> T) {
        self.init(typeAliases: nil) { initializer(DIContainer.resolve) }
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

// MARK: - Parameterized Resolution without Type Aliases

// swiftlint:disable force_cast
public extension Registration {
    init<T, A0>(_ initializer: @escaping (Resolver, A0) -> T) {
        let _initializer: () -> T = { fatalError() }
        self.init(typeAliases: nil, initializer: _initializer)
        self.initializer = { [self] in
            initializer(
                DIContainer.resolve,
                self.arguments[0] as! A0
            )
        }
    }

    init<T, A0, A1>(_ initializer: @escaping (Resolver, A0, A1) -> T) {
        let _initializer: () -> T = { fatalError() }
        self.init(typeAliases: nil, initializer: _initializer)
        self.initializer = { [self] in
            initializer(
                DIContainer.resolve,
                self.arguments[0] as! A0,
                self.arguments[1] as! A1
            )
        }
    }

    init<T, A0, A1, A2>(_ initializer: @escaping (Resolver, A0, A1, A2) -> T) {
        let _initializer: () -> T = { fatalError() }
        self.init(typeAliases: nil, initializer: _initializer)
        self.initializer = { [self] in
            initializer(
                DIContainer.resolve,
                self.arguments[0] as! A0,
                self.arguments[1] as! A1,
                self.arguments[2] as! A2
            )
        }
    }

    init<T, A0, A1, A2, A3>(_ initializer: @escaping (Resolver, A0, A1, A2, A3) -> T) {
        let _initializer: () -> T = { fatalError() }
        self.init(typeAliases: nil, initializer: _initializer)
        self.initializer = { [self] in
            initializer(
                DIContainer.resolve,
                self.arguments[0] as! A0,
                self.arguments[1] as! A1,
                self.arguments[2] as! A2,
                self.arguments[3] as! A3
            )
        }
    }

    init<T, A0, A1, A2, A3, A4>(_ initializer: @escaping (Resolver, A0, A1, A2, A3, A4) -> T) {
        let _initializer: () -> T = { fatalError() }
        self.init(typeAliases: nil, initializer: _initializer)
        self.initializer = { [self] in
            initializer(
                DIContainer.resolve,
                self.arguments[0] as! A0,
                self.arguments[1] as! A1,
                self.arguments[2] as! A2,
                self.arguments[3] as! A3,
                self.arguments[4] as! A4
            )
        }
    }

    init<T, A0, A1, A2, A3, A4, A5>(_ initializer: @escaping (Resolver, A0, A1, A2, A3, A4, A5) -> T) {
        let _initializer: () -> T = { fatalError() }
        self.init(typeAliases: nil, initializer: _initializer)
        self.initializer = { [self] in
            initializer(
                DIContainer.resolve,
                self.arguments[0] as! A0,
                self.arguments[1] as! A1,
                self.arguments[2] as! A2,
                self.arguments[3] as! A3,
                self.arguments[4] as! A4,
                self.arguments[5] as! A5
            )
        }
    }

    init<T, A0, A1, A2, A3, A4, A5, A6>(_ initializer: @escaping (Resolver, A0, A1, A2, A3, A4, A5, A6) -> T) {
        let _initializer: () -> T = { fatalError() }
        self.init(typeAliases: nil, initializer: _initializer)
        self.initializer = { [self] in
            initializer(
                DIContainer.resolve,
                self.arguments[0] as! A0,
                self.arguments[1] as! A1,
                self.arguments[2] as! A2,
                self.arguments[3] as! A3,
                self.arguments[4] as! A4,
                self.arguments[5] as! A5,
                self.arguments[6] as! A6
            )
        }
    }

    init<T, A0, A1, A2, A3, A4, A5, A6, A7>(_ initializer: @escaping (Resolver, A0, A1, A2, A3, A4, A5, A6, A7) -> T) {
        let _initializer: () -> T = { fatalError() }
        self.init(typeAliases: nil, initializer: _initializer)
        self.initializer = { [self] in
            initializer(
                DIContainer.resolve,
                self.arguments[0] as! A0,
                self.arguments[1] as! A1,
                self.arguments[2] as! A2,
                self.arguments[3] as! A3,
                self.arguments[4] as! A4,
                self.arguments[5] as! A5,
                self.arguments[6] as! A6,
                self.arguments[7] as! A7
            )
        }
    }

    init<T, A0, A1, A2, A3, A4, A5, A6, A7, A8>(_ initializer: @escaping (Resolver, A0, A1, A2, A3, A4, A5, A6, A7, A8) -> T) {
        let _initializer: () -> T = { fatalError() }
        self.init(typeAliases: nil, initializer: _initializer)
        self.initializer = { [self] in
            initializer(
                DIContainer.resolve,
                self.arguments[0] as! A0,
                self.arguments[1] as! A1,
                self.arguments[2] as! A2,
                self.arguments[3] as! A3,
                self.arguments[4] as! A4,
                self.arguments[5] as! A5,
                self.arguments[6] as! A6,
                self.arguments[7] as! A7,
                self.arguments[8] as! A8
            )
        }
    }

    init<T, A0, A1, A2, A3, A4, A5, A6, A7, A8, A9>(_ initializer: @escaping (Resolver, A0, A1, A2, A3, A4, A5, A6, A7, A8, A9) -> T) {
        let _initializer: () -> T = { fatalError() }
        self.init(typeAliases: nil, initializer: _initializer)
        self.initializer = { [self] in
            initializer(
                DIContainer.resolve,
                self.arguments[0] as! A0,
                self.arguments[1] as! A1,
                self.arguments[2] as! A2,
                self.arguments[3] as! A3,
                self.arguments[4] as! A4,
                self.arguments[5] as! A5,
                self.arguments[6] as! A6,
                self.arguments[7] as! A7,
                self.arguments[8] as! A8,
                self.arguments[9] as! A9
            )
        }
    }
}

// MARK: - Parameterized Resolution with Type Aliases

public extension Registration {
    init<T, A0>(_ initializer: @escaping (Resolver, A0) -> T, as typeAliases: Any.Type...) {
        let _initializer: () -> T = { fatalError() }
        self.init(typeAliases: typeAliases, initializer: _initializer)
        self.initializer = { [self] in
            initializer(
                DIContainer.resolve,
                self.arguments[0] as! A0
            )
        }
    }

    init<T, A0, A1>(_ initializer: @escaping (Resolver, A0, A1) -> T, as typeAliases: Any.Type...) {
        let _initializer: () -> T = { fatalError() }
        self.init(typeAliases: typeAliases, initializer: _initializer)
        self.initializer = { [self] in
            initializer(
                DIContainer.resolve,
                self.arguments[0] as! A0,
                self.arguments[1] as! A1
            )
        }
    }

    init<T, A0, A1, A2>(_ initializer: @escaping (Resolver, A0, A1, A2) -> T, as typeAliases: Any.Type...) {
        let _initializer: () -> T = { fatalError() }
        self.init(typeAliases: typeAliases, initializer: _initializer)
        self.initializer = { [self] in
            initializer(
                DIContainer.resolve,
                self.arguments[0] as! A0,
                self.arguments[1] as! A1,
                self.arguments[2] as! A2
            )
        }
    }

    init<T, A0, A1, A2, A3>(_ initializer: @escaping (Resolver, A0, A1, A2, A3) -> T, as typeAliases: Any.Type...) {
        let _initializer: () -> T = { fatalError() }
        self.init(typeAliases: typeAliases, initializer: _initializer)
        self.initializer = { [self] in
            initializer(
                DIContainer.resolve,
                self.arguments[0] as! A0,
                self.arguments[1] as! A1,
                self.arguments[2] as! A2,
                self.arguments[3] as! A3
            )
        }
    }

    init<T, A0, A1, A2, A3, A4>(_ initializer: @escaping (Resolver, A0, A1, A2, A3, A4) -> T, as typeAliases: Any.Type...) {
        let _initializer: () -> T = { fatalError() }
        self.init(typeAliases: typeAliases, initializer: _initializer)
        self.initializer = { [self] in
            initializer(
                DIContainer.resolve,
                self.arguments[0] as! A0,
                self.arguments[1] as! A1,
                self.arguments[2] as! A2,
                self.arguments[3] as! A3,
                self.arguments[4] as! A4
            )
        }
    }

    init<T, A0, A1, A2, A3, A4, A5>(_ initializer: @escaping (Resolver, A0, A1, A2, A3, A4, A5) -> T, as typeAliases: Any.Type...) {
        let _initializer: () -> T = { fatalError() }
        self.init(typeAliases: typeAliases, initializer: _initializer)
        self.initializer = { [self] in
            initializer(
                DIContainer.resolve,
                self.arguments[0] as! A0,
                self.arguments[1] as! A1,
                self.arguments[2] as! A2,
                self.arguments[3] as! A3,
                self.arguments[4] as! A4,
                self.arguments[5] as! A5
            )
        }
    }

    init<T, A0, A1, A2, A3, A4, A5, A6>(_ initializer: @escaping (Resolver, A0, A1, A2, A3, A4, A5, A6) -> T, as typeAliases: Any.Type...) {
        let _initializer: () -> T = { fatalError() }
        self.init(typeAliases: typeAliases, initializer: _initializer)
        self.initializer = { [self] in
            initializer(
                DIContainer.resolve,
                self.arguments[0] as! A0,
                self.arguments[1] as! A1,
                self.arguments[2] as! A2,
                self.arguments[3] as! A3,
                self.arguments[4] as! A4,
                self.arguments[5] as! A5,
                self.arguments[6] as! A6
            )
        }
    }

    init<T, A0, A1, A2, A3, A4, A5, A6, A7>(_ initializer: @escaping (Resolver, A0, A1, A2, A3, A4, A5, A6, A7) -> T, as typeAliases: Any.Type...) {
        let _initializer: () -> T = { fatalError() }
        self.init(typeAliases: typeAliases, initializer: _initializer)
        self.initializer = { [self] in
            initializer(
                DIContainer.resolve,
                self.arguments[0] as! A0,
                self.arguments[1] as! A1,
                self.arguments[2] as! A2,
                self.arguments[3] as! A3,
                self.arguments[4] as! A4,
                self.arguments[5] as! A5,
                self.arguments[6] as! A6,
                self.arguments[7] as! A7
            )
        }
    }

    init<T, A0, A1, A2, A3, A4, A5, A6, A7, A8>(_ initializer: @escaping (Resolver, A0, A1, A2, A3, A4, A5, A6, A7, A8) -> T, as typeAliases: Any.Type...) {
        let _initializer: () -> T = { fatalError() }
        self.init(typeAliases: typeAliases, initializer: _initializer)
        self.initializer = { [self] in
            initializer(
                DIContainer.resolve,
                self.arguments[0] as! A0,
                self.arguments[1] as! A1,
                self.arguments[2] as! A2,
                self.arguments[3] as! A3,
                self.arguments[4] as! A4,
                self.arguments[5] as! A5,
                self.arguments[6] as! A6,
                self.arguments[7] as! A7,
                self.arguments[8] as! A8
            )
        }
    }

    init<T, A0, A1, A2, A3, A4, A5, A6, A7, A8, A9>(_ initializer: @escaping (Resolver, A0, A1, A2, A3, A4, A5, A6, A7, A8, A9) -> T, as typeAliases: Any.Type...) {
        let _initializer: () -> T = { fatalError() }
        self.init(typeAliases: typeAliases, initializer: _initializer)
        self.initializer = { [self] in
            initializer(
                DIContainer.resolve,
                self.arguments[0] as! A0,
                self.arguments[1] as! A1,
                self.arguments[2] as! A2,
                self.arguments[3] as! A3,
                self.arguments[4] as! A4,
                self.arguments[5] as! A5,
                self.arguments[6] as! A6,
                self.arguments[7] as! A7,
                self.arguments[8] as! A8,
                self.arguments[9] as! A9
            )
        }
    }
}
// swiftlint:enable force_cast
