import Foundation
import Vision
import CoreGraphics

// MARK: - Geometry Utils

public extension CGPoint {
    func angle(to p2: CGPoint, p3: CGPoint) -> CGFloat {
        let v1 = CGVector(dx: p1.x - self.x, dy: p1.y - self.y)
        let v2 = CGVector(dx: p3.x - p2.x, dy: p3.y - p2.y)
        // Actually, angle between 3 points: self is point 1, p2 is vertex, p3 is point 3.
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
    public let targetPoseName = "Поза дерева"
    
    public init() {}
    
    public func analyze(joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> (isCorrect: Bool, feedback: String) {
        guard let leftAnkle = joints[.leftAnkle],
              let rightAnkle = joints[.rightAnkle],
              let leftKnee = joints[.leftKnee],
              let rightKnee = joints[.rightKnee],
              let leftHip = joints[.leftHip],
              let rightHip = joints[.rightHip] else {
            return (false, "Встаньте полностью в кадр")
        }
        
        // Tree pose: One foot is lifted and placed on the inner thigh of the other leg.
        // We can check if one ankle is significantly higher than the other (y is from bottom to top in Vision normalized coords, but CameraManager normalizes y = 1.0 - y, so 0 is top, 1 is bottom).
        // Let's assume the camera manager uses: y=0 is top, y=1 is bottom.
        
        let leftIsLifted = leftAnkle.y < rightKnee.y // Left ankle is higher than right knee (lower y value)
        let rightIsLifted = rightAnkle.y < leftKnee.y
        
        if !leftIsLifted && !rightIsLifted {
            return (false, "Поднимите одну ногу и поставьте её на внутреннюю часть бедра")
        }
        
        // Check knee angle for the lifted leg
        let liftedKneeAngle = leftIsLifted ? 
            leftHip.angle(to: leftKnee, p3: leftAnkle) : 
            rightHip.angle(to: rightKnee, p3: rightAnkle)
        
        // Lifted knee should be bent sharply
        if liftedKneeAngle > 90 {
            return (false, "Согните поднятую ногу сильнее")
        }
        
        // Check standing leg straightness
        let standingKneeAngle = leftIsLifted ? 
            rightHip.angle(to: rightKnee, p3: rightAnkle) : 
            leftHip.angle(to: leftKnee, p3: leftAnkle)
            
        if standingKneeAngle < 160 {
            return (false, "Выпрямите опорную ногу")
        }
        
        return (true, "Отлично! Держите баланс.")
    }
}

// MARK: - Downward Dog (Адхо Мукха Шванасана)

public struct DownwardDogAlgorithm: YogaPoseAlgorithm {
    public let targetPoseName = "Собака мордой вниз"
    
    public init() {}
    
    public func analyze(joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> (isCorrect: Bool, feedback: String) {
        guard let leftWrist = joints[.leftWrist],
              let leftShoulder = joints[.leftShoulder],
              let leftHip = joints[.leftHip],
              let leftAnkle = joints[.leftAnkle] else {
            return (false, "Встаньте боком к камере")
        }
        
        // Downward dog forms a triangle (hands, hips, feet)
        // Check angle at hips (should be around 60-90 degrees)
        let hipAngle = leftShoulder.angle(to: leftHip, p3: leftAnkle)
        
        if hipAngle > 110 {
            return (false, "Поднимите таз выше, сделайте угол острее")
        }
        
        if hipAngle < 45 {
            return (false, "Разойдитесь шире, угол слишком острый")
        }
        
        // Check arms straightness
        let armAngle = leftWrist.angle(to: leftShoulder, p3: leftHip)
        if armAngle < 150 {
            return (false, "Выпрямите руки и вытяните спину")
        }
        
        return (true, "Идеальная собака мордой вниз!")
    }
}

// MARK: - Tadasana (Сила Гор 2)

public struct TadasanaAlgorithm: YogaPoseAlgorithm {
    public let targetPoseName = "Сила Гор 2"
    
    public init() {}
    
    public func analyze(joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> (isCorrect: Bool, feedback: String) {
        guard let leftAnkle = joints[.leftAnkle],
              let rightAnkle = joints[.rightAnkle],
              let leftKnee = joints[.leftKnee],
              let leftHip = joints[.leftHip],
              let leftShoulder = joints[.leftShoulder] else {
            return (false, "Встаньте полностью в кадр")
        }
        
        // Tadasana: Standing perfectly straight.
        // Check if knees are straight
        let kneeAngle = leftHip.angle(to: leftKnee, p3: leftAnkle)
        if kneeAngle < 165 {
            return (false, "Выпрямите колени")
        }
        
        // Check if feet are somewhat close to each other
        let feetDistance = abs(leftAnkle.x - rightAnkle.x)
        if feetDistance > 0.2 { // normalized distance
            return (false, "Сведите стопы ближе")
        }
        
        // Check if shoulders are above hips (standing straight)
        let spineAngle = leftKnee.angle(to: leftHip, p3: leftShoulder)
        if spineAngle < 165 {
            return (false, "Выпрямите спину и расправьте плечи")
        }
        
        return (true, "Отлично, держите позу горы!")
    }
}

// MARK: - Utkatasana (Огненный шар 5)

public struct UtkatasanaAlgorithm: YogaPoseAlgorithm {
    public let targetPoseName = "Огненный шар 5"
    
    public init() {}
    
    public func analyze(joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> (isCorrect: Bool, feedback: String) {
        guard let leftAnkle = joints[.leftAnkle],
              let leftKnee = joints[.leftKnee],
              let leftHip = joints[.leftHip],
              let leftShoulder = joints[.leftShoulder],
              let leftWrist = joints[.leftWrist] else {
            return (false, "Встаньте боком к камере")
        }
        
        // Chair pose: Knees bent, hips low, arms raised.
        let kneeAngle = leftHip.angle(to: leftKnee, p3: leftAnkle)
        if kneeAngle > 140 {
            return (false, "Присядьте ниже, согните колени")
        }
        if kneeAngle < 70 {
            return (false, "Не приседайте так глубоко")
        }
        
        let hipAngle = leftKnee.angle(to: leftHip, p3: leftShoulder)
        if hipAngle < 90 {
            return (false, "Поднимите грудь, не наклоняйтесь слишком сильно")
        }
        
        // Arms should be raised (wrist higher than shoulder) -> y is 0 at top, 1 at bottom
        if leftWrist.y > leftShoulder.y {
            return (false, "Поднимите руки вверх")
        }
        
        return (true, "Мощная поза! Держим!")
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
            return (false, "Встаньте в кадр")
        }
        return (true, "Следим за позой...")
    }
}

// MARK: - Analyzer Factory

public final class YogaPoseAnalyzer {
    public static func getAlgorithm(for poseName: String) -> YogaPoseAlgorithm {
        switch poseName {
        case "Поза дерева":
            return TreePoseAlgorithm()
        case "Собака мордой вниз":
            return DownwardDogAlgorithm()
        case "Сила Гор 2":
            return TadasanaAlgorithm()
        case "Огненный шар 5":
            return UtkatasanaAlgorithm()
        default:
            return GenericPoseAlgorithm(name: poseName)
        }
    }
}
