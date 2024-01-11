//
//  DemoAppTests.swift
//  DemoAppTests
//
//  Created by hassan uriostegui on 8/30/22.
//

import DatastoreLib
@testable import DemoApp
import XCTest

class DatastoreTests: XCTestCase {
    var model: Model!
    var datastore: Datastore!

    override func setUpWithError() throws {
        super.setUp()
        model = Model()
        datastore = Datastore()
    }

    override func tearDownWithError() throws {
        model = nil
        datastore = nil
        super.tearDown()
    }
}

extension DatastoreTests {
    // Test Model's basic functionality
    func testModelInitialState() {
        XCTAssertEqual(model.state.value, 0, "Initial state value should be 0")
    }

    func testModelIncreaseValue() async {
        let expectation = XCTestExpectation(description: "Value increases")

        // Perform the operation that you expect to complete asynchronously.
        await model.increaseValue()

        // Wait for the async operation to complete
        DispatchQueue.main.async {
            expectation.fulfill() // Call this when the async operation completes
        }

        await fulfillment(of: [expectation], timeout: 1.0)

        // Perform your test assertion after the async operation is expected to be complete.
        XCTAssertEqual(model.state.value, 1, "Value should be incremented")
    }

    // Test DatastoreItem conformance
    func testStorageKey() {
        XCTAssertEqual(model.storageKey, "model:v1", "Storage key should match")
    }

    func testGetStorageItem() {
        let state = model.getStorageItem()
        XCTAssertEqual(state.value, model.state.value, "State values should match")
    }

    func testGetStorageItemDefault() {
        let defaultState = model.getStorageItemDefault()
        XCTAssertEqual(defaultState.value, 0, "Default state value should be 0")
    }

    func testSetStorageItem() {
        let newState = Model.State(value: 5)
        let expectation = self.expectation(description: "setStorageItem")
        model.setStorageItem(newState) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertEqual(model.state.value, 5, "State should be updated")
    }

    func testModelIncreaseValueAsync() async {
        let expectation = XCTestExpectation(description: "Async value increase")

        // Start the asynchronous operation
        await model.increaseValue()

        // Since increaseValue is asynchronous and posts changes to the main queue,
        // you should wait for the next run loop iteration for the changes to take effect.
        DispatchQueue.main.async {
            XCTAssertEqual(self.model.state.value, 1, "Value should be incremented")
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 2.0)
    }

    func testModelThreadSafety() {
        let expectation = XCTestExpectation(description: "Thread safety")
        expectation.expectedFulfillmentCount = 2 // Set to the number of concurrent tasks

        // Perform the operation on two different threads
        DispatchQueue.global(qos: .background).async {
            self.model.increaseValue()
            expectation.fulfill()
        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.model.increaseValue()
            expectation.fulfill()
        }

        // Wait for the async operations to complete
        wait(for: [expectation], timeout: 5.0)

        // Test if the final value is what you expect it to be
        XCTAssertEqual(model.state.value, 2, "Value should be incremented twice safely")
    }
}
