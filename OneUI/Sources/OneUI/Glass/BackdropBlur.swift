import SwiftUI
import UIKit

/// Runtime-isolated backdrop blur. Uses private `CABackdropLayer` + `CAFilter("gaussianBlur")`
/// when present in self-signed builds for exact Flutter `ImageFilter.blur(sigma)` parity,
/// and degrades cleanly to Apple's public `UIVisualEffectView` whenever unavailable.
public struct OneBackdropBlurView: View {
    public static var preferPublicMaterialFallback: Bool = false
    public static var pureSwiftUISnapshotMode: Bool = false

    public let sigma: CGFloat

    public init(sigma: CGFloat) { self.sigma = sigma }

    public var body: some View {
        if Self.pureSwiftUISnapshotMode {
            Color.clear
        } else {
            OneBackdropBlurRepresentable(sigma: sigma)
        }
    }
}

private struct OneBackdropBlurRepresentable: UIViewRepresentable {
    let sigma: CGFloat

    func makeUIView(context: Context) -> UIView {
        let view = BackdropBlurContainer(sigma: sigma)
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        (uiView as? BackdropBlurContainer)?.sigma = sigma
    }
}

private final class BackdropBlurContainer: UIView {
    var sigma: CGFloat {
        didSet {
            if abs(oldValue - sigma) > 0.01 {
                applyBackdrop()
            }
        }
    }

    private let fallback = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
    private var privateBackdropLayer: CALayer?

    init(sigma: CGFloat) {
        self.sigma = sigma
        super.init(frame: .zero)
        isOpaque = false
        backgroundColor = .clear
        addSubview(fallback)
        fallback.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fallback.leadingAnchor.constraint(equalTo: leadingAnchor),
            fallback.trailingAnchor.constraint(equalTo: trailingAnchor),
            fallback.topAnchor.constraint(equalTo: topAnchor),
            fallback.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        applyBackdrop()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        privateBackdropLayer?.frame = bounds
    }

    private func applyBackdrop() {
        guard !OneBackdropBlurView.preferPublicMaterialFallback,
              sigma > 0,
              let backdropClass = NSClassFromString("CABackdropLayer") as? CALayer.Type,
              let filterClass = NSClassFromString("CAFilter") as? NSObject.Type else {
            privateBackdropLayer?.removeFromSuperlayer()
            privateBackdropLayer = nil
            fallback.isHidden = false
            return
        }

        let selector = NSSelectorFromString("filterWithType:")
        guard filterClass.responds(to: selector),
              let unmanaged = filterClass.perform(selector, with: "gaussianBlur") else {
            privateBackdropLayer?.removeFromSuperlayer()
            privateBackdropLayer = nil
            fallback.isHidden = false
            return
        }

        let blurFilter = unmanaged.takeUnretainedValue() as AnyObject
        blurFilter.setValue(NSNumber(value: Double(sigma)), forKey: "inputRadius")
        blurFilter.setValue(NSNumber(value: true), forKey: "inputNormalizeEdges")

        let targetLayer: CALayer
        if let existing = privateBackdropLayer {
            targetLayer = existing
        } else {
            let created = backdropClass.init()
            created.frame = bounds
            layer.insertSublayer(created, at: 0)
            privateBackdropLayer = created
            targetLayer = created
        }
        targetLayer.filters = [blurFilter]
        fallback.isHidden = true
    }
}
