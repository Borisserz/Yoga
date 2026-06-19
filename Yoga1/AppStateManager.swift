import SwiftUI
import Observation

@Observable
public final class AppStateManager {
    public var selectedTab: Int = 0
    public var hasCompletedOnboarding: Bool = false
    public var isPremiumActivated: Bool = false
    public var earnedAchievements: [String] = []
    
    public init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        if let savedBadges = UserDefaults.standard.stringArray(forKey: "earnedAchievements") {
            self.earnedAchievements = savedBadges
        }
    }
    
    public func completeOnboarding() {
        self.hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        checkAchievements(reason: "onboarding")
    }
    
    public func activatePremium() {
        self.isPremiumActivated = true
        checkAchievements(reason: "premium")
    }
    
    public func unlockAchievement(_ name: String) {
        if !earnedAchievements.contains(name) {
            earnedAchievements.append(name)
            UserDefaults.standard.set(earnedAchievements, forKey: "earnedAchievements")
            HapticsManager.shared.playSuccess()
            print("Achievement Unlocked: \(name)")
        }
    }
    
    private func checkAchievements(reason: String) {
        if reason == "onboarding" {
            unlockAchievement("Первый Шаг")
        } else if reason == "premium" {
            unlockAchievement("VIP Йог")
        }
    }
    
    public func reset() {
        self.hasCompletedOnboarding = false
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        self.selectedTab = 0
        self.earnedAchievements = []
        UserDefaults.standard.removeObject(forKey: "earnedAchievements")
    }
}
