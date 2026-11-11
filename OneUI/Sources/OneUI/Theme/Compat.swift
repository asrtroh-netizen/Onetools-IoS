import SwiftUI

// iOS 15 部署目标下的新 API 兜底。

extension View {
    /// 数值变化时数字滚动（iOS 17+），更早系统淡入淡出。
    @ViewBuilder
    func numericTransition() -> some View {
        if #available(iOS 17.0, *) {
            contentTransition(.numericText())
        } else {
            self
        }
    }

    /// 门面卡状态变化时给触感反馈（iOS 17+）。
    @ViewBuilder
    func sensoryFeedbackCompat(_ state: HeroState) -> some View {
        if #available(iOS 17.0, *) {
            sensoryFeedback(trigger: state) { _, new in
                switch new {
                case .ready: .success
                case .inactive: .warning
                case .activating: nil
                }
            }
        } else {
            self
        }
    }
}

/// `ViewThatFits`（iOS 16+）兜底：iOS 15 直接用第一个布局。
struct ViewThatFitsCompat<A: View, B: View>: View {
    let first: A
    let second: B

    init(@ViewBuilder _ content: () -> TupleView<(A, B)>) {
        let pair = content().value
        first = pair.0
        second = pair.1
    }

    var body: some View {
        if #available(iOS 16.0, *) {
            ViewThatFits(in: .horizontal) { first; second }
        } else {
            first
        }
    }
}
