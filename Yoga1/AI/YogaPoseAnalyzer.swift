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

// MARK: - Side Resolution Helper

/// A consistent set of joints for one side of the body. Side-on poses are
/// analysed using whichever side the Vision request detected most completely,
/// so the coach works regardless of which way the user faces the camera.
struct SidePoints {
    let shoulder: CGPoint
    let elbow: CGPoint
    let wrist: CGPoint
    let hip: CGPoint
    let knee: CGPoint
    let ankle: CGPoint
}

/// Returns the most complete body side (left preferred, right as fallback).
func bestSide(_ joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> SidePoints? {
    func side(_ s: VNHumanBodyPoseObservation.JointName,
              _ e: VNHumanBodyPoseObservation.JointName,
              _ w: VNHumanBodyPoseObservation.JointName,
              _ h: VNHumanBodyPoseObservation.JointName,
              _ k: VNHumanBodyPoseObservation.JointName,
              _ a: VNHumanBodyPoseObservation.JointName) -> SidePoints? {
        guard let sh = joints[s], let el = joints[e], let wr = joints[w],
              let hp = joints[h], let kn = joints[k], let an = joints[a] else { return nil }
        return SidePoints(shoulder: sh, elbow: el, wrist: wr, hip: hp, knee: kn, ankle: an)
    }
    return side(.leftShoulder, .leftElbow, .leftWrist, .leftHip, .leftKnee, .leftAnkle)
        ?? side(.rightShoulder, .rightElbow, .rightWrist, .rightHip, .rightKnee, .rightAnkle)
}

// MARK: - Plank (Phalakasana)

public struct PlankAlgorithm: YogaPoseAlgorithm {
    public let targetPoseName = "plank"

    public init() {}

    public func analyze(joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> (isCorrect: Bool, feedback: String) {
        guard let s = bestSide(joints) else {
            return (false, String(localized: "Turn sideways so the camera sees your whole body"))
        }

        // The body should be a single straight line: shoulder–hip–ankle ≈ 180°.
        let bodyLine = s.shoulder.angle(to: s.hip, p3: s.ankle)

        // Where the hip *should* sit on the shoulder→ankle line, to tell a
        // sagging lower back apart from piked-up hips.
        let dx = s.ankle.x - s.shoulder.x
        let t = abs(dx) < 0.001 ? 0.5 : (s.hip.x - s.shoulder.x) / dx
        let expectedHipY = s.shoulder.y + min(max(t, 0), 1) * (s.ankle.y - s.shoulder.y)

        if bodyLine < 162 {
            if s.hip.y > expectedHipY + 0.03 {
                return (false, String(localized: "Lift your hips — don't let them sag"))
            } else {
                return (false, String(localized: "Lower your hips — keep your body in one line"))
            }
        }

        // High plank: arms fairly straight with shoulders stacked over wrists.
        let armAngle = s.shoulder.angle(to: s.elbow, p3: s.wrist)
        if armAngle < 150 {
            return (false, String(localized: "Straighten your arms, stack shoulders over wrists"))
        }

        return (true, String(localized: "Strong plank! Hold steady."))
    }
}

// MARK: - Cobra (Bhujangasana)

public struct CobraAlgorithm: YogaPoseAlgorithm {
    public let targetPoseName = "cobra"

    public init() {}

    public func analyze(joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> (isCorrect: Bool, feedback: String) {
        guard let s = bestSide(joints) else {
            return (false, String(localized: "Lie on your stomach, sideways to the camera"))
        }

        // Chest lifted: shoulders clearly higher (smaller y) than the hips.
        let lift = s.hip.y - s.shoulder.y
        if lift < 0.08 {
            return (false, String(localized: "Lift your chest higher into the back bend"))
        }

        // Hips and legs stay grounded — the hip shouldn't rise above the knees.
        if s.hip.y < s.knee.y - 0.08 {
            return (false, String(localized: "Keep your hips and legs on the mat"))
        }

        // Protect the lower back — keep a soft bend, don't lock the elbows.
        let armAngle = s.shoulder.angle(to: s.elbow, p3: s.wrist)
        if armAngle > 176 {
            return (false, String(localized: "Soften your elbows and relax the shoulders"))
        }

        return (true, String(localized: "Beautiful cobra — open the heart."))
    }
}

// MARK: - Triangle (Trikonasana)

public struct TriangleAlgorithm: YogaPoseAlgorithm {
    public let targetPoseName = "triangle"

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
            return (false, String(localized: "Step fully into the frame, facing the camera"))
        }

        // Wide stance.
        let stance = abs(leftAnkle.x - rightAnkle.x)
        if stance < 0.28 {
            return (false, String(localized: "Step your feet wider apart"))
        }

        // Both legs straight.
        let leftKneeAngle = leftHip.angle(to: leftKnee, p3: leftAnkle)
        let rightKneeAngle = rightHip.angle(to: rightKnee, p3: rightAnkle)
        if min(leftKneeAngle, rightKneeAngle) < 155 {
            return (false, String(localized: "Keep both legs straight"))
        }

        // Arms reach in one long line — one up, one down.
        let armSpread = abs(leftWrist.y - rightWrist.y)
        if armSpread < 0.3 {
            return (false, String(localized: "Open your arms in a line — one up, one down"))
        }

        return (true, String(localized: "Lovely triangle — lengthen both sides."))
    }
}

// MARK: - Boat (Navasana)

public struct BoatAlgorithm: YogaPoseAlgorithm {
    public let targetPoseName = "boat"

    public init() {}

    public func analyze(joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> (isCorrect: Bool, feedback: String) {
        guard let s = bestSide(joints) else {
            return (false, String(localized: "Sit sideways to the camera, in full view"))
        }

        // Feet lifted off the floor (higher than the hips).
        if s.ankle.y > s.hip.y - 0.02 {
            return (false, String(localized: "Lift your legs off the floor"))
        }

        // Torso and legs form a V at the hips.
        let vAngle = s.shoulder.angle(to: s.hip, p3: s.ankle)
        if vAngle > 120 {
            return (false, String(localized: "Lean back and lift into a V shape"))
        }
        if vAngle < 35 {
            return (false, String(localized: "Open the V a little and lift your chest"))
        }

        // Legs reasonably straight.
        let kneeAngle = s.hip.angle(to: s.knee, p3: s.ankle)
        if kneeAngle < 130 {
            return (false, String(localized: "Straighten your legs"))
        }

        return (true, String(localized: "Strong core — hold the boat!"))
    }
}

// MARK: - Warrior I (Virabhadrasana I)

public struct WarriorIAlgorithm: YogaPoseAlgorithm {
    public let targetPoseName = "warrior_i"

    public init() {}

    public func analyze(joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> (isCorrect: Bool, feedback: String) {
        guard let leftAnkle = joints[.leftAnkle],
              let rightAnkle = joints[.rightAnkle],
              let leftKnee = joints[.leftKnee],
              let rightKnee = joints[.rightKnee],
              let leftHip = joints[.leftHip],
              let rightHip = joints[.rightHip],
              let leftWrist = joints[.leftWrist],
              let rightWrist = joints[.rightWrist],
              let leftShoulder = joints[.leftShoulder],
              let rightShoulder = joints[.rightShoulder] else {
            return (false, String(localized: "Step fully into the frame"))
        }

        // A lunge stance — front knee bent, back leg straight.
        let leftKneeAngle = leftHip.angle(to: leftKnee, p3: leftAnkle)
        let rightKneeAngle = rightHip.angle(to: rightKnee, p3: rightAnkle)
        let bent = min(leftKneeAngle, rightKneeAngle)
        let straight = max(leftKneeAngle, rightKneeAngle)

        if straight < 150 {
            return (false, String(localized: "Straighten your back leg"))
        }
        if bent > 130 {
            return (false, String(localized: "Bend your front knee toward 90°"))
        }
        if bent < 70 {
            return (false, String(localized: "Don't dip your front knee too low"))
        }

        // Both arms reach overhead.
        if leftWrist.y > leftShoulder.y || rightWrist.y > rightShoulder.y {
            return (false, String(localized: "Reach both arms overhead"))
        }

        return (true, String(localized: "Mighty Warrior I!"))
    }
}

// MARK: - Half Moon (Ardha Chandrasana)

public struct HalfMoonAlgorithm: YogaPoseAlgorithm {
    public let targetPoseName = "half_moon"

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

        // One leg lifts up toward parallel with the floor.
        let leftLifted = leftAnkle.y < rightAnkle.y - 0.15
        let rightLifted = rightAnkle.y < leftAnkle.y - 0.15
        if !leftLifted && !rightLifted {
            return (false, String(localized: "Lift one leg up, parallel to the floor"))
        }

        // The standing leg stays straight.
        let standingKneeAngle = leftLifted
            ? rightHip.angle(to: rightKnee, p3: rightAnkle)
            : leftHip.angle(to: leftKnee, p3: leftAnkle)
        if standingKneeAngle < 160 {
            return (false, String(localized: "Straighten your standing leg"))
        }

        // The lifted leg extends long.
        let liftedKneeAngle = leftLifted
            ? leftHip.angle(to: leftKnee, p3: leftAnkle)
            : rightHip.angle(to: rightKnee, p3: rightAnkle)
        if liftedKneeAngle < 150 {
            return (false, String(localized: "Extend your lifted leg straight"))
        }

        return (true, String(localized: "Floating half moon — find your balance!"))
    }
}

// MARK: - Camel (Ustrasana)

public struct CamelAlgorithm: YogaPoseAlgorithm {
    public let targetPoseName = "camel"

    public init() {}

    public func analyze(joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> (isCorrect: Bool, feedback: String) {
        guard let s = bestSide(joints) else {
            return (false, String(localized: "Kneel sideways to the camera"))
        }

        // Kneeling — shins on the floor, knees deeply bent.
        let kneeAngle = s.hip.angle(to: s.knee, p3: s.ankle)
        if kneeAngle > 130 {
            return (false, String(localized: "Kneel down with hips over your knees"))
        }

        // Thighs vertical: hips lifted well above the knees and pressed forward.
        if s.hip.y > s.knee.y - 0.12 {
            return (false, String(localized: "Lift your hips and press them forward"))
        }

        // Back bend: chest opens up and back, shoulders above the hips.
        if s.shoulder.y > s.hip.y {
            return (false, String(localized: "Open your chest and arch back"))
        }

        return (true, String(localized: "Deep camel — breathe into the stretch."))
    }
}

// MARK: - Bridge (Setu Bandhasana)

public struct BridgeAlgorithm: YogaPoseAlgorithm {
    public let targetPoseName = "bridge"

    public init() {}

    public func analyze(joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> (isCorrect: Bool, feedback: String) {
        guard let s = bestSide(joints) else {
            return (false, String(localized: "Lie on your back, sideways to the camera"))
        }

        // Hips lift toward the ceiling (higher than the grounded shoulders).
        if s.hip.y > s.shoulder.y - 0.04 {
            return (false, String(localized: "Lift your hips toward the ceiling"))
        }

        // Knees bent with heels tucked under.
        let kneeAngle = s.hip.angle(to: s.knee, p3: s.ankle)
        if kneeAngle > 120 {
            return (false, String(localized: "Bend your knees, bring your heels closer"))
        }

        // Shoulder–hip–knee forms a straight ramp.
        let line = s.shoulder.angle(to: s.hip, p3: s.knee)
        if line < 150 {
            return (false, String(localized: "Push your hips higher into a straight line"))
        }

        return (true, String(localized: "Strong bridge — lift and breathe."))
    }
}

// MARK: - Seated Forward Bend (Paschimottanasana)

public struct SeatedForwardBendAlgorithm: YogaPoseAlgorithm {
    public let targetPoseName = "seated_forward_bend"

    public init() {}

    public func analyze(joints: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> (isCorrect: Bool, feedback: String) {
        guard let s = bestSide(joints) else {
            return (false, String(localized: "Sit sideways to the camera, legs in view"))
        }

        // Legs extended straight in front.
        let kneeAngle = s.hip.angle(to: s.knee, p3: s.ankle)
        if kneeAngle < 150 {
            return (false, String(localized: "Straighten your legs in front of you"))
        }

        // Fold forward from the hips — small torso-to-leg angle.
        let fold = s.shoulder.angle(to: s.hip, p3: s.ankle)
        if fold > 75 {
            return (false, String(localized: "Hinge at the hips and fold forward"))
        }

        return (true, String(localized: "Lovely fold — relax your neck."))
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
        case "plank":
            return PlankAlgorithm()
        case "cobra":
            return CobraAlgorithm()
        case "triangle":
            return TriangleAlgorithm()
        case "boat":
            return BoatAlgorithm()
        case "warrior_i":
            return WarriorIAlgorithm()
        case "half_moon":
            return HalfMoonAlgorithm()
        case "camel":
            return CamelAlgorithm()
        case "bridge":
            return BridgeAlgorithm()
        case "seated_forward_bend":
            return SeatedForwardBendAlgorithm()
        default:
            return GenericPoseAlgorithm(name: poseName)
        }
    }
}
