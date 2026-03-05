import AVFoundation
import UIKit

@Observable
@MainActor
class MeditationAudioService {
    var isPlaying: Bool = false
    var elapsedSeconds: Int = 0
    var totalSeconds: Int = 0

    private var engine: AVAudioEngine?
    private var sourceNode1: AVAudioSourceNode?
    private var sourceNode2: AVAudioSourceNode?
    private var timer: Timer?
    private var phase1: Double = 0
    private var phase2: Double = 0
    private var currentFreq1: Double = 136.1
    private var currentFreq2: Double = 272.2

    func startMeditation(frequency: Double, harmonicFrequency: Double, durationMinutes: Int) {
        stopMeditation()

        currentFreq1 = frequency
        currentFreq2 = harmonicFrequency
        totalSeconds = durationMinutes * 60
        elapsedSeconds = 0
        phase1 = 0
        phase2 = 0

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            return
        }

        let eng = AVAudioEngine()
        let sampleRate: Double = 44100
        let freq1 = currentFreq1
        let freq2 = currentFreq2
        var p1 = phase1
        var p2 = phase2

        let node1 = AVAudioSourceNode { _, _, frameCount, audioBufferList in
            let bufferList = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let inc = 2.0 * .pi * freq1 / sampleRate
            for frame in 0..<Int(frameCount) {
                let sample = Float(sin(p1) * 0.15)
                p1 += inc
                if p1 >= 2.0 * .pi { p1 -= 2.0 * .pi }
                for buffer in bufferList {
                    let buf = UnsafeMutableBufferPointer<Float>(buffer)
                    buf[frame] = sample
                }
            }
            return noErr
        }

        let node2 = AVAudioSourceNode { _, _, frameCount, audioBufferList in
            let bufferList = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let inc = 2.0 * .pi * freq2 / sampleRate
            for frame in 0..<Int(frameCount) {
                let sample = Float(sin(p2) * 0.08)
                p2 += inc
                if p2 >= 2.0 * .pi { p2 -= 2.0 * .pi }
                for buffer in bufferList {
                    let buf = UnsafeMutableBufferPointer<Float>(buffer)
                    buf[frame] = sample
                }
            }
            return noErr
        }

        let reverb = AVAudioUnitReverb()
        reverb.loadFactoryPreset(.cathedral)
        reverb.wetDryMix = 70

        let delay = AVAudioUnitDelay()
        delay.delayTime = 0.4
        delay.feedback = 40
        delay.wetDryMix = 25

        eng.attach(node1)
        eng.attach(node2)
        eng.attach(reverb)
        eng.attach(delay)

        let mixer = eng.mainMixerNode
        eng.connect(node1, to: delay, format: nil)
        eng.connect(delay, to: reverb, format: nil)
        eng.connect(reverb, to: mixer, format: nil)
        eng.connect(node2, to: mixer, format: nil)

        mixer.outputVolume = 0.6

        do {
            eng.prepare()
            try eng.start()
            isPlaying = true
            UIApplication.shared.isIdleTimerDisabled = true
        } catch {
            return
        }

        engine = eng
        sourceNode1 = node1
        sourceNode2 = node2

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.elapsedSeconds += 1
                if self.elapsedSeconds >= self.totalSeconds {
                    self.stopMeditation()
                }
            }
        }
    }

    func stopMeditation() {
        timer?.invalidate()
        timer = nil
        engine?.stop()
        engine = nil
        sourceNode1 = nil
        sourceNode2 = nil
        isPlaying = false
        UIApplication.shared.isIdleTimerDisabled = false
    }

    func togglePlayPause() {
        guard let eng = engine else { return }
        if isPlaying {
            eng.pause()
            timer?.invalidate()
            timer = nil
            isPlaying = false
            UIApplication.shared.isIdleTimerDisabled = false
        } else {
            do {
                try eng.start()
                isPlaying = true
                UIApplication.shared.isIdleTimerDisabled = true
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                    Task { @MainActor in
                        guard let self else { return }
                        self.elapsedSeconds += 1
                        if self.elapsedSeconds >= self.totalSeconds {
                            self.stopMeditation()
                        }
                    }
                }
            } catch {}
        }
    }

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(elapsedSeconds) / Double(totalSeconds)
    }

    var remainingTimeString: String {
        let remaining = max(0, totalSeconds - elapsedSeconds)
        let mins = remaining / 60
        let secs = remaining % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    var elapsedTimeString: String {
        let mins = elapsedSeconds / 60
        let secs = elapsedSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
