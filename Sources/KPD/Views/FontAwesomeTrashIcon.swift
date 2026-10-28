import SwiftUI

// Font Awesome Free 6.7.2 "trash" icon by @fontawesome.
// Copyright 2024 Fonticons, Inc. https://fontawesome.com
// Icon license: CC BY 4.0 https://creativecommons.org/licenses/by/4.0/
// Adapted from SVG to a scalable SwiftUI Path; see THIRD_PARTY_NOTICES.md.
struct FontAwesomeTrashIcon: Shape {
    func path(in rect: CGRect) -> Path {
        let scale = min(rect.width / 448, rect.height / 512)
        let xOffset = rect.midX - (448 * scale / 2)
        let yOffset = rect.midY - (512 * scale / 2)

        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: xOffset + x * scale, y: yOffset + y * scale)
        }

        var path = Path()
        path.move(to: point(135.2, 17.7))
        path.addLine(to: point(128, 32))
        path.addLine(to: point(32, 32))
        path.addCurve(to: point(0, 64), control1: point(14.3, 32), control2: point(0, 46.3))
        path.addCurve(to: point(32, 96), control1: point(0, 81.7), control2: point(14.3, 96))
        path.addLine(to: point(416, 96))
        path.addCurve(to: point(448, 64), control1: point(433.7, 96), control2: point(448, 81.7))
        path.addCurve(to: point(416, 32), control1: point(448, 46.3), control2: point(433.7, 32))
        path.addLine(to: point(320, 32))
        path.addLine(to: point(312.8, 17.7))
        path.addCurve(to: point(284.2, 0), control1: point(307.4, 6.8), control2: point(296.3, 0))
        path.addLine(to: point(163.8, 0))
        path.addCurve(to: point(135.2, 17.7), control1: point(151.7, 0), control2: point(140.6, 6.8))
        path.closeSubpath()

        path.move(to: point(416, 128))
        path.addLine(to: point(32, 128))
        path.addLine(to: point(53.2, 467))
        path.addCurve(to: point(101.1, 512), control1: point(54.8, 492.3), control2: point(75.8, 512))
        path.addLine(to: point(346.9, 512))
        path.addCurve(to: point(394.8, 467), control1: point(372.2, 512), control2: point(393.2, 492.3))
        path.addLine(to: point(416, 128))
        path.closeSubpath()
        return path
    }
}
