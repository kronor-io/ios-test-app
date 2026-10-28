//
//  Theme.swift
//  kronor-test-app
//

import SwiftUI

/// Kronor's brand colors, as used on kronor.io. The green is the asset
/// catalog's accent color, so it also tints every control in the app.
extension Color {
    static let kronorGreen = Color.accentColor
    static let kronorCream = Color(red: 0xF4 / 255, green: 0xF0 / 255, blue: 0xCE / 255)
}

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 50)
            .foregroundStyle(isEnabled ? Color.kronorCream : Color.secondary)
            .background(
                isEnabled ? Color.kronorGreen.opacity(configuration.isPressed ? 0.8 : 1) : Color(.tertiarySystemFill),
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var kronorPrimary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

struct KronorHeader: View {
    var body: some View {
        HStack(spacing: 12) {
            Image("KronorLogo")
                .resizable()
                .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text("Kronor Test App")
                    .font(.title2.bold())
                Text("iOS SDK payment playground")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("STAGING")
                .font(.caption2.weight(.bold))
                .tracking(0.5)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .foregroundStyle(Color.kronorGreen)
                .background(Color.kronorGreen.opacity(0.12), in: Capsule())
        }
    }
}
