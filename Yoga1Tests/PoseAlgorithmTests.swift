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

    // MARK: - New pose algorithms

    func testFactoryWiresUpNewAlgorithms() {
        XCTAssertTrue(YogaPoseAnalyzer.getAlgorithm(for: "plank") is PlankAlgorithm)
        XCTAssertTrue(YogaPoseAnalyzer.getAlgorithm(for: "cobra") is CobraAlgorithm)
        XCTAssertTrue(YogaPoseAnalyzer.getAlgorithm(for: "triangle") is TriangleAlgorithm)
        XCTAssertTrue(YogaPoseAnalyzer.getAlgorithm(for: "boat") is BoatAlgorithm)
        XCTAssertTrue(YogaPoseAnalyzer.getAlgorithm(for: "warrior_i") is WarriorIAlgorithm)
        XCTAssertTrue(YogaPoseAnalyzer.getAlgorithm(for: "half_moon") is HalfMoonAlgorithm)
        XCTAssertTrue(YogaPoseAnalyzer.getAlgorithm(for: "camel") is CamelAlgorithm)
        XCTAssertTrue(YogaPoseAnalyzer.getAlgorithm(for: "bridge") is BridgeAlgorithm)
        XCTAssertTrue(YogaPoseAnalyzer.getAlgorithm(for: "seated_forward_bend") is SeatedForwardBendAlgorithm)
    }

    func testPlankCorrectWhenBodyIsOneLine() {
        let joints: Joints = [
            .leftShoulder: CGPoint(x: 0.20, y: 0.50),
            .leftElbow:    CGPoint(x: 0.20, y: 0.70),
            .leftWrist:    CGPoint(x: 0.20, y: 0.90),
            .leftHip:      CGPoint(x: 0.50, y: 0.55),
            .leftKnee:     CGPoint(x: 0.68, y: 0.58),
            .leftAnkle:    CGPoint(x: 0.85, y: 0.60)
        ]
        XCTAssertTrue(PlankAlgorithm().analyze(joints: joints).isCorrect)
    }

    func testPlankFailsWhenHipsSag() {
        let joints: Joints = [
            .leftShoulder: CGPoint(x: 0.20, y: 0.40),
            .leftElbow:    CGPoint(x: 0.20, y: 0.60),
            .leftWrist:    CGPoint(x: 0.20, y: 0.80),
            .leftHip:      CGPoint(x: 0.50, y: 0.70),
            .leftKnee:     CGPoint(x: 0.68, y: 0.55),
            .leftAnkle:    CGPoint(x: 0.85, y: 0.40)
        ]
        XCTAssertFalse(PlankAlgorithm().analyze(joints: joints).isCorrect)
    }

    func testBoatCorrectWhenFeetLiftedInV() {
        let joints: Joints = [
            .leftShoulder: CGPoint(x: 0.35, y: 0.45),
            .leftElbow:    CGPoint(x: 0.40, y: 0.50),
            .leftWrist:    CGPoint(x: 0.45, y: 0.55),
            .leftHip:      CGPoint(x: 0.50, y: 0.70),
            .leftKnee:     CGPoint(x: 0.70, y: 0.55),
            .leftAnkle:    CGPoint(x: 0.85, y: 0.40)
        ]
        XCTAssertTrue(BoatAlgorithm().analyze(joints: joints).isCorrect)
    }

    func testBoatFailsWhenFeetOnFloor() {
        let joints: Joints = [
            .leftShoulder: CGPoint(x: 0.35, y: 0.45),
            .leftElbow:    CGPoint(x: 0.40, y: 0.55),
            .leftWrist:    CGPoint(x: 0.45, y: 0.60),
            .leftHip:      CGPoint(x: 0.50, y: 0.70),
            .leftKnee:     CGPoint(x: 0.65, y: 0.85),
            .leftAnkle:    CGPoint(x: 0.80, y: 0.95)
        ]
        XCTAssertFalse(BoatAlgorithm().analyze(joints: joints).isCorrect)
    }

    func testTriangleCorrectWithWideStanceAndOpenArms() {
        let joints: Joints = [
            .leftHip:     CGPoint(x: 0.30, y: 0.50),
            .leftKnee:    CGPoint(x: 0.25, y: 0.72),
            .leftAnkle:   CGPoint(x: 0.20, y: 0.95),
            .rightHip:    CGPoint(x: 0.60, y: 0.50),
            .rightKnee:   CGPoint(x: 0.70, y: 0.72),
            .rightAnkle:  CGPoint(x: 0.80, y: 0.95),
            .leftWrist:   CGPoint(x: 0.15, y: 0.20),
            .rightWrist:  CGPoint(x: 0.85, y: 0.85)
        ]
        XCTAssertTrue(TriangleAlgorithm().analyze(joints: joints).isCorrect)
    }

    func testCobraCorrectWhenChestLiftedHipsDown() {
        let joints: Joints = [
            .leftShoulder: CGPoint(x: 0.30, y: 0.55),
            .leftElbow:    CGPoint(x: 0.35, y: 0.70),
            .leftWrist:    CGPoint(x: 0.40, y: 0.80),
            .leftHip:      CGPoint(x: 0.60, y: 0.75),
            .leftKnee:     CGPoint(x: 0.80, y: 0.78),
            .leftAnkle:    CGPoint(x: 0.95, y: 0.80)
        ]
        XCTAssertTrue(CobraAlgorithm().analyze(joints: joints).isCorrect)
    }
}
