import XCTest
@testable import DependencyInjection

protocol DummyProtocol: AnyObject {}
protocol AnotherDummyProtocol: AnyObject {}
protocol YetAnotherDummyProtocol: AnyObject {}

final class DependencyInjectionTests: XCTestCase {

    private class DummyClass: DummyProtocol, AnotherDummyProtocol, YetAnotherDummyProtocol {}

    @LazyInject private var dummy: DummyProtocol
    @LazyInject private var dummyType: DummyProtocol.Type
    @LazyInject private var optionalDummy: DummyProtocol?

    override func setUp() {
        super.setUp()

        DIContainer.cleanUpForTesting()
    }

    func testSharedInstanceResolvesToIdenticalInstance() {
        DIContainer.register(Shared(DummyClass()))
        XCTAssert(DIContainer.resolve(DummyClass.self) === DIContainer.resolve(DummyClass.self))
    }

    func testNewInstanceResolvesToDifferentInstance() {
        DIContainer.register(New(DummyClass()))
        XCTAssert(DIContainer.resolve(DummyClass.self) !== DIContainer.resolve(DummyClass.self))
    }

    func testLazyInjectPropertyWrapperWithNewInstanceProtocolConformance() {
        DIContainer.register(New(DummyClass() as DummyProtocol))
        XCTAssert(dummy !== DIContainer.resolve(DummyProtocol.self))
    }

    func testLazyInjectPropertyWrapperWithSharedInstancesAndProtocolConformance() {
        DIContainer.register(Shared(DummyClass() as DummyProtocol))
        XCTAssert(dummy === DIContainer.resolve(DummyProtocol.self))
    }

    func testOptionalLazyInjectPropertyWrapperWithNewInstanceProtocolConformance() {
        DIContainer.register(New(DummyClass() as DummyProtocol))
        XCTAssertNotNil(optionalDummy)
        XCTAssert(optionalDummy !== DIContainer.resolve(DummyProtocol.self))
    }

    func testOptionalLazyInjectPropertyWrapperWithSharedInstancesAndProtocolConformance() {
        DIContainer.register(Shared(DummyClass() as DummyProtocol))
        XCTAssertNotNil(optionalDummy)
        XCTAssert(optionalDummy === DIContainer.resolve(DummyProtocol.self))
    }

    func testOptionalLazyInjectPropertyWrapperWithNoRegisteredDependency() {
        XCTAssertNil(optionalDummy)
    }

    func testInjectPropertyWrapper() {
        class DummyWithInjectedProperty {
            @Inject var injectedProperty: DummyProtocol
        }
        DIContainer.register(Shared(DummyClass() as DummyProtocol))
        XCTAssert(DummyWithInjectedProperty().injectedProperty === DIContainer.resolve(DummyProtocol.self))
    }

    func testOptionalInjectPropertyWrapperWithRegisteredDependency() {
        class DummyWithInjectedProperty {
            @Inject var injectedProperty: DummyProtocol?
        }
        DIContainer.register(Shared(DummyClass() as DummyProtocol))
        XCTAssert(DummyWithInjectedProperty().injectedProperty === DIContainer.resolve(DummyProtocol.self))
    }

    func testOptionalInjectPropertyWrapperWithoutRegisteredDependencyReturnsNil() {
        class DummyWithInjectedProperty {
            @Inject var injectedProperty: DummyProtocol?
        }
        XCTAssertNil(DummyWithInjectedProperty().injectedProperty)
    }

    func testAliasesReferenceSameInstance() {
        DIContainer.register(Shared(DummyClass(), as: DummyProtocol.self, YetAnotherDummyProtocol.self))
        XCTAssert(DIContainer.resolve(DummyProtocol.self) === DIContainer.resolve(YetAnotherDummyProtocol.self))
    }

