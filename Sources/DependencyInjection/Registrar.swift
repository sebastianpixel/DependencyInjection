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
