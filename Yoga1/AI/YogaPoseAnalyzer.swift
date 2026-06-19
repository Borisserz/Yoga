import Foundation
import Vision
import CoreGraphics

// MARK: - Geometry Utils

public extension CGPoint {
    func angle(to p2: CGPoint, p3: CGPoint) -> CGFloat {
        // Angle at vertex p2 formed by points self (p1) and p3.
        let vector1 = CGVector(dx: self.x - p2.x, dy: self.y - p2.y)
        let vector2 = CGVector(dx: p3.x - p2.x, dy: p3.y - p2.y)
        
        let angle1 = atan2(vector1.dy, vector1.dx)
        let angle2 = atan2(vector2.dy, vector2.dx)
        var angle = abs(angle1 - angle2) * 180 / .pi
        if angle > 180 {
            angle = 360 - angle
        }
        return angle
    }
}

// MARK: - Pose Analyzer Protocol

public protocol YogaPoseAlgorithm {
    var targetPoseName: String { get }
    func analyze(joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> (isCorrect: Bool, feedback: String)
}

// MARK: - Tree Pose (Врикшасана)

public struct TreePoseAlgorithm: YogaPoseAlgorithm {
    public let targetPoseName = "vrksasana"
    
    public init() {}
    
    public func analyze(joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> (isCorrect: Bool, feedback: String) {
        guard let leftAnkle = joints[.leftAnkle],
              let rightAnkle = joints[.rightAnkle],
              let leftKnee = joints[.leftKnee],
              let rightKnee = joints[.rightKnee],
              let leftHip = joints[.leftHip],
              let rightHip = joints[.rightHip] else {
            return (false, String(localized: "Step fully into the frame"))
        }
        
        // Tree pose: One foot is lifted and placed on the inner thigh of the other leg.
        // We can check if one ankle is significantly higher than the other (y is from bottom to top in Vision normalized coords, but CameraManager normalizes y = 1.0 - y, so 0 is top, 1 is bottom).
        // Let's assume the camera manager uses: y=0 is top, y=1 is bottom.
        
        let leftIsLifted = leftAnkle.y < rightKnee.y // Left ankle is higher than right knee (lower y value)
        let rightIsLifted = rightAnkle.y < leftKnee.y
        
        if !leftIsLifted && !rightIsLifted {
            return (false, String(localized: "Lift one leg and place the foot on your inner thigh"))
        }
        
        // Check knee angle for the lifted leg
        let liftedKneeAngle = leftIsLifted ? 
            leftHip.angle(to: leftKnee, p3: leftAnkle) : 
            rightHip.angle(to: rightKnee, p3: rightAnkle)
        
        // Lifted knee should be bent sharply
        if liftedKneeAngle > 90 {
            return (false, String(localized: "Bend your lifted leg more"))
        }
        
        // Check standing leg straightness
        let standingKneeAngle = leftIsLifted ? 
            rightHip.angle(to: rightKnee, p3: rightAnkle) : 
            leftHip.angle(to: leftKnee, p3: leftAnkle)
            
        if standingKneeAngle < 160 {
            return (false, String(localized: "Straighten your standing leg"))
        }
        
        return (true, String(localized: "Great! Hold your balance."))
    }
}

// MARK: - Downward Dog (Адхо Мукха Шванасана)

public struct DownwardDogAlgorithm: YogaPoseAlgorithm {
    public let targetPoseName = "downward_dog"
    
    public init() {}
    
    public func analyze(joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> (isCorrect: Bool, feedback: String) {
        guard let leftWrist = joints[.leftWrist],
              let leftShoulder = joints[.leftShoulder],
              let leftHip = joints[.leftHip],
              let leftAnkle = joints[.leftAnkle] else {
            return (false, String(localized: "Turn sideways to the camera"))
        }
        
        // Downward dog forms a triangle (hands, hips, feet)
        // Check angle at hips (should be around 60-90 degrees)
        let hipAngle = leftShoulder.angle(to: leftHip, p3: leftAnkle)
        
        if hipAngle > 110 {
            return (false, String(localized: "Lift your hips higher to sharpen the angle"))
        }
        
        if hipAngle < 45 {
            return (false, String(localized: "Widen your stance, the angle is too sharp"))
        }
        
        // Check arms straightness
        let armAngle = leftWrist.angle(to: leftShoulder, p3: leftHip)
        if armAngle < 150 {
            return (false, String(localized: "Straighten your arms and lengthen your back"))
        }
        
        return (true, String(localized: "Perfect downward dog!"))
    }
}

// MARK: - Tadasana (Сила Гор 2)

public struct TadasanaAlgorithm: YogaPoseAlgorithm {
    public let targetPoseName = "tadasana"
    
