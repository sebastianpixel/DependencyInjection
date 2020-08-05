protocol DummyProtocol: AnyObject {}
protocol AnotherDummyProtocol {}
protocol YetAnotherDummyProtocol: AnyObject {}

class DummyClass: DummyProtocol, AnotherDummyProtocol, YetAnotherDummyProtocol {}

struct DummyWithOneProperty: AnotherDummyProtocol {
    let id: String
}

import DependencyInjection

struct DummyWithMultipleProperties {
    let id: String
    let name: String
    let age: Int
}

struct DummyWithNestedDependency {
    @Inject var injectedProperty: DummyWithInjectedProperty
}

struct DummyWithOptionalInjectedProperty {
    @Inject var injectedProperty: DummyProtocol?
}

struct DummyWithInjectedProperty {
    @Inject var injectedProperty: DummyProtocol
}
