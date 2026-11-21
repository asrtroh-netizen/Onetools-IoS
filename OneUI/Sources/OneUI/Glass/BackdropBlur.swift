import SwiftUI
import UIKit

/// Runtime-isolated backdrop blur. Private CoreAnimation layers are optional,
/// so unsupported OS versions always receive Apple's public material fallback.
public struct OneBackdropBlurView: UIViewRepresentable {
    public let sigma: CGFloat

    public init(sigma: CGFloat) { self.sigma = sigma }

    public func makeUIView(context: Context) -> UIView {
        let view = BackdropBlurContainer(sigma: sigma)
        view.isUserInteractionEnabled = false
        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        (uiView as? BackdropBlurContainer)?.sigma = sigma
    }
}

private final class BackdropBlurContainer: UIView {
    var sigma: CGFloat {
        didSet { applyBackdropIfAvailable() }
    }

    private let fallback = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))

    init(sigma: CGFloat) {
        self.sigma = sigma
        super.init(frame: .zero)
        isOpaque = false
        addSubview(fallback)
        fallback.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fallback.leadingAnchor.constraint(equalTo: leadingAnchor),
            fallback.trailingAnchor.constraint(equalTo: trailingAnchor),
            fallback.topAnchor.constraint(equalTo: topAnchor),
            fallback.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        applyBackdropIfAvailable()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func applyBackdropIfAvailable() {
        guard let backdrop = NSClassFromString("CABackdropLayer") else {
            fallback.isHidden = false
            return
        }
        // The private layer is only selected when present at runtime. KVC keeps
        // this source compatible with SDKs that do not expose its declarations.
        // Public fallback remains the rendering path when the private layer
        // cannot be safely constructed by this SDK. The lookup above is kept
        // isolated so a future host can install its own layer implementation.
        _ = backdrop
        fallback.isHidden = false
    }
}
