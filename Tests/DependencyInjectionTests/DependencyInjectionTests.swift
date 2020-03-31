import XCTest
@testable import DependencyInjection

protocol DummyProtocol: AnyObject {}
protocol AnotherDummyProtocol: AnyObject {}
protocol YetAnotherDummyProtocol: AnyObject {}

final class DependencyInjectionTests: XCTestCase {

    private class DummyClass: DummyProtocol, AnotherDummyProtocol, YetAnotherDummyProtocol {}

    @LazyInject private var dummy: DummyProtocol

    func testSharedInstanceResolvesToIdenticalInstance() {
        DIContainer.register(Shared(DummyClass()))
        XCTAssert(DIContainer.resolve(DummyClass.self) === DIContainer.resolve(DummyClass.self))
    }

    func testNewInstanceResolvesToDifferentInstance() {
        DIContainer.register(New(DummyClass()))
        XCTAssert(DIContainer.resolve(DummyClass.self) !== DIContainer.resolve(DummyClass.self))
    }

    func testLazyInjectPropertyWrapperWithNewInstanceProtocolConformance() {
        DIContainer.register(New(DummyClass() as AnotherDummyProtocol))
        XCTAssert(dummy !== DIContainer.resolve(AnotherDummyProtocol.self))
    }

    func testLazyInjectPropertyWrapperWithSharedInstancesAndProtocolConformance() {
        DIContainer.register(Shared(DummyClass() as DummyProtocol))
        XCTAssert(dummy === DIContainer.resolve(DummyProtocol.self))
    }

    func testInjectPropertyWrapper() {
        class DummyWithInjectedProperty {
            @Inject var injectedProperty: DummyProtocol
        }
        DIContainer.register(Shared(DummyClass() as DummyProtocol))
        XCTAssert(DummyWithInjectedProperty().injectedProperty === DIContainer.resolve(DummyProtocol.self))
    }

    func testAliasesReferenceSameInstance() {
        DIContainer.register(Shared(DummyClass(), as: DummyProtocol.self, YetAnotherDummyProtocol.self))
        XCTAssert(DIContainer.resolve(DummyProtocol.self) === DIContainer.resolve(YetAnotherDummyProtocol.self))
    }

    func testOverrideRegistrationFromProductionInTests() {
        DIContainer.register(Shared(DummyClass() as DummyProtocol))
        XCTAssert(DIContainer.resolve(DummyProtocol.self) !== DIContainer.resolve(DummyProtocol.self))

        DIContainer.register(New(DummyClass() as DummyProtocol))
        XCTAssert(DIContainer.resolve(DummyProtocol.self) !== DIContainer.resolve(DummyProtocol.self))
    }

    static var allTests = [
        ("testSharedInstanceResolvesToIdenticalInstance", testSharedInstanceResolvesToIdenticalInstance),
        ("testNewInstanceResolvesToDifferentInstance", testNewInstanceResolvesToDifferentInstance),
        ("testLazyInjectPropertyWrapperWithNewInstanceProtocolConformance", testLazyInjectPropertyWrapperWithNewInstanceProtocolConformance),
        ("testLazyInjectPropertyWrapperWithSharedInstancesAndProtocolConformance", testLazyInjectPropertyWrapperWithSharedInstancesAndProtocolConformance),
        ("testInjectPropertyWrapper", testInjectPropertyWrapper),
        ("testAliasesReferenceSameInstance", testAliasesReferenceSameInstance),
        ("testOverrideRegistrationFromProductionInTests", testOverrideRegistrationFromProductionInTests)
    ]
}
