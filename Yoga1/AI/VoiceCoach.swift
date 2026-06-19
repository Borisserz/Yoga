import Foundation
import AVFoundation

public final class VoiceCoach: NSObject, AVSpeechSynthesizerDelegate {
    public static let shared = VoiceCoach()
    private let synthesizer = AVSpeechSynthesizer()
    private var lastSpokenPhrase: String = ""
    private var lastSpokenTime: Date = Date.distantPast
    
    private override init() {
        super.init()
        synthesizer.delegate = self
        // Request audio session to play nicely with other sounds
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers, .duckOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    public func speak(_ text: String, force: Bool = false) {
        // Prevent spamming the same phrase within 3 seconds unless forced
        if !force && text == lastSpokenPhrase && Date().timeIntervalSince(lastSpokenTime) < 3.0 {
            return
        }
        
        // Stop current speech if any
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .word)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        // Speak in the user's current language instead of a hard-coded locale.
        let preferred = Locale.preferredLanguages.first ?? "en-US"
        utterance.voice = AVSpeechSynthesisVoice(language: preferred)
            ?? AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5 // Normal speed
        utterance.pitchMultiplier = 1.1 // Slightly uplifting voice
        
        synthesizer.speak(utterance)
        
        lastSpokenPhrase = text
        lastSpokenTime = Date()
    }
}