    public init() {}
    
    public func analyze(joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> (isCorrect: Bool, feedback: String) {
        guard let leftAnkle = joints[.leftAnkle],
              let rightAnkle = joints[.rightAnkle],
              let leftKnee = joints[.leftKnee],
              let leftHip = joints[.leftHip],
              let leftShoulder = joints[.leftShoulder] else {
            return (false, String(localized: "Step fully into the frame"))
        }
        
        // Tadasana: Standing perfectly straight.
        // Check if knees are straight
        let kneeAngle = leftHip.angle(to: leftKnee, p3: leftAnkle)
        if kneeAngle < 165 {
            return (false, String(localized: "Straighten your knees"))
        }
        
        // Check if feet are somewhat close to each other
        let feetDistance = abs(leftAnkle.x - rightAnkle.x)
        if feetDistance > 0.2 { // normalized distance
            return (false, String(localized: "Bring your feet closer together"))
        }
        
        // Check if shoulders are above hips (standing straight)
        let spineAngle = leftKnee.angle(to: leftHip, p3: leftShoulder)
        if spineAngle < 165 {
            return (false, String(localized: "Straighten your back and open your shoulders"))
        }
        
        return (true, String(localized: "Great, hold mountain pose!"))
    }
}

// MARK: - Utkatasana (Огненный шар 5)

public struct UtkatasanaAlgorithm: YogaPoseAlgorithm {
    public let targetPoseName = "utkatasana"
    
    public init() {}
    
    public func analyze(joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> (isCorrect: Bool, feedback: String) {
        guard let leftAnkle = joints[.leftAnkle],
              let leftKnee = joints[.leftKnee],
              let leftHip = joints[.leftHip],
              let leftShoulder = joints[.leftShoulder],
              let leftWrist = joints[.leftWrist] else {
            return (false, String(localized: "Turn sideways to the camera"))
        }
        
        // Chair pose: Knees bent, hips low, arms raised.
        let kneeAngle = leftHip.angle(to: leftKnee, p3: leftAnkle)
        if kneeAngle > 140 {
            return (false, String(localized: "Sit lower, bend your knees"))
        }
        if kneeAngle < 70 {
            return (false, String(localized: "Don't squat so deep"))
        }
        
        let hipAngle = leftKnee.angle(to: leftHip, p3: leftShoulder)
        if hipAngle < 90 {
            return (false, String(localized: "Lift your chest, don't lean too far forward"))
        }
        
        // Arms should be raised (wrist higher than shoulder) -> y is 0 at top, 1 at bottom
        if leftWrist.y > leftShoulder.y {
            return (false, String(localized: "Raise your arms overhead"))
        }
        
        return (true, String(localized: "Powerful pose! Hold it!"))
    }
}

// MARK: - Virabhadrasana II (Поза Потока 1)

public struct VirabhadrasanaIIAlgorithm: YogaPoseAlgorithm {
    public let targetPoseName = "warrior_ii"
    
    public init() {}
    
    public func analyze(joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> (isCorrect: Bool, feedback: String) {
        guard let leftAnkle = joints[.leftAnkle],
              let rightAnkle = joints[.rightAnkle],
              let leftKnee = joints[.leftKnee],
              let rightKnee = joints[.rightKnee],
              let leftHip = joints[.leftHip],
              let rightHip = joints[.rightHip],
              let leftWrist = joints[.leftWrist],
              let rightWrist = joints[.rightWrist] else {
            return (false, String(localized: "Step fully into the frame, sideways"))
        }
        
        // Stance width
        let stanceWidth = abs(leftAnkle.x - rightAnkle.x)
        if stanceWidth < 0.3 {
            return (false, String(localized: "Step your feet wider apart"))
        }
        
        // Find which leg is forward (bent). Let's assume the one with lower Y (higher up in normalized) or simply the one with knee angle closest to 90.
        let leftKneeAngle = leftHip.angle(to: leftKnee, p3: leftAnkle)
        let rightKneeAngle = rightHip.angle(to: rightKnee, p3: rightAnkle)
        
        let isLeftForward = leftKneeAngle < rightKneeAngle
        let bentKneeAngle = isLeftForward ? leftKneeAngle : rightKneeAngle
        let straightKneeAngle = isLeftForward ? rightKneeAngle : leftKneeAngle
        
        if straightKneeAngle < 150 {
            return (false, String(localized: "Straighten your back leg"))
        }
        
        if bentKneeAngle > 130 {
            return (false, String(localized: "Bend your front knee more"))
        }
        
        if bentKneeAngle < 70 {
            return (false, String(localized: "Your front knee angle is too sharp"))
        }
        
        // Check arms (horizontal)
        // Y coordinate difference between wrists should be small
        let armSlope = abs(leftWrist.y - rightWrist.y)
        if armSlope > 0.15 {
            return (false, String(localized: "Keep your arms parallel to the floor"))
        }
        
        return (true, String(localized: "Beautiful Warrior II!"))
    }
}

// MARK: - Bakasana (Полет Дракона 3)

public struct BakasanaAlgorithm: YogaPoseAlgorithm {
    public let targetPoseName = "bakasana"
    
