// RUN: %{swiftc} %s -o %T/Asynchronous-Predicates
// RUN: %T/Asynchronous-Predicates > %t || true
// RUN: %{xctest_checker} %t %s

#if os(Linux) || os(FreeBSD) || CYGWIN
    import XCTest
    import Foundation
#else
    import SwiftXCTest
    import SwiftFoundation
#endif

// CHECK: Test Suite 'All tests' started at \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'PredicateExpectationsTestCase' started at \d+:\d+:\d+\.\d+
class PredicateExpectationsTestCase: XCTestCase {
    // CHECK: Test Case 'PredicateExpectationsTestCase.test_immediatelyTruePredicateAndObject_passes' started at \d+:\d+:\d+\.\d+
    // CHECK: Test Case 'PredicateExpectationsTestCase.test_immediatelyTruePredicateAndObject_passes' passed \(\d+\.\d+ seconds\).
    func test_immediatelyTruePredicateAndObject_passes() {
        let predicate = Predicate(value: true)
        let object = NSObject()
        expectation(for: predicate, evaluatedWith: object)
        waitForExpectations(timeout: 0.1)
    }

    // CHECK: Test Case 'PredicateExpectationsTestCase.test_immediatelyFalsePredicateAndObject_fails' started at \d+:\d+:\d+\.\d+
    // CHECK: .*/Tests/Functional/Asynchronous/Predicates/Expectations/main.swift:[[@LINE+6]]: error: PredicateExpectationsTestCase.test_immediatelyFalsePredicateAndObject_fails : Asynchronous wait failed - Exceeded timeout of 0.1 seconds, with unfulfilled expectations: Expect `<Predicate: 0x[0-9A-Fa-f]{1,16}>` for object <NSObject: 0x[0-9A-Fa-f]{1,16}>
    // CHECK: Test Case 'PredicateExpectationsTestCase.test_immediatelyFalsePredicateAndObject_fails' failed \(\d+\.\d+ seconds\).
    func test_immediatelyFalsePredicateAndObject_fails() {
        let predicate = Predicate(value: false)
        let object = NSObject()
        expectation(for: predicate, evaluatedWith: object)
        waitForExpectations(timeout: 0.1)
    }

    // CHECK: Test Case 'PredicateExpectationsTestCase.test_delayedTruePredicateAndObject_passes' started at \d+:\d+:\d+\.\d+
    // CHECK: Test Case 'PredicateExpectationsTestCase.test_delayedTruePredicateAndObject_passes' passed \(\d+\.\d+ seconds\).
    func test_delayedTruePredicateAndObject_passes() {
        let halfSecLaterDate = NSDate(timeIntervalSinceNow: 0.01)
        let predicate = Predicate(block: {
            evaluatedObject, bindings in
            if let evaluatedDate = evaluatedObject as? NSDate {
                return evaluatedDate.compare(Date()) == ComparisonResult.orderedAscending
            }
            return false
        })
        expectation(for: predicate, evaluatedWith: halfSecLaterDate)
        waitForExpectations(timeout: 0.1)
    }
    
    // CHECK: Test Case 'PredicateExpectationsTestCase.test_immediatelyTrueDelayedFalsePredicateAndObject_passes' started at \d+:\d+:\d+\.\d+
    // CHECK: Test Case 'PredicateExpectationsTestCase.test_immediatelyTrueDelayedFalsePredicateAndObject_passes' passed \(\d+\.\d+ seconds\).
    func test_immediatelyTrueDelayedFalsePredicateAndObject_passes() {
        let halfSecLaterDate = NSDate(timeIntervalSinceNow: 0.01)
        let predicate = Predicate(block: { evaluatedObject, bindings in
            if let evaluatedDate = evaluatedObject as? NSDate {
                return evaluatedDate.compare(Date()) == ComparisonResult.orderedDescending
            }
            return false
        })
        expectation(for: predicate, evaluatedWith: halfSecLaterDate)
        waitForExpectations(timeout: 0.1)
    }
    
    static var allTests = {
        return [
                   ("test_immediatelyTruePredicateAndObject_passes", test_immediatelyTruePredicateAndObject_passes),
                   ("test_immediatelyFalsePredicateAndObject_fails", test_immediatelyFalsePredicateAndObject_fails),
                   ("test_delayedTruePredicateAndObject_passes", test_delayedTruePredicateAndObject_passes),
                   ("test_immediatelyTrueDelayedFalsePredicateAndObject_passes", test_immediatelyTrueDelayedFalsePredicateAndObject_passes),
        ]
    }()
}

// CHECK: Test Suite 'PredicateExpectationsTestCase' failed at \d+:\d+:\d+\.\d+
// CHECK: \t Executed 4 tests, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
XCTMain([testCase(PredicateExpectationsTestCase.allTests)])

// CHECK: Test Suite '.*\.xctest' failed at \d+:\d+:\d+\.\d+
// CHECK: \t Executed 4 tests, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' failed at \d+:\d+:\d+\.\d+
// CHECK: \t Executed 4 tests, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
