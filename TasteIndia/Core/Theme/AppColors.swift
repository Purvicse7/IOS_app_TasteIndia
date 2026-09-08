import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

enum AppTheme {
    static let primaryAccent = Color(red: 0.85, green: 0.35, blue: 0.15)
    static let secondaryBadge = Color(red: 0.20, green: 0.55, blue: 0.35)
    
    #if canImport(UIKit)
    static let surfaceBackground = Color(uiColor: .systemGroupedBackground)
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    static let tertiaryBackground = Color(uiColor: .tertiarySystemGroupedBackground)
    #else
    static let surfaceBackground = Color.gray.opacity(0.08)
    static let cardBackground = Color.gray.opacity(0.15)
    static let tertiaryBackground = Color.gray.opacity(0.12)
    #endif
}
