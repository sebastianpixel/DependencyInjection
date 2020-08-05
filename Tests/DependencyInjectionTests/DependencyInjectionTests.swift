import XCTest
@testable import DependencyInjection

final class DependencyInjectionTests: XCTestCase {

    @LazyInject private var dummy: DummyProtocol
    @LazyInject private var dummyType: DummyProtocol.Type
    @LazyInject private var optionalDummy: DummyProtocol?

    override func setUp() {
        super.setUp()

        DIContainer.cleanUpForTesting()
    }

    func testSharedInstanceResolvesToIdenticalInstance() {
        DIContainer.register(Shared(DummyClass.init))
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

        for _ in 0 ..< iterationsPerLoop {
            DIContainer.cleanUpForTesting()
            DIContainer.register(Shared(dummy))

            for _ in 0 ..< iterationsPerLoop {
                group.enter()
            }

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

    func testParameterizedResolutionWithSingleProperty() {
        DIContainer.register {
            New { _, id in DummyWithOneProperty(id: id) as AnotherDummyProtocol }
        }
        let resolved = DIContainer.resolve(AnotherDummyProtocol.self, arguments: { "id" })
        XCTAssertEqual("id", (resolved as! DummyWithOneProperty).id)
    }

    func testParameterizedResolutionWithMultipleProperties() {
        DIContainer.register {
            New { _, id, name, age in
                DummyWithMultipleProperties(id: id, name: name, age: age)
            }
        }
        let resolved = DIContainer.resolve(DummyWithMultipleProperties.self) { ("id", "name", 1) }
        XCTAssertEqual("id", resolved.id)
        XCTAssertEqual("name", resolved.name)
        XCTAssertEqual(1, resolved.age)
    }

    func testParameterizedResolutionWithTypeAlias() {
        DIContainer.register {
            New { _, id in DummyWithOneProperty(id: id) as AnotherDummyProtocol }
        }
        let resolved = DIContainer.resolve(AnotherDummyProtocol.self, arguments: { "id" })
        XCTAssertEqual("id", (resolved as! DummyWithOneProperty).id)
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
        ("testLazyInjectPropertyWrapperIsMutable", testLazyInjectPropertyWrapperIsMutable),
        ("testGroupRegistrationsInModule", testGroupRegistrationsInModule),
        ("testParameterizedResolutionWithSingleProperty", testParameterizedResolutionWithSingleProperty),
        ("testParameterizedResolutionWithMultipleProperties", testParameterizedResolutionWithMultipleProperties),
        ("testParameterizedResolutionWithTypeAlias", testParameterizedResolutionWithTypeAlias)
    ]
    // swiftlint:enable line_length
}
