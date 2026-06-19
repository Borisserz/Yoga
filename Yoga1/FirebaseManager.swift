import Foundation
import Observation

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

@Observable
public final class FirebaseManager {
    public static let shared = FirebaseManager()
    
    public init() {}
    
    public func saveUserStats(userId: String, minutes: Int, streak: Int) {
        guard !userId.isEmpty && userId != "Unknown" else { return }
        
        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData([
            "totalMinutes": minutes,
            "currentStreak": streak,
            "lastUpdated": FieldValue.serverTimestamp()
        ], merge: true) { error in
            if let error = error {
                print("Error saving stats to Firestore: \(error.localizedDescription)")
            } else {
                print("Successfully synced stats to Firestore.")
            }
        }
        #else
        print("FirebaseFirestore not imported. Mocking sync for user \(userId): \(minutes) mins, \(streak) streak.")
        #endif
    }
}
