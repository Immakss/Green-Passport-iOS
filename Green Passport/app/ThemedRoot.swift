import SwiftUI
import UIKit

struct ThemedRoot<Content: View>: View {
    private static let darkIconName = "AppIconDark"

    @AppStorage(UserDefaultsSettingsRepository.themeKey) private var themeRawValue = AppTheme.system.rawValue
    @Environment(\.colorScheme) private var systemColorScheme
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .preferredColorScheme(AppTheme(rawValue: themeRawValue)?.colorScheme)
            .onChange(of: themeRawValue, initial: true) { applyAppIcon() }
            .onChange(of: systemColorScheme) { applyAppIcon() }
    }

    private func applyAppIcon() {
        let theme = AppTheme(rawValue: themeRawValue) ?? .system
        let wantsDarkIcon = theme == .dark || (theme == .system && systemColorScheme == .dark)
        let desiredIconName = wantsDarkIcon ? Self.darkIconName : nil
        guard UIApplication.shared.supportsAlternateIcons, UIApplication.shared.alternateIconName != desiredIconName else {
            return
        }
        UIApplication.shared.setAlternateIconName(desiredIconName)
    }
}
