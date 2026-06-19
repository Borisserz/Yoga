import Foundation
import HealthKit
import Observation

@Observable
public final class HealthKitManager {
    public static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    
    public var isAuthorized: Bool = false
    
    public init() {}
    
    public func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        let workoutType = HKObjectType.workoutType()
        let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        let typesToWrite: Set<HKSampleType> = [mindfulType, workoutType, activeEnergy]
        let typesToRead: Set<HKObjectType> = [mindfulType, workoutType]
        
        do {
            try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
            await MainActor.run {
                self.isAuthorized = true
            }
        } catch {
            print("HealthKit authorization failed: \(error.localizedDescription)")
        }
    }
    
    public func saveMindfulMinutes(minutes: Int, startDate: Date, endDate: Date) async {
        guard isAuthorized else { return }
        let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        
        let sample = HKCategorySample(type: mindfulType, value: 0, start: startDate, end: endDate)
        
        do {
            try await healthStore.save(sample)
            print("Successfully saved \(minutes) mindful minutes.")
        } catch {
            print("Error saving mindful minutes: \(error.localizedDescription)")
        }
    }
    
    public func saveYogaWorkout(durationMinutes: Int, calories: Double, startDate: Date, endDate: Date) async {
        guard isAuthorized else { return }
        
        let energyBurned = HKQuantity(unit: .kilocalorie(), doubleValue: calories)
        let workout = HKWorkout(
            activityType: .yoga,
            start: startDate,
            end: endDate,
            workoutEvents: nil,
            totalEnergyBurned: energyBurned,
            totalDistance: nil,
            metadata: nil
        )
        
        do {
            try await healthStore.save(workout)
            print("Successfully saved yoga workout.")
        } catch {
            print("Error saving yoga workout: \(error.localizedDescription)")
        }
    }
}
