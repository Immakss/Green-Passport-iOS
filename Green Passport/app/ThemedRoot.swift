import SwiftUI
import UIKit

private enum AppIconName {
    static let dark = "AppIconDark"
}

struct ThemedRoot<Content: View>: View {
    @AppStorage(UserDefaultsSettingsRepository.themeKey)
    private var themeRawValue = AppTheme.system.rawValue

    @Environment(\.colorScheme) private var systemColorScheme

    @ViewBuilder let content: () -> Content

    private var theme: AppTheme {
        AppTheme(rawValue: themeRawValue) ?? .system
    }

    private var wantsDarkIcon: Bool {
        theme == .dark || (theme == .system && systemColorScheme == .dark)
    }

    var body: some View {
        content()
            .preferredColorScheme(theme.colorScheme)
            .task(id: wantsDarkIcon) {
                try? await Task.sleep(for: .milliseconds(900))
                guard !Task.isCancelled else { return }
                await applyAppIcon(dark: wantsDarkIcon)
            }
    }

    @MainActor
    private func applyAppIcon(dark: Bool) async {
        let desiredIconName: String? = dark ? AppIconName.dark : nil
        let application = UIApplication.shared

        guard application.supportsAlternateIcons,
              application.alternateIconName != desiredIconName else {
            return
        }

        do {
            try await application.setAlternateIconName(desiredIconName)
        } catch {
            print("Не удалось сменить иконку: \(error.localizedDescription)")
        }
    }
}
