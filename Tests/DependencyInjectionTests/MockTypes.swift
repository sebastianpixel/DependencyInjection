import DependencyInjection

protocol DummyProtocol: AnyObject {}
protocol AnotherDummyProtocol {}
protocol YetAnotherDummyProtocol: AnyObject {}

class DummyClass: DummyProtocol, AnotherDummyProtocol, YetAnotherDummyProtocol {}

struct DummyWithOneProperty: AnotherDummyProtocol {
    let id: String
}

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

struct DummyWithOptionalLazyInjectedProperty {
    @LazyInject var injectedProperty: DummyProtocol?
}

struct DummyWithInjectedProperty {
    @Inject var injectedProperty: DummyProtocol
}

struct DummyWithLazyInjectedProperty {
    @LazyInject var injectedProperty: DummyProtocol
}

struct DummyWithMutableInjectedProperty {
    @MutableInject var injectedProperty: DummyProtocol
}

struct DummyWithMutableLazyInjectedProperty {
    @MutableLazyInject var injectedProperty: DummyProtocol
}

struct DummyWithInjectedPropertyType {
    @Inject var injectedType: DummyProtocol.Type
}

struct DummyWithLazyInjectedPropertyType {
    @LazyInject var injectedType: DummyProtocol.Type
}
