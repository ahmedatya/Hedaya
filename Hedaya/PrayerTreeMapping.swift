// MARK: - Prayer Tree — Design-first workflow (Figma → SVG → SwiftUI)
// See docs/PrayerTree-Design-Workflow.md for Step 1 (design) and Step 2 (render).
// This file defines Step 3: map tree element IDs to actions.

import Foundation

/// Stable IDs for the tree graphic. Use these exact strings in Figma/Illustrator
/// layer names and in the exported SVG so taps can be mapped to actions.
enum PrayerTreeElementID {
    static let trunk = "trunk"

    static let rootIDs: [String] = [
        "root-fajr",
        "root-dhuhr",
        "root-asr",
        "root-maghrib",
        "root-isha",
    ]

    static let branchIDs: [String] = [
        "branch-sunnah",
        "branch-sadaqa",
        "branch-morning-zikr",
        "branch-sleeping-zikr",
        "branch-evening-zikr",
        "branch-extra-duaa",
        "branch-extra-zikr",
        "branch-extra-salah",
    ]

    /// All known interactive element IDs.
    static var allIDs: [String] {
        [trunk] + rootIDs + branchIDs
    }
}

/// Result of resolving a tap on a tree element (by ID) to an action.
enum PrayerTreeAction {
    case prayer(PrayerName)
    case quran
    case branch(BranchType)
}

/// Maps a tree element ID (from SVG or overlay) to an action.
/// Use when rendering an SVG tree and the user taps an element with a known ID.
struct PrayerTreeMapping {
    /// Returns the action for the given element ID, or nil if unknown.
    static func action(for elementID: String) -> PrayerTreeAction? {
        if elementID == PrayerTreeElementID.trunk {
            return .quran
        }
        if let index = PrayerTreeElementID.rootIDs.firstIndex(of: elementID),
           let prayer = PrayerName.allCases[safe: index] {
            return .prayer(prayer)
        }
        if let index = PrayerTreeElementID.branchIDs.firstIndex(of: elementID),
           let branch = BranchType.allCases[safe: index] {
            return .branch(branch)
        }
        return nil
    }

    /// Index of the prayer for a root ID (0–4), or nil.
    static func prayerIndex(for elementID: String) -> Int? {
        PrayerTreeElementID.rootIDs.firstIndex(of: elementID)
    }

    /// Index of the branch for a branch ID (0–7), or nil.
    static func branchIndex(for elementID: String) -> Int? {
        PrayerTreeElementID.branchIDs.firstIndex(of: elementID)
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
