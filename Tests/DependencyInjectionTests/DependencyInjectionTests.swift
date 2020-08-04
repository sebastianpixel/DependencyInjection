import XCTest
@testable import DependencyInjection

private protocol DummyProtocol: AnyObject {}
private protocol AnotherDummyProtocol: AnyObject {}
private protocol YetAnotherDummyProtocol: AnyObject {}

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
        DIContainer.register(Shared(DummyClass() as DummyProtocol))
        XCTAssert(DummyWithInjectedProperty().injectedProperty === DIContainer.resolve(DummyProtocol.self))
    }

    func testOptionalInjectPropertyWrapperWithRegisteredDependency() {
        DIContainer.register(Shared(DummyClass() as DummyProtocol))
        XCTAssert(DummyWithInjectedProperty().injectedProperty === DIContainer.resolve(DummyProtocol.self))
    }

    func testOptionalInjectPropertyWrapperWithoutRegisteredDependencyReturnsNil() {
        XCTAssertNil(DummyWithOptionalInjectedProperty().injectedProperty)
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
        let group = DispatchGroup()
        let iterationsPerLoop = 10

        iterationsPerLoop.times {
            DIContainer.cleanUpForTesting()
            DIContainer.register(Shared(dummy))

            iterationsPerLoop.times(do: group.enter)

            DispatchQueue.concurrentPerform(iterations: iterationsPerLoop) { _ in
                XCTAssert(DIContainer.resolve(DummyClass.self) === dummy)
                group.leave()
            }

            group.wait()
        }
    }

    func testNestedResolvingDoesNotBlockCurrentThread() {
        let expectation = XCTestExpectation(description: "Nested dependencies are not blocking")

        DIContainer.register {
            Shared(DummyClass() as DummyProtocol)
            Shared(DummyWithInjectedProperty.init)
            Shared(DummyWithNestedDependency.init)
        }

        DispatchQueue.global().async(flags: .barrier) {
            _ = DIContainer.resolve(DummyWithNestedDependency.self)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
    }

    func testInjectPropertyWrapperIsMutable() {
        DIContainer.register(Shared(DummyClass() as DummyProtocol))
        var container = DummyWithInjectedProperty()
        let dummy = DummyClass()
        container.injectedProperty = dummy
        XCTAssert(container.injectedProperty === dummy)
    }

    func testLazyInjectPropertyWrapperIsMutable() {
        DIContainer.register(Shared(DummyClass() as DummyProtocol))
        XCTAssert(dummy === DIContainer.resolve(DummyProtocol.self))
        let newDummy = DummyClass()
        dummy = newDummy
        XCTAssert(dummy !== DIContainer.resolve(DummyProtocol.self))
        XCTAssert(dummy === newDummy)
    }

    func testGroupRegistrationsInModule() {
        let dummy = DummyClass()
        let module = Module {
            Shared(dummy as DummyProtocol)
        }
        DIContainer.register(module)
        XCTAssert(dummy === DIContainer.resolve(DummyProtocol.self))
    }

    private struct DummyWithNestedDependency {
        @Inject var injectedProperty: DummyWithInjectedProperty
    }

    private struct DummyWithOptionalInjectedProperty {
        @Inject var injectedProperty: DummyProtocol?
    }

    private struct DummyWithInjectedProperty {
        @Inject var injectedProperty: DummyProtocol
    }

    // swiftlint:disable line_length
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
        ("testParallelAccessToSharedInstance", testParallelAccessToSharedInstance),
        ("testInjectPropertyWrapperIsMutable", testInjectPropertyWrapperIsMutable),
        ("testLazyInjectPropertyWrapperIsMutable", testLazyInjectPropertyWrapperIsMutable)
    ]
    // swiftlint:enable line_length
}

private extension Int {
    func times(do block: () -> Void) {
        for _ in 0 ..< self {
            block()
        }
    }
}
