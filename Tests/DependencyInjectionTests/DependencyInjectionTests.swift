import XCTest
@testable import DependencyInjection

protocol DummyProtocol: AnyObject {}

final class DependencyInjectionTests: XCTestCase {

    private class DummyClass: DummyProtocol {}

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
        DIContainer.shared.register(New(DummyClass() as DummyProtocol))
        XCTAssert(dummy !== DIContainer.shared.resolve(DummyProtocol.self))
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

    func testOverrideRegistrationFromProductionInTests() {
        DIContainer.shared.register(Shared(DummyClass() as DummyProtocol))
        XCTAssert(DIContainer.shared.resolve(DummyProtocol.self) === DIContainer.shared.resolve(DummyProtocol.self))

        DIContainer.shared.register(New(DummyClass() as DummyProtocol))
        XCTAssert(DIContainer.shared.resolve(DummyProtocol.self) !== DIContainer.shared.resolve(DummyProtocol.self))
    }

    static var allTests = [
        ("testSharedInstanceResolvesToIdenticalInstance", testSharedInstanceResolvesToIdenticalInstance),
        ("testNewInstanceResolvesToDifferentInstance", testNewInstanceResolvesToDifferentInstance),
        ("testLazyInjectPropertyWrapperWithNewInstanceProtocolConformance", testLazyInjectPropertyWrapperWithNewInstanceProtocolConformance),
        ("testLazyInjectPropertyWrapperWithSharedInstancesAndProtocolConformance", testLazyInjectPropertyWrapperWithSharedInstancesAndProtocolConformance),
        ("testInjectPropertyWrapper", testInjectPropertyWrapper),
        ("testOverrideRegistrationFromProductionInTests", testOverrideRegistrationFromProductionInTests)
    ]
}
