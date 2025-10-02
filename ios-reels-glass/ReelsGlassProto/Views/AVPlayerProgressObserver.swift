import Foundation
import AVFoundation
import Combine

final class AVPlayerProgressObserver: ObservableObject {
    @Published var progress: Double = 0
    private var timeObserver: Any?

    func startObserving(player: AVPlayer) {
        stopObserving(player: player)
        let interval = CMTime(seconds: 0.05, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }
            guard let item = player.currentItem else { return }
            let dur = item.duration
            guard dur.isNumeric else { return }
            let total = CMTimeGetSeconds(dur)
            let cur = CMTimeGetSeconds(time)
            if total > 0 {
                self.progress = min(1.0, max(0.0, cur / total))
            }
        }
    }

    func stopObserving(player: AVPlayer) {
        if let token = timeObserver {
            player.removeTimeObserver(token)
            timeObserver = nil
        }
    }

    deinit {
        // cannot remove observer without player reference; leave it
    }
}
