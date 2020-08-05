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
