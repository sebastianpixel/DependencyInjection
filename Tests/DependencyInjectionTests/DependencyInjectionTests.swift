import XCTest
@testable import DependencyInjection

protocol DummyProtocol: AnyObject {}
protocol AnotherDummyProtocol: AnyObject {}
protocol YetAnotherDummyProtocol: AnyObject {}

final class DependencyInjectionTests: XCTestCase {

    private class DummyClass: DummyProtocol, AnotherDummyProtocol, YetAnotherDummyProtocol {}

    @LazyInject private var dummy: DummyProtocol

    func testSharedInstanceResolvesToIdenticalInstance() {
        DIContainer.shared.register(Shared(DummyClass()))
        XCTAssert(DIContainer.shared.resolve(DummyClass.self) === DIContainer.shared.resolve(DummyClass.self))
    }

    func testNewInstanceResolvesToDifferentInstance() {
        DIContainer.shared.register(New(DummyClass()))
        XCTAssert(DIContainer.shared.resolve(DummyClass.self) !== DIContainer.shared.resolve(DummyClass.self))
    }

    func testLazyInjectPropertyWrapperWithNewInstanceProtocolConformance() {
        DIContainer.shared.register(New(DummyClass() as AnotherDummyProtocol))
        XCTAssert(dummy !== DIContainer.shared.resolve(AnotherDummyProtocol.self))
    }

    func testLazyInjectPropertyWrapperWithSharedInstancesAndProtocolConformance() {
        DIContainer.shared.register(Shared(DummyClass() as DummyProtocol))
        XCTAssert(dummy === DIContainer.shared.resolve(DummyProtocol.self))
    }

    func testInjectPropertyWrapper() {
        class DummyWithInjectedProperty {
            @Inject var injectedProperty: DummyProtocol
        }
        DIContainer.shared.register(Shared(DummyClass() as DummyProtocol))
        XCTAssert(DummyWithInjectedProperty().injectedProperty === DIContainer.shared.resolve(DummyProtocol.self))
    }

    func testAliasesReferenceSameInstance() {
        DIContainer.shared.register(Shared(DummyClass(), as: DummyProtocol.self, YetAnotherDummyProtocol.self))
        XCTAssert(DIContainer.shared.resolve(DummyProtocol.self) === DIContainer.shared.resolve(YetAnotherDummyProtocol.self))
    }

    func testOverrideRegistrationFromProductionInTests() {
        DIContainer.shared.register(Shared(DummyClass() as DummyProtocol))
        XCTAssert(DIContainer.shared.resolve(DummyProtocol.self) !== DIContainer.shared.resolve(DummyProtocol.self))

        DIContainer.shared.register(New(DummyClass() as DummyProtocol))
        XCTAssert(DIContainer.shared.resolve(DummyProtocol.self) !== DIContainer.shared.resolve(DummyProtocol.self))
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
