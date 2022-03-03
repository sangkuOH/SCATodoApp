//
//  ContentView.swift
//  Shared
//
//  Created by 상구 on 2022/03/03.
//

import SwiftUI
import ComposableArchitecture


struct Todo: Equatable, Identifiable {
	let id: UUID
	var description = ""
	var isComplete = false
}

struct AppState: Equatable {
	@BindableState var text: String = ""
	@BindableState var todos: [Todo] = []
}

enum AppAction: BindableAction, Equatable {
	case binding(BindingAction<AppState>)
	case appendTodo(text: String)
	case deleteTodo(offset: IndexSet)
	case todoCheckboxTapped(index: Int)
	case todoTextFieldChanged(index: Int, text: String)
}

struct AppEnvironment {
	
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
	switch action {
	case .appendTodo(let text):
		state.todos.append(
			Todo(
				id: UUID(),
				description: text
			)
		)
		state.text = ""
		return .none
	case .deleteTodo(let offset):
		state.todos.remove(atOffsets: offset)
		return .none
	case .todoCheckboxTapped(let index):
		state.todos[index].isComplete.toggle()
		return .none
	case .todoTextFieldChanged(let index, let text):
		state.todos[index].description = text
		return .none
	case .binding:
		return .none
	}
}
	.binding()
//	.debug()

struct ContentView: View {
	let store: Store<AppState, AppAction>
	
	init(store: Store<AppState, AppAction>? = nil) {
		if let store = store {
			self.store = store
		} else {
			self.store = Store(
				initialState: AppState(todos: [Todo]()),
				reducer: appReducer,
				environment: AppEnvironment()
			)
		}
	}
	
	var body: some View {
		NavigationView {
			WithViewStore(self.store) { viewStore in
				VStack {
					TextField("todos..", text: viewStore.binding(\.$text))
						.onSubmit {
							viewStore.send(.appendTodo(text: viewStore.text))
						}
						.textFieldStyle(.roundedBorder)
						.padding()
					
					List {
						ForEach(Array(viewStore.todos.enumerated()), id: \.element.id) { index, todo in
							HStack {
								Button {
									viewStore.send(.todoCheckboxTapped(index: index))
								} label: {
									Image(systemName: todo.isComplete ? "checkmark.circle.fill" : "circlebadge")
								}
								.buttonStyle(.plain)
								TextField(
									"untitled todo",
									text: viewStore.binding(\.$todos[index].description)
								)
							}
							.foregroundColor(todo.isComplete ? .gray : nil)
						}
						.onDelete { offset in
							viewStore.send(.deleteTodo(offset: offset))
						}
					}
				}
				.navigationTitle("Todos")
			}
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
				environment: AppEnvironment()
			)
		)
	}
}

