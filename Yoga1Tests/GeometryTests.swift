import XCTest
import CoreGraphics
@testable import Yoga1

final class GeometryTests: XCTestCase {

    func testRightAngle() {
        // Vertex at origin, arms along +Y and +X → 90°.
        let p1 = CGPoint(x: 0, y: 1)
        let vertex = CGPoint(x: 0, y: 0)
        let p3 = CGPoint(x: 1, y: 0)
        XCTAssertEqual(p1.angle(to: vertex, p3: p3), 90, accuracy: 0.5)
    }

    func testStraightAngle() {
        // Collinear points → 180°.
        let p1 = CGPoint(x: 0, y: 0)
        let vertex = CGPoint(x: 0, y: 1)
        let p3 = CGPoint(x: 0, y: 2)
        XCTAssertEqual(p1.angle(to: vertex, p3: p3), 180, accuracy: 0.5)
    }

    func testFortyFiveDegrees() {
        let p1 = CGPoint(x: 1, y: 0)
        let vertex = CGPoint(x: 0, y: 0)
        let p3 = CGPoint(x: 1, y: 1)
        XCTAssertEqual(p1.angle(to: vertex, p3: p3), 45, accuracy: 0.5)
    }
}