    func testOverrideRegistrationFromProductionInTests() {
        DIContainer.register(Shared(DummyClass() as DummyProtocol))
        XCTAssert(DIContainer.resolve(DummyProtocol.self) === DIContainer.resolve(DummyProtocol.self))

        DIContainer.register(New(DummyClass() as DummyProtocol))
        XCTAssert(DIContainer.resolve(DummyProtocol.self) !== DIContainer.resolve(DummyProtocol.self))
    }

    func testOverrideOneAliasInTests() {
        let sharedDummyClass = DummyClass()
        DIContainer.register(Shared(sharedDummyClass, as: DummyProtocol.self, YetAnotherDummyProtocol.self))

        XCTAssert(DIContainer.resolve(DummyProtocol.self) === sharedDummyClass)
        XCTAssert(DIContainer.resolve(YetAnotherDummyProtocol.self) === sharedDummyClass)

        DIContainer.register(New(DummyClass() as DummyProtocol))

        XCTAssert(DIContainer.resolve(DummyProtocol.self) !== sharedDummyClass)
        XCTAssert(DIContainer.resolve(YetAnotherDummyProtocol.self) === sharedDummyClass)
    }

    func testProtocolTypeRegistration() {
        DIContainer.register(Shared(DummyClass.self as DummyProtocol.Type))
        XCTAssert(dummyType == DummyClass.self)
        XCTAssert(DIContainer.resolve(DummyProtocol.Type.self) == DummyClass.self)
    }

    func testClassTypeRegistration() {
        DIContainer.register(Shared(DummyClass.self))
        XCTAssert(DIContainer.resolve(DummyClass.Type.self) == DummyClass.self)
    }

    func testParallelAccessToSharedInstance() {
        let dummy = DummyClass()
        DIContainer.register(Shared(dummy))

        let group = DispatchGroup()
        let iterations = 10

        for _ in 0 ..< iterations {
            group.enter()
        }

        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            XCTAssert(DIContainer.resolve(DummyClass.self) === dummy)
            group.leave()
        }

        group.wait()
    }

    static var allTests = [
        ("testSharedInstanceResolvesToIdenticalInstance", testSharedInstanceResolvesToIdenticalInstance),
        ("testNewInstanceResolvesToDifferentInstance", testNewInstanceResolvesToDifferentInstance),
        ("testLazyInjectPropertyWrapperWithNewInstanceProtocolConformance", testLazyInjectPropertyWrapperWithNewInstanceProtocolConformance),
        ("testLazyInjectPropertyWrapperWithSharedInstancesAndProtocolConformance", testLazyInjectPropertyWrapperWithSharedInstancesAndProtocolConformance),
        ("testOptionalLazyInjectPropertyWrapperWithNewInstanceProtocolConformance", testOptionalLazyInjectPropertyWrapperWithNewInstanceProtocolConformance),
        ("testOptionalLazyInjectPropertyWrapperWithSharedInstancesAndProtocolConformance", testOptionalLazyInjectPropertyWrapperWithSharedInstancesAndProtocolConformance),
        ("testOptionalLazyInjectPropertyWrapperWithNoRegisteredDependency", testOptionalLazyInjectPropertyWrapperWithNoRegisteredDependency),
        ("testInjectPropertyWrapper", testInjectPropertyWrapper),
        ("testOptionalInjectPropertyWrapperWithRegisteredDependency", testOptionalInjectPropertyWrapperWithRegisteredDependency),
        ("testOptionalInjectPropertyWrapperWithoutRegisteredDependencyReturnsNil", testOptionalInjectPropertyWrapperWithoutRegisteredDependencyReturnsNil),
        ("testAliasesReferenceSameInstance", testAliasesReferenceSameInstance),
        ("testOverrideRegistrationFromProductionInTests", testOverrideRegistrationFromProductionInTests),
        ("testOverrideOneAliasInTests", testOverrideOneAliasInTests),
        ("testProtocolTypeRegistration", testProtocolTypeRegistration),
        ("testClassTypeRegistration", testClassTypeRegistration),
        ("testParallelAccessToSharedInstance", testParallelAccessToSharedInstance)
    ]
}
