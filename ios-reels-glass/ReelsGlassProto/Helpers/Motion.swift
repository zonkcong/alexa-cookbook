import Foundation
import CoreMotion
import Combine

final class MotionManager: ObservableObject {
    private let manager = CMMotionManager()
    private let queue = OperationQueue()

    @Published var x: Double = 0 // roll
    @Published var y: Double = 0 // pitch

    init() {
        start()
    }

    func start() {
        guard manager.isDeviceMotionAvailable else { return }
        manager.deviceMotionUpdateInterval = 1.0 / 30.0
        manager.startDeviceMotionUpdates(to: queue) { [weak self] motion, _ in
            guard let self, let motion else { return }
            // Normalize small values for subtle parallax
            let roll = max(-1, min(1, motion.attitude.roll))
            let pitch = max(-1, min(1, motion.attitude.pitch))
            DispatchQueue.main.async {
                self.x = roll
                self.y = pitch
            }
        }
    }

    deinit {
        manager.stopDeviceMotionUpdates()
    }
}

import SwiftUI

struct ParallaxEffect: ViewModifier {
    @EnvironmentObject private var motion: MotionManager
    let magnitude: CGFloat

    func body(content: Content) -> some View {
        content
            .offset(x: CGFloat(motion.x) * magnitude, y: CGFloat(motion.y) * -magnitude)
    }
}

extension View {
    func parallax(_ magnitude: CGFloat) -> some View { modifier(ParallaxEffect(magnitude: magnitude)) }
}
