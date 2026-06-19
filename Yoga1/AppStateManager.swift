import SwiftUI
import Observation

@Observable
public final class AppStateManager {
    public var selectedTab: Int = 0
    public var hasCompletedOnboarding: Bool = false
    public var isPremiumActivated: Bool = false
    
    public init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    public func completeOnboarding() {
        self.hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
    
    public func activatePremium() {
        self.isPremiumActivated = true
    }
    
    public func reset() {
        self.hasCompletedOnboarding = false
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        self.selectedTab = 0
    }
}
