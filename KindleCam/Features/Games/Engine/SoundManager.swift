import Foundation
import Combine
import AVFoundation
import AudioToolbox

class SoundManager: ObservableObject {
    static let shared = SoundManager()

    private let synthesizer = AVSpeechSynthesizer()
    private let audioQueue = DispatchQueue(label: "com.gameforkids.audio", qos: .userInitiated)
    @Published var isMuted: Bool = false

    private init() {
        audioQueue.async {
            self.configureAudioSession()
        }
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session configuration error: \(error)")
        }
    }

    /// Immediately stops any ongoing speech synthesis and audio queues
    func stopAllAudio() {
        audioQueue.async { [weak self] in
            guard let self = self else { return }
            if self.synthesizer.isSpeaking {
                self.synthesizer.stopSpeaking(at: .immediate)
            }
        }
    }

    /// Speaks prompt text out loud in friendly voice asynchronously without blocking UI main thread
    func speak(_ text: String) {
        guard !isMuted else { return }
        audioQueue.async { [weak self] in
            guard let self = self else { return }
            if self.synthesizer.isSpeaking {
                self.synthesizer.stopSpeaking(at: .immediate)
            }

            let utterance = AVSpeechUtterance(string: text)
            // Prefer an installed Premium or Enhanced English voice. These voices
            // are downloaded in iOS Settings, so a standard English voice remains
            // a reliable fallback on every device.
            utterance.voice = self.preferredEnglishVoice()
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.96
            utterance.pitchMultiplier = 1.04
            utterance.preUtteranceDelay = 0.08
            utterance.postUtteranceDelay = 0.12

            self.synthesizer.speak(utterance)
        }
    }

    private func preferredEnglishVoice() -> AVSpeechSynthesisVoice? {
        let englishVoices = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.lowercased().hasPrefix("en") }

        return englishVoices.max { lhs, rhs in
            lhs.quality.rawValue < rhs.quality.rawValue
        } ?? AVSpeechSynthesisVoice(language: "en-US")
    }

    /// Plays cheerful sound for correct answer asynchronously
    func playCorrectFeedback() {
        guard !isMuted else { return }
        audioQueue.async { [weak self] in
            AudioServicesPlaySystemSound(1025)
            let praisePhrases = ["Great job!", "Super!", "Yay!", "Awesome!", "Correct!", "Spot on!"]
            let phrase = praisePhrases.randomElement() ?? "Good job!"
            self?.speak(phrase)
        }
    }

    /// Plays gentle negative feedback sound & prompt asynchronously
    func playWrongFeedback() {
        guard !isMuted else { return }
        audioQueue.async { [weak self] in
            AudioServicesPlaySystemSound(1053)
            let tryAgainPhrases = ["Oops! Try again!", "Not quite, keep looking!", "Give it another try!"]
            let phrase = tryAgainPhrases.randomElement() ?? "Try again!"
            self?.speak(phrase)
        }
    }

    /// Plays grand celebration cheer for finishing category asynchronously
    func playCategoryCompletedCheer() {
        guard !isMuted else { return }
        audioQueue.async { [weak self] in
            AudioServicesPlaySystemSound(1026)
            self?.speak("Hooray! You completed all questions! Amazing job!")
        }
    }
}
