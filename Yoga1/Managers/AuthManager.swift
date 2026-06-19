import Foundation
internal import SwiftUI
import Observation

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

@Observable
final class AuthManager {
    var isAnonymous: Bool = true
    var isAuthenticated: Bool = false
    var currentUserId: String = "Unknown"
    
    init() {
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
    
    func signInAnonymously() {
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
    
    func signOut() {
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
