import XCTest
import Vision
import CoreGraphics
@testable import Yoga1

final class PoseAlgorithmTests: XCTestCase {

    typealias Joints = [VNHumanBodyPoseObservation.JointName: CGPoint]

    // NOTE: CameraManager normalizes coordinates so y = 0 is the top and y = 1
    // is the bottom of the frame.

    func testTadasanaCorrectWhenStandingStraight() {
        let joints: Joints = [
            .leftShoulder: CGPoint(x: 0.50, y: 0.20),
            .leftHip:      CGPoint(x: 0.50, y: 0.50),
            .leftKnee:     CGPoint(x: 0.50, y: 0.75),
            .leftAnkle:    CGPoint(x: 0.50, y: 0.95),
            .rightAnkle:   CGPoint(x: 0.52, y: 0.95)
        ]
        let (isCorrect, _) = TadasanaAlgorithm().analyze(joints: joints)
        XCTAssertTrue(isCorrect)
    }

    func testTadasanaFailsWhenKneesBent() {
        // Knee pushed forward so the hip-knee-ankle angle is far from straight.
        let joints: Joints = [
            .leftShoulder: CGPoint(x: 0.50, y: 0.20),
            .leftHip:      CGPoint(x: 0.50, y: 0.50),
            .leftKnee:     CGPoint(x: 0.70, y: 0.70),
            .leftAnkle:    CGPoint(x: 0.50, y: 0.95),
            .rightAnkle:   CGPoint(x: 0.52, y: 0.95)
        ]
        let (isCorrect, _) = TadasanaAlgorithm().analyze(joints: joints)
        XCTAssertFalse(isCorrect)
    }

    func testAlgorithmReportsMissingJoints() {
        let (isCorrect, feedback) = TadasanaAlgorithm().analyze(joints: [:])
        XCTAssertFalse(isCorrect)
        XCTAssertFalse(feedback.isEmpty)
    }

    func testFactoryReturnsAlgorithmForKnownKey() {
        // Known keys must not fall through to the generic algorithm.
        let algo = YogaPoseAnalyzer.getAlgorithm(for: "tadasana")
        XCTAssertTrue(algo is TadasanaAlgorithm)
    }

    func testFactoryFallsBackForUnknownKey() {
        let algo = YogaPoseAnalyzer.getAlgorithm(for: "does_not_exist")
        XCTAssertTrue(algo is GenericPoseAlgorithm)
    }
}
