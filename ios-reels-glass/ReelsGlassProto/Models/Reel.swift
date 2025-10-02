import Foundation

struct Creator: Identifiable, Hashable {
    let id: UUID = UUID()
    let handle: String
    let displayName: String
    let avatarURL: URL?
}

struct Reel: Identifiable, Hashable {
    let id: UUID = UUID()
    let videoURL: URL
    let creator: Creator
    let caption: String
    let audioTitle: String
    var likeCount: Int
    var commentCount: Int
    var isLiked: Bool = false
    var isFollowing: Bool = false
    var isMuted: Bool = false
}
