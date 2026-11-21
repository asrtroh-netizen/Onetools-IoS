import SwiftUI
import UIKit

public struct OneFilledButton: View {
    let title: String; let action: () -> Void
    public init(_ title: String, action: @escaping () -> Void) { self.title = title; self.action = action }
    public var body: some View { Button(title, action: action).buttonStyle(OneFilledButtonStyle()) }
}
public struct OneOutlinedButton: View {
    let title: String; let action: () -> Void
    public init(_ title: String, action: @escaping () -> Void) { self.title = title; self.action = action }
    public var body: some View { Button(title, action: action).buttonStyle(OneOutlinedButtonStyle()) }
}
public struct OneTextButton: View {
    let title: String; let action: () -> Void
    public init(_ title: String, action: @escaping () -> Void) { self.title = title; self.action = action }
    public var body: some View { Button(title, action: action).buttonStyle(OneTextButtonStyle()) }
}
public struct OneIconButton: View {
    let name: String; let action: () -> Void
    public init(_ name: String, action: @escaping () -> Void) { self.name = name; self.action = action }
    public var body: some View { Button(action: action) { MaterialIcon(name: name, size: 20, color: OnePalette.onSurface).frame(width: 44, height: 44) }.buttonStyle(OneIconButtonStyle()) }
}

public struct OneFilledButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var enabled
    public init() {}
    public func makeBody(configuration: Configuration) -> some View { configuration.label.font(OneText.labelLarge()).foregroundStyle(OnePalette.surface).frame(maxWidth: .infinity, minHeight: OneMetrics.control).padding(.horizontal, OneMetrics.space16).background(RoundedRectangle(cornerRadius: OneMetrics.radiusTile, style: .circular).fill(OnePalette.onSurface)).overlay(RoundedRectangle(cornerRadius: OneMetrics.radiusTile, style: .circular).strokeBorder(OneGlass.stroke, lineWidth: OneMetrics.stroke)).opacity(enabled ? 1 : 0.38).inkRipple(overlayColor: OnePalette.surface.opacity(0.10)) }
}
public struct OneOutlinedButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var enabled
    public init() {}
    public func makeBody(configuration: Configuration) -> some View { configuration.label.font(OneText.labelLarge()).foregroundStyle(OnePalette.onSurface).frame(maxWidth: .infinity, minHeight: OneMetrics.control).padding(.horizontal, OneMetrics.space16).background(RoundedRectangle(cornerRadius: OneMetrics.radiusTile, style: .circular).fill(.clear)).overlay(RoundedRectangle(cornerRadius: OneMetrics.radiusTile, style: .circular).strokeBorder(OneGlass.stroke, lineWidth: OneMetrics.stroke)).opacity(enabled ? 1 : 0.38).inkRipple(overlayColor: OnePalette.onSurface.opacity(0.10)) }
}
public struct OneTextButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var enabled
    public init() {}
    public func makeBody(configuration: Configuration) -> some View { configuration.label.font(OneText.labelLarge()).foregroundStyle(OnePalette.onSurface).frame(minWidth: 44, minHeight: 44).padding(.horizontal, OneMetrics.space12).background(RoundedRectangle(cornerRadius: OneMetrics.radiusTile, style: .circular).fill(.clear)).overlay(RoundedRectangle(cornerRadius: OneMetrics.radiusTile, style: .circular).strokeBorder(OneGlass.stroke, lineWidth: OneMetrics.stroke)).opacity(enabled ? 1 : 0.38).inkRipple(overlayColor: OnePalette.onSurface.opacity(0.10)) }
}
public struct OneIconButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var enabled
    public init() {}
    public func makeBody(configuration: Configuration) -> some View { configuration.label.background(RoundedRectangle(cornerRadius: OneMetrics.radiusTile, style: .circular).fill(.clear)).overlay(RoundedRectangle(cornerRadius: OneMetrics.radiusTile, style: .circular).strokeBorder(OneGlass.stroke, lineWidth: OneMetrics.stroke)).opacity(enabled ? 1 : 0.38).inkRipple(overlayColor: OnePalette.onSurface.opacity(0.10)) }
}

public struct OneTextField: View {
    let title: String; @Binding var text: String; let error: String?
    @FocusState private var focused: Bool
    public init(_ title: String, text: Binding<String>, error: String? = nil) { self.title = title; self._text = text; self.error = error }
    public var body: some View {
        VStack(alignment: .leading, spacing: OneMetrics.space4) {
            TextField(title, text: $text)
                .focused($focused)
                .padding(.horizontal, OneMetrics.space16)
                .frame(minHeight: OneMetrics.control)
                .glassSurface(.sheer, radius: OneMetrics.radiusTile, stroke: nil, elevated: false)
                .overlay {
                    RoundedRectangle(cornerRadius: OneMetrics.radiusTile, style: .circular)
                        .strokeBorder(error == nil ? (focused ? OnePalette.accent : OneGlass.stroke) : OnePalette.error,
                                      lineWidth: focused || error != nil ? 2 : OneMetrics.stroke)
                }
            if let error { Text(error).font(OneText.labelSmall()).foregroundStyle(OnePalette.error) }
        }
    }
}
public struct OneDivider: View {
    public init() {}
    public var body: some View { Rectangle().fill(OnePalette.outlineVariant.opacity(0.65)).frame(height: 0.5) }
}
public struct OneSnackBarBanner: View {
    let message: String; let actionTitle: String?; let action: (() -> Void)?
    public init(_ message: String, actionTitle: String? = nil, action: (() -> Void)? = nil) { self.message = message; self.actionTitle = actionTitle; self.action = action }
    public var body: some View { HStack(spacing: OneMetrics.space12) { Text(message).font(OneText.bodyMedium()).foregroundStyle(OnePalette.surface); Spacer(); if let action, let actionTitle { Button(actionTitle, action: action).font(OneText.labelLarge()).foregroundStyle(OnePalette.surface) } }.padding(.horizontal, OneMetrics.space16).frame(minHeight: 48).background(RoundedRectangle(cornerRadius: OneMetrics.radiusTile, style: .circular).fill(OnePalette.onSurface)) }
}

public struct SystemSwitch: View {
    @Binding var isOn: Bool
    public init(isOn: Binding<Bool>) { self._isOn = isOn }
    public var body: some View { OneSystemSwitchRepresentable(isOn: $isOn).frame(width: 51, height: 31) }
}
public struct SystemSpinner: View {
    public init() {}
    public var body: some View { OneSystemSpinnerRepresentable().frame(width: 20, height: 20) }
}

private struct OneSystemSwitchRepresentable: UIViewRepresentable {
    @Binding var isOn: Bool

    func makeUIView(context: Context) -> UISwitch {
        let control = UISwitch()
        control.addTarget(context.coordinator, action: #selector(Coordinator.changed(_:)), for: .valueChanged)
        return control
    }

    func updateUIView(_ uiView: UISwitch, context: Context) {
        uiView.setOn(isOn, animated: false)
        uiView.onTintColor = .label
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject {
        var parent: OneSystemSwitchRepresentable
        init(_ parent: OneSystemSwitchRepresentable) { self.parent = parent }
        @objc func changed(_ sender: UISwitch) { parent.isOn = sender.isOn }
    }
}

private struct OneSystemSpinnerRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .medium)
        view.color = .label
        view.startAnimating()
        return view
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        if !uiView.isAnimating { uiView.startAnimating() }
    }
}
