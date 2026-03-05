import AVFoundation
import UIKit

@Observable
@MainActor
class HymnAudioService {
    var isPlaying: Bool = false
    var isLoading: Bool = false
    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 0

    private var player: AVPlayer?
    private var timeObserver: Any?

    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }

    var currentTimeString: String {
        formatTime(currentTime)
    }

    var durationString: String {
        formatTime(duration)
    }

    var remainingTimeString: String {
        formatTime(max(0, duration - currentTime))
    }

    func loadAndPlay(url: URL) {
        stop()
        isLoading = true

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            isLoading = false
            return
        }

        let playerItem = AVPlayerItem(url: url)
        let avPlayer = AVPlayer(playerItem: playerItem)
        player = avPlayer

        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = avPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            Task { @MainActor in
                guard let self else { return }
                self.currentTime = time.seconds
                if let item = self.player?.currentItem {
                    let dur = item.duration
                    if dur.isNumeric {
                        self.duration = dur.seconds
                    }
                }
            }
        }

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.isPlaying = false
                self?.currentTime = 0
                self?.player?.seek(to: .zero)
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }

        avPlayer.play()
        isPlaying = true
        UIApplication.shared.isIdleTimerDisabled = true
        isLoading = false
    }

    func togglePlayPause() {
        guard let player else { return }
        if isPlaying {
            player.pause()
            isPlaying = false
            UIApplication.shared.isIdleTimerDisabled = false
        } else {
            player.play()
            isPlaying = true
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }

    func seek(to fraction: Double) {
        guard let player, duration > 0 else { return }
        let target = CMTime(seconds: fraction * duration, preferredTimescale: 600)
        player.seek(to: target)
    }

    func stop() {
        if let observer = timeObserver, let player {
            player.removeTimeObserver(observer)
        }
        timeObserver = nil
        player?.pause()
        player = nil
        isPlaying = false
        UIApplication.shared.isIdleTimerDisabled = false
        currentTime = 0
        duration = 0
        isLoading = false
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
