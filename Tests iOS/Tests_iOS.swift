//
//  Tests_iOS.swift
//  Tests iOS
//
//  Created by 상구 on 2022/03/03.
//
import ComposableArchitecture
import XCTest
@testable import SCATodo

class Tests_iOS: XCTestCase {
	let scheduler = DispatchQueue.test
	
	func testCompleteingTodo() {
		let store = TestStore(
			initialState: AppState(
				text: "",
				todos: [
					Todo(
						id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
						description: "Milk",
						isComplete: false
					)
				]
			),
			reducer: appReducer,
			environment: AppEnvironment(
				uuid: { fatalError("unimplemented") },
				mainQueue: scheduler.eraseToAnyScheduler()
			)
		)
		store.assert(
			.send(.todo(index: 0, action: .checkboxTapped)) {
					$0.todos[0].isComplete = true
			},
			.do {
				self.scheduler.advance(by: 1)
//				_ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: 1)
			},
			.receive(.todoDelayCompleted)
		)
	}
	
	func testTodoSorting() {
		let store = TestStore(
			initialState: AppState(
				text: "",
				todos: [
					Todo(
						id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
						description: "Milk",
						isComplete: false
					),
					Todo(
						id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
						description: "Eggs",
						isComplete: false
					)
				]
			),
			reducer: appReducer,
			environment: AppEnvironment(
				uuid: { fatalError("unimplemented") },
				mainQueue: scheduler.eraseToAnyScheduler()
			)
		)
		store.assert(
			.send(.todo(index: 0, action: .checkboxTapped)) {
					$0.todos[0].isComplete = true
			},
			.do {
//				_ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: 1)
				self.scheduler.advance(by: 1)
			},
			.receive(.todoDelayCompleted) {
				$0.todos.swapAt(0, 1)
			}
		)
	}
	
	func testTodoSorting_Cancellation() {
		let store = TestStore(
			initialState: AppState(
				text: "",
				todos: [
					Todo(
						id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
						description: "Milk",
						isComplete: false
					),
					Todo(
						id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
						description: "Eggs",
						isComplete: false
					)
				]
			),
			reducer: appReducer,
			environment: AppEnvironment(
				uuid: { fatalError("unimplemented") },
				mainQueue: scheduler.eraseToAnyScheduler()
			)
		)
		store.assert(
			.send(.todo(index: 0, action: .checkboxTapped)) {
					$0.todos[0].isComplete = true
			},
			.do {
				self.scheduler.advance(by: 0.5)
//				_ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: 0.5)
			},
			.send(.todo(index: 0, action: .checkboxTapped)) {
					$0.todos[0].isComplete = false
			},
			.do {
				self.scheduler.advance(by: 1)
//				_ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: 1)
			},
			.receive(.todoDelayCompleted)
		)
	}
	
	func testAddTodo() {
		let store = TestStore(
			initialState: AppState(),
			reducer: appReducer,
			environment: AppEnvironment(
				uuid: { UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")! },
				mainQueue: scheduler.eraseToAnyScheduler()
			)
		)
		
		store.send(.addTodo("hello world")) {
			$0.todos = [
				Todo(id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!, description: "hello world", isComplete: false)
			]
			self.scheduler.advance(by: 1)
//			_ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: 1)
		}
	}
}