    public init() {}
    
    public func analyze(joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> (isCorrect: Bool, feedback: String) {
        guard let leftWrist = joints[.leftWrist],
              let leftElbow = joints[.leftElbow],
              let leftKnee = joints[.leftKnee],
              let leftAnkle = joints[.leftAnkle] else {
            return (false, String(localized: "The camera must see your full body from the side"))
        }
        
        // Crow pose: Weight on hands, knees on elbows, feet off the ground.
        // Wrists are at the bottom (y close to 1)
        // Ankles must be higher than wrists (lower Y value)
        if leftAnkle.y > leftWrist.y - 0.05 {
            return (false, String(localized: "Lift your feet off the floor"))
        }
        
        // Knees must be close to elbows
        let kneeElbowDist = hypot(leftKnee.x - leftElbow.x, leftKnee.y - leftElbow.y)
        if kneeElbowDist > 0.2 {
            return (false, String(localized: "Draw your knees higher toward your armpits"))
        }
        
        return (true, String(localized: "Great balance! You're flying!"))
    }
}

// MARK: - Balasana (Тихий океан 4)

public struct BalasanaAlgorithm: YogaPoseAlgorithm {
    public let targetPoseName = "balasana"
    
    public init() {}
    
    public func analyze(joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> (isCorrect: Bool, feedback: String) {
        guard let hip = joints[.leftHip] ?? joints[.rightHip],
              let shoulder = joints[.leftShoulder] ?? joints[.rightShoulder],
              let ankle = joints[.leftAnkle] ?? joints[.rightAnkle] else {
            return (false, String(localized: "Lie down on the mat, sideways to the camera"))
        }
        
        // Child's pose: Hips are very close to ankles. Shoulders are low to the ground.
        let hipAnkleDist = hypot(hip.x - ankle.x, hip.y - ankle.y)
        if hipAnkleDist > 0.2 {
            return (false, String(localized: "Lower your hips onto your heels"))
        }
        
        // Shoulders should be low (Y value close to ankles/hips)
        if shoulder.y < hip.y - 0.2 { // Assuming y=0 is top, y=1 is bottom
            return (false, String(localized: "Bring your chest and forehead to the mat"))
        }
        
        return (true, String(localized: "Breathe deeply. You are calm."))
    }
}

// MARK: - Generic Algorithm (Fallback)

public struct GenericPoseAlgorithm: YogaPoseAlgorithm {
    public let targetPoseName: String
    
    public init(name: String) {
        self.targetPoseName = name
    }
    
    public func analyze(joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> (isCorrect: Bool, feedback: String) {
        if joints.isEmpty {
            return (false, String(localized: "Step into frame"))
        }
        return (true, String(localized: "Tracking your pose..."))
    }
}

// MARK: - Analyzer Factory

public final class YogaPoseAnalyzer {
    public static func getAlgorithm(for poseName: String) -> YogaPoseAlgorithm {
        switch poseName {
        case "warrior_ii":
            return VirabhadrasanaIIAlgorithm()
        case "tadasana":
            return TadasanaAlgorithm()
        case "bakasana":
            return BakasanaAlgorithm()
        case "balasana":
            return BalasanaAlgorithm()
        case "utkatasana":
            return UtkatasanaAlgorithm()
        case "vrksasana":
            return TreePoseAlgorithm()
        case "downward_dog":
            return DownwardDogAlgorithm()
        default:
            return GenericPoseAlgorithm(name: poseName)
        }
    }
}
