import XCTest
@testable import DependencyInjection

final class DependencyInjectionTests: XCTestCase {

    override func setUp() {
        super.setUp()

        let container = DIContainer()
        DIContainer.shared = container
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
        let container = DummyWithLazyInjectedProperty()
        XCTAssert(container.injectedProperty !== DIContainer.resolve(DummyProtocol.self))
    }

    func testLazyInjectPropertyWrapperWithSharedInstancesAndProtocolConformance() {
        DIContainer.register(Shared(DummyClass() as DummyProtocol))
        let container = DummyWithLazyInjectedProperty()
        XCTAssert(container.injectedProperty === DIContainer.resolve(DummyProtocol.self))
    }

    func testOptionalLazyInjectPropertyWrapperWithNewInstanceProtocolConformance() {
        DIContainer.register(New(DummyClass() as DummyProtocol))
        let container = DummyWithOptionalLazyInjectedProperty()
        XCTAssertNotNil(container.injectedProperty)
        XCTAssert(container.injectedProperty !== DIContainer.resolve(DummyProtocol.self))
    }

    func testOptionalLazyInjectPropertyWrapperWithSharedInstancesAndProtocolConformance() {
        DIContainer.register(Shared(DummyClass() as DummyProtocol))
        let container = DummyWithOptionalLazyInjectedProperty()
        XCTAssertNotNil(container.injectedProperty)
        XCTAssert(container.injectedProperty === DIContainer.resolve(DummyProtocol.self))
    }

    func testOptionalLazyInjectPropertyWrapperWithNoRegisteredDependency() {
        XCTAssertNil(DummyWithOptionalLazyInjectedProperty().injectedProperty)
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
        let container = DummyWithInjectedPropertyType()
        XCTAssert(container.injectedType == DummyClass.self)
        XCTAssert(DIContainer.resolve(DummyProtocol.Type.self) == DummyClass.self)
    }

    func testProtocolTypeLazyRegistration() {
        DIContainer.register(Shared(DummyClass.self as DummyProtocol.Type))
        let container = DummyWithLazyInjectedPropertyType()
        XCTAssert(container.injectedType == DummyClass.self)
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
            DIContainer.shared.cleanUpForTesting()
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

    func testMutableInjectPropertyWrapperIsMutable() {
        DIContainer.register(Shared(DummyClass() as DummyProtocol))
        var container = DummyWithMutableInjectedProperty()
        XCTAssert(container.injectedProperty === DIContainer.resolve(DummyProtocol.self))
        let newInjectedProperty = DummyClass()
        container.injectedProperty = newInjectedProperty
        XCTAssert(newInjectedProperty !== DIContainer.resolve(DummyProtocol.self))
        XCTAssert(container.injectedProperty === newInjectedProperty)
    }

    func testMutableLazyInjectPropertyWrapperIsMutable() {
        DIContainer.register(Shared(DummyClass() as DummyProtocol))
        var container = DummyWithMutableLazyInjectedProperty()
        XCTAssert(container.injectedProperty === DIContainer.resolve(DummyProtocol.self))
        let newInjectedProperty = DummyClass()
        container.injectedProperty = newInjectedProperty
        XCTAssert(newInjectedProperty !== DIContainer.resolve(DummyProtocol.self))
        XCTAssert(container.injectedProperty === newInjectedProperty)
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

    func testRegisteringByImplementingDependencyRegistering() {
        shouldRegisterDependencies = true

        let resolved = DIContainer.resolve(DummyRegisteredInDependencyRegisteringConformanceImplementation?.self)
        XCTAssertNotNil(resolved)
    }

    func testRegisterDependenciesInDependencyRegisteringImplementationIsCalledOnlyOnce() {
        shouldRegisterDependencies = true

        XCTAssertEqual(invocationCount, 0)
        _ = DIContainer.resolve(DummyRegisteredInDependencyRegisteringConformanceImplementation?.self)
        XCTAssertEqual(invocationCount, 1)
        _ = DIContainer.resolve(DummyRegisteredInDependencyRegisteringConformanceImplementation?.self)
        XCTAssertEqual(invocationCount, 1)
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
        ("testProtocolTypeLazyRegistration", testProtocolTypeLazyRegistration),
        ("testClassTypeRegistration", testClassTypeRegistration),
        ("testParallelAccessToSharedInstance", testParallelAccessToSharedInstance),
        ("testMutableInjectPropertyWrapperIsMutable", testMutableInjectPropertyWrapperIsMutable),
        ("testMutableLazyInjectPropertyWrapperIsMutable", testMutableLazyInjectPropertyWrapperIsMutable),
        ("testGroupRegistrationsInModule", testGroupRegistrationsInModule),
        ("testParameterizedResolutionWithSingleProperty", testParameterizedResolutionWithSingleProperty),
        ("testParameterizedResolutionWithMultipleProperties", testParameterizedResolutionWithMultipleProperties),
        ("testParameterizedResolutionWithTypeAlias", testParameterizedResolutionWithTypeAlias)
    ]
    // swiftlint:enable line_length
}

private var shouldRegisterDependencies = false
private var invocationCount = 0

extension DIContainer: DependencyRegistering {
    public static func registerDependencies() {
        if shouldRegisterDependencies {
            invocationCount += 1
            register(Shared(DummyRegisteredInDependencyRegisteringConformanceImplementation()))
        }
    }
}
