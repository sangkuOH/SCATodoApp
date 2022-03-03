//
//  ContentView.swift
//  Shared
//
//  Created by 상구 on 2022/03/03.
//

import SwiftUI
import ComposableArchitecture
import IdentifiedCollections


struct Todo: Equatable, Identifiable {
	let id: UUID
	var description = ""
	var isComplete = false
}

struct AppState: Equatable {
	@BindableState var text: String = ""
	@BindableState var todos: [Todo] = []
}

enum TodoAction: Equatable {
	case checkboxTapped
	case textFieldChanged(String)
}

struct TodoEnvironment {
}


let todoReducer  = Reducer<Todo, TodoAction, TodoEnvironment> { state, action, environment in
	switch action {
	case .checkboxTapped:
		state.isComplete.toggle()
		return .none
	case .textFieldChanged(let text):
		state.description = text
		return .none
	}
}

enum AppAction: BindableAction, Equatable {
	case binding(BindingAction<AppState>)
	case todo(index: Int, action: TodoAction)
	case todoDelayCompleted
	case addTodo(String)
	case deleteTodo(IndexSet)
}

struct AppEnvironment {
	var uuid: () -> UUID
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>
	.combine(
		todoReducer.forEach(
			state: \AppState.todos,
			action: /AppAction.todo(index:action:),
			environment: {_ in TodoEnvironment() }
		),
		Reducer {state, action, environment in
			switch action {
			case .binding:
				return .none
			case .addTodo(let text):
				state.todos.insert(Todo(id: environment.uuid(), description: text), at: 0)
				state.text = ""
				return .none
			case .deleteTodo(let indexSet):
				state.todos.remove(atOffsets: indexSet)
				return .none
			case .todo(index: _, action: .checkboxTapped):
				struct CancelDelayId: Hashable {}
				
				return .concatenate(
						Effect(value: AppAction.todoDelayCompleted)
							.delay(for: 1, scheduler: DispatchQueue.main)
							.eraseToEffect()
							.cancellable(id: CancelDelayId(), cancelInFlight: true)
				)
			case .todo(let index, let action):
				return .none
			case .todoDelayCompleted:
				state.todos = state.todos
					.enumerated()
					.sorted { lhs, rhs in
						(!lhs.element.isComplete && rhs.element.isComplete)
						|| lhs.offset < rhs.offset
					}
					.map(\.element)
				return .none
			}
		}
	)
	.binding()

struct ContentView: View {
	let store: Store<AppState, AppAction>
	
	init(store: Store<AppState, AppAction>? = nil) {
		if let store = store {
			self.store = store
		} else {
			self.store = Store(
				initialState: AppState(todos: [Todo]()),
				reducer: appReducer,
				environment: AppEnvironment(uuid: UUID.init)
			)
		}
	}
	
	var body: some View {
		NavigationView {
			WithViewStore(self.store) { viewStore in
				VStack {
					TextField("todos..", text: viewStore.binding(\.$text))
						.onSubmit {
							viewStore.send(.addTodo(viewStore.text))
						}
						.textFieldStyle(.roundedBorder)
						.padding()
					
					List {
						ForEachStore(
							self.store.scope(
							state: \.todos,
							action: AppAction.todo(index:action:)
						),
							content: TodoView.init(store:)
						)
						.onDelete { offset in
							viewStore.send(.deleteTodo(offset))
						}
					}
				}
				.navigationTitle("Todos")
			}
		}
	}
}

struct TodoView: View {
	let store: Store<Todo, TodoAction>
	
	var body: some View {
		WithViewStore(store) { todoViewStore in
			HStack {
				Button {
					todoViewStore.send(.checkboxTapped)
				} label: {
					Image(systemName: todoViewStore.isComplete ? "checkmark.circle.fill" : "circlebadge")
				}
				.buttonStyle(.plain)
				TextField(
					"untitled todo",
					text: todoViewStore.binding(
						get: \.description,
						send: TodoAction.textFieldChanged
					)
				)
			}
			.foregroundColor(todoViewStore.isComplete ? .gray : nil)
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView(
			store: Store(
				initialState: AppState(
					todos: [
						Todo(
							id: UUID(),
							description: "Milk",
							isComplete: false
						),
						Todo(
							id: UUID(),
							description: "Eggs",
							isComplete: false
						),
						Todo(
							id: UUID(),
							description: "Hand Soap",
							isComplete: false
						),
					]
				),
				reducer: appReducer,
				environment: AppEnvironment(uuid: UUID.init)
			)
		)
	}
}

