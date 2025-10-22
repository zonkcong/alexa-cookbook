import Foundation
import SwiftUI

enum ReelItem: Identifiable, Hashable {
    case organic(Reel)
    case ad(AdReel)

    var id: String {
        switch self {
        case .organic(let reel): return "org_\(reel.id.uuidString)"
        case .ad(let ad): return "ad_\(ad.id.uuidString)"
        }
    }
}

struct Reel: Identifiable, Hashable {
    let id = UUID()
    let userName: String
    let caption: String
    let color: Color
}

struct AdReel: Identifiable, Hashable {
    let id = UUID()
    let advertiser: String
    let callToAction: String
    let color: Color
}
