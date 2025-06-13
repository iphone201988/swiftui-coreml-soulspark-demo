import SwiftUI

enum MoodType1: String, CaseIterable, Equatable {
    case calm
    case stressed
    case neutral

    var color: Color {
        switch self {
        case .calm: return .blue
        case .stressed: return .red
        case .neutral: return .gray
        }
    }

    var speed: Double {
        switch self {
        case .calm: return 2.0
        case .stressed: return 0.7
        case .neutral: return 1.3
        }
    }

    static func random() -> MoodType {
        MoodType.allCases.randomElement() ?? .neutral
    }
}

import SwiftUI

enum MoodType: String, CaseIterable, Equatable {
    case calm, stressed, neutral, happy, sad, anxious, excited, angry
    case tired, hopeful, lonely, content, overwhelmed, motivated, bored
    case grateful, confused, curious, relaxed, jealous

    /// Color representation for each mood (used for UI visuals)
    var color: Color {
        switch self {
        case .calm: return .blue
        case .stressed: return .red
        case .neutral: return .gray
        case .happy: return .yellow
        case .sad: return .indigo
        case .anxious: return .orange
        case .excited: return .pink
        case .angry: return .red.opacity(0.8)
        case .tired: return .brown
        case .hopeful: return .mint
        case .lonely: return .purple
        case .content: return .green.opacity(0.7)
        case .overwhelmed: return .teal
        case .motivated: return .cyan
        case .bored: return .gray.opacity(0.6)
        case .grateful: return .yellow.opacity(0.8)
        case .confused: return .orange.opacity(0.6)
        case .curious: return .blue.opacity(0.6)
        case .relaxed: return .green.opacity(0.6)
        case .jealous: return .green
        }
    }

    /// Pulse animation speed (lower = faster beat)
    var speed: Double {
        switch self {
        case .calm, .relaxed: return 2.0
        case .neutral, .curious, .content: return 1.5
        case .happy, .hopeful, .grateful, .motivated: return 1.2
        case .excited: return 0.9
        case .stressed, .anxious, .overwhelmed, .jealous: return 0.6
        case .angry: return 0.5
        case .tired, .bored, .sad, .lonely, .confused: return 1.8
        }
    }

    /// Returns a random mood
    static func random() -> MoodType {
        MoodType.allCases.randomElement() ?? .neutral
    }
}
