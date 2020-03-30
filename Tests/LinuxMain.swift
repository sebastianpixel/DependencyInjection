import XCTest

import DependencyInjectionTests

var tests = [XCTestCaseEntry]()
tests += DependencyInjectionTests.allTests()
XCTMain(tests)
