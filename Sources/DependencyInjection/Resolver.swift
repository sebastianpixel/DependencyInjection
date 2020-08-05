public protocol Resolver {
    func callAsFunction<T>() -> T
    func callAsFunction<T>(_: T.Type) -> T
    func callAsFunction<T>(_: T.Type, arguments: [Any]) -> T
}

public extension Resolver {
    func callAsFunction<T, A0>(_: T.Type = T.self, arguments: () -> A0) -> T {
        callAsFunction(T.self, arguments: [
            arguments()
        ])
    }

    func callAsFunction<T, A0, A1>(_: T.Type = T.self, arguments: () -> (A0, A1)) -> T {
        let arguments = arguments()
        return callAsFunction(T.self, arguments: [
            arguments.0,
            arguments.1
        ])
    }

    func callAsFunction<T, A0, A1, A2>(_: T.Type = T.self, arguments: () -> (A0, A1, A2)) -> T {
        let arguments = arguments()
        return callAsFunction(T.self, arguments: [
            arguments.0,
            arguments.1,
            arguments.2
        ])
    }

    func callAsFunction<T, A0, A1, A2, A3>(_: T.Type = T.self, arguments: () -> (A0, A1, A2, A3)) -> T {
        let arguments = arguments()
        return callAsFunction(T.self, arguments: [
            arguments.0,
            arguments.1,
            arguments.2,
            arguments.3
        ])
    }

    func callAsFunction<T, A0, A1, A2, A3, A4>(_: T.Type = T.self, arguments: () -> (A0, A1, A2, A3, A4)) -> T {
        let arguments = arguments()
        return callAsFunction(T.self, arguments: [
            arguments.0,
            arguments.1,
            arguments.2,
            arguments.3,
            arguments.4
        ])
    }

    func callAsFunction<T, A0, A1, A2, A3, A4, A5>(_: T.Type = T.self, arguments: () -> (A0, A1, A2, A3, A4, A5)) -> T {
        let arguments = arguments()
        return callAsFunction(T.self, arguments: [
            arguments.0,
            arguments.1,
            arguments.2,
            arguments.3,
            arguments.4,
            arguments.5
        ])
    }

    func callAsFunction<T, A0, A1, A2, A3, A4, A5, A6>(_: T.Type = T.self, arguments: () -> (A0, A1, A2, A3, A4, A5, A6)) -> T {
        let arguments = arguments()
        return callAsFunction(T.self, arguments: [
            arguments.0,
            arguments.1,
            arguments.2,
            arguments.3,
            arguments.4,
            arguments.5,
            arguments.6
        ])
    }

    func callAsFunction<T, A0, A1, A2, A3, A4, A5, A6, A7>(_: T.Type = T.self, arguments: () -> (A0, A1, A2, A3, A4, A5, A6, A7)) -> T {
        let arguments = arguments()
        return callAsFunction(T.self, arguments: [
            arguments.0,
            arguments.1,
            arguments.2,
            arguments.3,
            arguments.4,
            arguments.5,
            arguments.6,
            arguments.7
        ])
    }

    func callAsFunction<T, A0, A1, A2, A3, A4, A5, A6, A7, A8>(_: T.Type = T.self, arguments: () -> (A0, A1, A2, A3, A4, A5, A6, A7, A8)) -> T {
        let arguments = arguments()
        return callAsFunction(T.self, arguments: [
            arguments.0,
            arguments.1,
            arguments.2,
            arguments.3,
            arguments.4,
            arguments.5,
            arguments.6,
            arguments.7,
            arguments.8
        ])
    }

    func callAsFunction<T, A0, A1, A2, A3, A4, A5, A6, A7, A8, A9>(_: T.Type = T.self, arguments: () -> (A0, A1, A2, A3, A4, A5, A6, A7, A8, A9)) -> T {
        let arguments = arguments()
        return callAsFunction(T.self, arguments: [
            arguments.0,
            arguments.1,
            arguments.2,
            arguments.3,
            arguments.4,
            arguments.5,
            arguments.6,
            arguments.7,
            arguments.8,
            arguments.9
        ])
    }
}
