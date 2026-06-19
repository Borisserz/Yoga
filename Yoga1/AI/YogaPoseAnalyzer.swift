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

// MARK: - Virabhadrasana II (Поза Потока 1)

public struct VirabhadrasanaIIAlgorithm: YogaPoseAlgorithm {
    public let targetPoseName = "Поза Потока 1"
    
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
            return (false, "Встаньте полностью в кадр боком")
        }
        
        // Stance width
        let stanceWidth = abs(leftAnkle.x - rightAnkle.x)
        if stanceWidth < 0.3 {
            return (false, "Расставьте ноги шире")
        }
        
        // Find which leg is forward (bent). Let's assume the one with lower Y (higher up in normalized) or simply the one with knee angle closest to 90.
        let leftKneeAngle = leftHip.angle(to: leftKnee, p3: leftAnkle)
        let rightKneeAngle = rightHip.angle(to: rightKnee, p3: rightAnkle)
        
        let isLeftForward = leftKneeAngle < rightKneeAngle
        let bentKneeAngle = isLeftForward ? leftKneeAngle : rightKneeAngle
        let straightKneeAngle = isLeftForward ? rightKneeAngle : leftKneeAngle
        
        if straightKneeAngle < 150 {
            return (false, "Выпрямите заднюю ногу")
        }
        
        if bentKneeAngle > 130 {
            return (false, "Согните переднее колено сильнее")
        }
        
        if bentKneeAngle < 70 {
            return (false, "Угол переднего колена слишком острый")
        }
        
        // Check arms (horizontal)
        // Y coordinate difference between wrists should be small
        let armSlope = abs(leftWrist.y - rightWrist.y)
        if armSlope > 0.15 {
            return (false, "Держите руки параллельно полу")
        }
        
        return (true, "Прекрасный Воин II!")
    }
}

// MARK: - Bakasana (Полет Дракона 3)

public struct BakasanaAlgorithm: YogaPoseAlgorithm {
    public let targetPoseName = "Полет Дракона 3"
    
    public init() {}
    
    public func analyze(joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> (isCorrect: Bool, feedback: String) {
        guard let leftWrist = joints[.leftWrist],
              let leftElbow = joints[.leftElbow],
              let leftKnee = joints[.leftKnee],
              let leftAnkle = joints[.leftAnkle] else {
            return (false, "Камера должна видеть вас сбоку целиком")
        }
        
        // Crow pose: Weight on hands, knees on elbows, feet off the ground.
        // Wrists are at the bottom (y close to 1)
        // Ankles must be higher than wrists (lower Y value)
        if leftAnkle.y > leftWrist.y - 0.05 {
            return (false, "Оторвите стопы от пола")
        }
        
        // Knees must be close to elbows
        let kneeElbowDist = hypot(leftKnee.x - leftElbow.x, leftKnee.y - leftElbow.y)
        if kneeElbowDist > 0.2 {
            return (false, "Подтяните колени выше к подмышкам")
        }
        
        return (true, "Отличный баланс! Вы летите!")
    }
}

// MARK: - Balasana (Тихий океан 4)

public struct BalasanaAlgorithm: YogaPoseAlgorithm {
    public let targetPoseName = "Тихий океан 4"
    
    public init() {}
    
    public func analyze(joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> (isCorrect: Bool, feedback: String) {
        guard let hip = joints[.leftHip] ?? joints[.rightHip],
              let shoulder = joints[.leftShoulder] ?? joints[.rightShoulder],
              let ankle = joints[.leftAnkle] ?? joints[.rightAnkle] else {
            return (false, "Опуститесь на коврик боком к камере")
        }
        
        // Child's pose: Hips are very close to ankles. Shoulders are low to the ground.
        let hipAnkleDist = hypot(hip.x - ankle.x, hip.y - ankle.y)
        if hipAnkleDist > 0.2 {
            return (false, "Опустите таз на пятки")
        }
        
        // Shoulders should be low (Y value close to ankles/hips)
        if shoulder.y < hip.y - 0.2 { // Assuming y=0 is top, y=1 is bottom
            return (false, "Опустите грудь и лоб на коврик")
        }
        
        return (true, "Дышите глубоко. Вы спокойны.")
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
        case "Поза Потока 1":
            return VirabhadrasanaIIAlgorithm()
        case "Сила Гор 2":
            return TadasanaAlgorithm()
        case "Полет Дракона 3":
            return BakasanaAlgorithm()
        case "Тихий океан 4":
            return BalasanaAlgorithm()
        case "Огненный шар 5":
            return UtkatasanaAlgorithm()
        case "Дерево Жизни 6":
            return TreePoseAlgorithm()
        case "Собака мордой вниз 7":
            return DownwardDogAlgorithm()
        default:
            return GenericPoseAlgorithm(name: poseName)
        }
    }
}
