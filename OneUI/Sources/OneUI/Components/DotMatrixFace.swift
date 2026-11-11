import SwiftUI

/// 点阵脸：笑 = 就绪，哭 = 激活中 / 未激活。形状本身编码状态，不只靠颜色。
public enum DotMatrixMood: Sendable { case smile, frown }

public struct DotMatrixFace: View {
    let mood: DotMatrixMood
    let size: CGFloat
    var color: Color = OnePalette.onSurface

    public init(mood: DotMatrixMood, size: CGFloat = 36, color: Color = OnePalette.onSurface) {
        self.mood = mood
        self.size = size
        self.color = color
    }

    // 7×7，按行排列。Flutter 版是 49 行竖排数组，这里改成可读的字符画。
    private static let smile = [
        ".......",
        ".#...#.",
        ".#...#.",
        ".......",
        ".#...#.",
        "..###..",
        ".......",
    ]
    private static let frown = [
        ".......",
        ".#...#.",
        ".#...#.",
        ".......",
        "..###..",
        ".#...#.",
        ".......",
    ]

    public var body: some View {
        let rows = mood == .smile ? Self.smile : Self.frown
        Canvas { ctx, canvas in
            let cells = 7
            let gap = canvas.width * 0.08
            let cell = (canvas.width - gap * CGFloat(cells - 1)) / CGFloat(cells)
            let r = cell * 0.42
            for (y, row) in rows.enumerated() {
                for (x, ch) in row.enumerated() {
                    let cx = CGFloat(x) * (cell + gap) + cell / 2
                    let cy = CGFloat(y) * (cell + gap) + cell / 2
                    let dot = Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
                    ctx.fill(dot, with: .color(ch == "#" ? color : color.opacity(0.14)))
                }
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel(Text(mood == .smile ? "就绪" : "未就绪"))
    }
}
