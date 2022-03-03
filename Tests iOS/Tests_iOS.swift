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
	func testCompleteingTodo() {
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
				uuid: { fatalError("unimplemented") }
			)
		)
		
		
		store.send(.todo(index: 0, action: .checkboxTapped)) {
				$0.todos[0].isComplete = true
				$0.todos.swapAt(0, 1)
//				$0.todos = [
//					$0.todos[1],
//					$0.todos[0]
//				]
		}
	}
	
	func testAddTodo() {
		let store = TestStore(
			initialState: AppState(),
			reducer: appReducer,
			environment: AppEnvironment(
				uuid: { UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")! }
			)
		)
		
		store.send(.addTodo("hello world")) {
			$0.todos = [
				Todo(id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!, description: "hello world", isComplete: false)
			]
		}
	}
}
