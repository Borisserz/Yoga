import Foundation
import SwiftUI
import Observation

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

@Observable
public final class AuthManager {
    public var isAnonymous: Bool = true
    public var isAuthenticated: Bool = false
    public var currentUserId: String = "Unknown"
    
    public init() {
        #if canImport(FirebaseAuth)
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            self.isAnonymous = user?.isAnonymous ?? true
            self.isAuthenticated = user != nil && !(user?.isAnonymous ?? true)
            self.currentUserId = user?.uid ?? "Unknown"
        }
        #else
        // Mock state if Firebase is not yet imported
        self.isAnonymous = true
        self.isAuthenticated = false
        self.currentUserId = "local_user"
        #endif
    }
    
    public func signInAnonymously() {
        #if canImport(FirebaseAuth)
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                print("Error signing in anonymously: \(error.localizedDescription)")
            }
        }
        #else
        print("Firebase not configured. Mocking anonymous sign in.")
        self.isAuthenticated = true
        self.isAnonymous = true
        #endif
    }
    
    public func signOut() {
        #if canImport(FirebaseAuth)
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error)")
        }
        #else
        self.isAuthenticated = false
        self.isAnonymous = true
        #endif
    }
}
