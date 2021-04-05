//
//  UserViewModel.swift
//  publisher
//
//  Created by ACT on 05/04/21.
//

import Foundation
import Combine

class UserViewModel: ObservableObject {
    
    // MARK: Input
    @Published var username = ""
    @Published var password = ""
    @Published var passwordConfirmation = ""
    
    // MARK: Output
    @Published var usernameMessage = ""
    @Published var passwordMessage = ""
    @Published var isValid = false
    
    private var cancellableSet: Set<AnyCancellable> = []
    
    private var isUsernameValidPublisher: AnyPublisher<Bool, Never> {
        $username
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { input in
                return input.count >= 6
            }
            .eraseToAnyPublisher()
    }
    
    private var isPasswordEmptyPublisher: AnyPublisher<Bool, Never> {
        $password
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { password in
                return password.isEmpty
            }
            .eraseToAnyPublisher()
    }
    
    private var passwordsEqualPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest($password, $passwordConfirmation)
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .map { password, passwordConfirmation in
                return password == passwordConfirmation
            }
            .eraseToAnyPublisher()
    }
    
    enum PasswordCheck {
        case valid
        case empty
        case noMatch
    }
    
    private var isPasswordValidPublisher: AnyPublisher<PasswordCheck, Never> {
        Publishers.CombineLatest(isPasswordEmptyPublisher, passwordsEqualPublisher)
            .map { passwordIsEmpty, passwordAreEqual in
                if (passwordIsEmpty) {
                    return .empty
                }
                else if (!passwordAreEqual) {
                    return .noMatch
                }
                else {
                    return .valid
                }
            }
            .eraseToAnyPublisher()
    }
    
    private var isFormValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isUsernameValidPublisher, isPasswordValidPublisher)
            .map { usernameIsValid, passwordIsValid in
                return usernameIsValid && (passwordIsValid == .valid)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: Constructor
    init() {
        self.isUsernameValidPublisher
            .receive(on: RunLoop.main)
            .map { valid in
                valid ? "" : "Username must at least 6 characters"
            }
            .assign(to: \.usernameMessage, on: self)
            .store(in: &cancellableSet)
        
        self.isPasswordValidPublisher
            .receive(on: RunLoop.main)
            .map { passwordCheck in
                switch passwordCheck {
                case .empty:
                    return "Password must not be empty"
                case .noMatch:
                    return "Passwords don't match"
                default:
                    return ""
                }
            }
            .assign(to: \.passwordMessage, on: self)
            .store(in: &cancellableSet)
        
        self.isFormValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isValid, on: self)
            .store(in: &cancellableSet)
    }
}
