import Foundation
import Combine
import AVKit

final class ReelsViewModel: ObservableObject {
    @Published var reels: [Reel] = []
    @Published var currentIndex: Int = 0
    @Published var showComments: Bool = false
    @Published var showShare: Bool = false
    @Published var showAudioDetails: Bool = false
    @Published var showActions: Bool = false
    @Published var showProfile: Bool = false
    @Published var showNetworkToast: Bool = false

    // Players keyed by reel id
    @Published private(set) var players: [UUID: AVPlayer] = [:]
    @Published private(set) var observers: [UUID: AVPlayerProgressObserver] = [:]

    private var cancellables: Set<AnyCancellable> = []

    init() {
        seed()
    }

    func player(for reel: Reel) -> AVPlayer {
        if let existing = players[reel.id] { return existing }
        let player = AVPlayer(url: reel.videoURL)
        player.actionAtItemEnd = .pause
        players[reel.id] = player
        let observer = AVPlayerProgressObserver()
        observer.startObserving(player: player)
        observers[reel.id] = observer
        return player
    }

    func playCurrent() {
        guard reels.indices.contains(currentIndex) else { return }
        let reel = reels[currentIndex]
        let player = player(for: reel)
        if let item = player.currentItem { seekToStartIfAtEnd(player: player, item: item) }
        player.play()
        if reels[currentIndex].isMuted {
            player.isMuted = true
        } else {
            player.isMuted = false
        }
        // simulate probability of failure to demonstrate toast
        if Bool.random() && player.currentItem?.status == .failed {
            showNetworkToast = true
        }
    }

    func pauseCurrent() {
        guard reels.indices.contains(currentIndex) else { return }
        let reel = reels[currentIndex]
        players[reel.id]?.pause()
    }

    func togglePlayPause() {
        guard reels.indices.contains(currentIndex) else { return }
        let reel = reels[currentIndex]
        let player = player(for: reel)
        if player.timeControlStatus == .playing {
            player.pause()
        } else {
            player.play()
        }
    }

    func toggleLike(for reel: Reel) {
        guard let idx = reels.firstIndex(of: reel) else { return }
        reels[idx].isLiked.toggle()
        reels[idx].likeCount += reels[idx].isLiked ? 1 : -1
    }

    func toggleFollow(for reel: Reel) {
        guard let idx = reels.firstIndex(of: reel) else { return }
        reels[idx].isFollowing.toggle()
    }

    func toggleMute(for reel: Reel) {
        guard let idx = reels.firstIndex(of: reel) else { return }
        reels[idx].isMuted.toggle()
        players[reel.id]?.isMuted = reels[idx].isMuted
    }

    func onAppear(index: Int) {
        currentIndex = index
        pauseAllExcept(index: index)
        playCurrent()
    }

    func onDisappear(index: Int) {
        guard reels.indices.contains(index) else { return }
        let reel = reels[index]
        players[reel.id]?.pause()
    }

    func handlePagingSettled(to index: Int) {
        currentIndex = index
        pauseAllExcept(index: index)
        playCurrent()
    }

    private func pauseAllExcept(index: Int) {
        for (i, reel) in reels.enumerated() {
            if i == index { continue }
            players[reel.id]?.pause()
        }
    }

    private func seekToStartIfAtEnd(player: AVPlayer, item: AVPlayerItem) {
        let duration = item.duration
        let current = item.currentTime()
        if duration.isNumeric && current.isNumeric {
            let durSeconds = CMTimeGetSeconds(duration)
            let curSeconds = CMTimeGetSeconds(current)
            if durSeconds - curSeconds < 0.25 {
                player.seek(to: .zero)
            }
        }
    }

    private func seed() {
        // Placeholder vertical videos (public domain). Replace with bundled assets if needed.
        let urls = [
            "https://cdn.coverr.co/videos/coverr-girl-running-8283/1080p.mp4",
            "https://cdn.coverr.co/videos/coverr-waterfall-1456/1080p.mp4",
            "https://cdn.coverr.co/videos/coverr-pasta-cooking-6837/1080p.mp4"
        ]
        let videos: [URL] = urls.compactMap { URL(string: $0) }

        let creators: [Creator] = [
            Creator(handle: "@movewithmia", displayName: "Move with Mia", avatarURL: URL(string: "https://i.pravatar.cc/80?img=12")),
            Creator(handle: "@nomadnate", displayName: "Nomad Nate", avatarURL: URL(string: "https://i.pravatar.cc/80?img=5")),
            Creator(handle: "@plateandpalette", displayName: "Plate & Palette", avatarURL: URL(string: "https://i.pravatar.cc/80?img=20"))
        ]

        let captions = [
            "5 min core blast to start your day",
            "Hidden waterfall hike in Iceland",
            "Silky carbonara tip you need"
        ]

        let audioTitles = [
            "Mia's Core Flow",
            "Nordic Drip",
            "Tuscan Strings"
        ]

        let likes = [2481, 10342, 5821]
        let comments = [112, 893, 274]

        var seeded: [Reel] = []
        for i in 0..<3 {
            let reel = Reel(
                videoURL: videos[i],
                creator: creators[i],
                caption: captions[i],
                audioTitle: audioTitles[i],
                likeCount: likes[i],
                commentCount: comments[i],
                isLiked: false,
                isFollowing: i == 0,
                isMuted: false
            )
            seeded.append(reel)
        }
        self.reels = seeded
    }
}
