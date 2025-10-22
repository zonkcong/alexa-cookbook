import Foundation
import SwiftUI

@MainActor
final class ReelsViewModel: ObservableObject {
    @Published private(set) var items: [ReelItem] = []

    init() {
        loadSample()
    }

    func loadSample() {
        let organic: [Reel] = [
            Reel(userName: "Alice", caption: "Sunny day vibes", color: .blue.opacity(0.7)),
            Reel(userName: "Bob", caption: "Street food tour", color: .green.opacity(0.7)),
            Reel(userName: "Carol", caption: "Gym routine", color: .purple.opacity(0.7)),
            Reel(userName: "Dan", caption: "City drone shots", color: .orange.opacity(0.7)),
            Reel(userName: "Eve", caption: "Travel hacks", color: .pink.opacity(0.7)),
            Reel(userName: "Frank", caption: "Cooking pasta", color: .teal.opacity(0.7))
        ]

        let adTemplates: [AdReel] = [
            AdReel(advertiser: "Acme Co.", callToAction: "Shop Now", color: .yellow.opacity(0.7)),
            AdReel(advertiser: "Globex", callToAction: "Learn More", color: .red.opacity(0.7))
        ]

        // Pattern: O, O, Ad, O repeating
        var result: [ReelItem] = []
        var organicIndex = 0
        var adIndex = 0

        while organicIndex < organic.count {
            // O
            if organicIndex < organic.count {
                result.append(.organic(organic[organicIndex]))
                organicIndex += 1
            }
            // O
            if organicIndex < organic.count {
                result.append(.organic(organic[organicIndex]))
                organicIndex += 1
            }
            // Ad
            result.append(.ad(adTemplates[adIndex % adTemplates.count]))
            adIndex += 1
            // O
            if organicIndex < organic.count {
                result.append(.organic(organic[organicIndex]))
                organicIndex += 1
            }
        }

        self.items = result
    }
}
