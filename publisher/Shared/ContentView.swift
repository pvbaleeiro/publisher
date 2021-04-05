//
//  ContentView.swift
//  Shared
//
//  Created by ACT on 05/04/21.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @ObservedObject private var userViewModel = UserViewModel()
    @State var presenteAlert = false
    
    var body: some View {
        Form {
            Section(footer: Text(userViewModel.usernameMessage).foregroundColor(.red)) {
                TextField("Username", text: $userViewModel.username)
                    .autocapitalization(.none)
            }
            Section(footer: Text(userViewModel.passwordMessage).foregroundColor(.red)) {
                SecureField("Password", text: $userViewModel.password)
                SecureField("Password Confirmation", text: $userViewModel.passwordConfirmation)
            }
            Section {
                Button(action: { self.signUp() }) {
                    Text("Sign up")
                }.disabled(!self.userViewModel.isValid)
            }
        }
        .sheet(isPresented: $presenteAlert) {
            WelcomeView()
        }
    }
    
    func signUp() {
        self.presenteAlert = true
    }
}

struct WelcomeView: View {
    var body: some View {
        Text("Welcome to our app!!!")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

/// Just
/// Emits a single value
/// Mostly used for MockServices
func just42() -> AnyPublisher<Int, Never> {
    Just(42).eraseToAnyPublisher()
}


/// Future
/// Emits just once
/// Mostly used to wrap existing code in Combine Publishers
/// Based on a promise
/// Can succed or fail
func future() -> AnyPublisher<Int, Error> {
    Future<Int, Error>() { promise in
        
        // Do some stuff
        // If it succeeds:
        promise(.success(42))
        
        // It it fails:
        promise(.failure(NSError()))
    }.eraseToAnyPublisher()
}


/// Timer
/// Emits repeatedly after defined time interval
/// Used for stopwatches and timers
let timer = Timer.publish(every: 1, on: .main, in: .default)
    .autoconnect()
    .eraseToAnyPublisher()


/// DataTaskPublisher
/// Used for network request
/// Used to access APIs
/// Not made by hand, taken from URLSession
let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1")!

func dataTask<T>() -> AnyPublisher<T, Error> {
    URLSession.shared.dataTaskPublisher(for: url)
        .tryMap { (data, response) -> T in
            return data as! T
        }
        .eraseToAnyPublisher()
}


/// Combine Latest
/// Combines the latest emitted values from other Publishers
/// Used to compare and set states
/// e.g in the pratical example: form validation
func just33() -> AnyPublisher<Int, Never> {
    Just(42)
        .eraseToAnyPublisher()
}

func just150() -> AnyPublisher<Int, Never> {
    Just(150)
        .eraseToAnyPublisher()
}

func combineLatest() -> AnyPublisher<Int, Never> {
    just33().combineLatest(just150())
        .map { (value1, value2) in
            value1 + value2
        }
        .eraseToAnyPublisher()
}

final class ViewModel: ObservableObject {
    @Published var nameFromTextField = ""
    
    func published() -> AnyPublisher<String, Never> {
        $nameFromTextField
            .map { name -> String in
                "You entered \(name)"
            }
            .eraseToAnyPublisher()
    }
}


