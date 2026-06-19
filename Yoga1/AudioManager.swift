import Foundation
import AVFoundation

final class AudioManager {
    static let shared = AudioManager()
    private var audioPlayer: AVAudioPlayer?
    
    private init() {}
    
    func toggleAmbientSound() -> Bool {
        if let player = audioPlayer, player.isPlaying {
            player.pause()
            return false
        } else {
            // Attempt to play a sound if we have one in the bundle
            if let url = Bundle.main.url(forResource: "ambient", withExtension: "mp3") {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.numberOfLoops = -1 // Loop indefinitely
                    audioPlayer?.play()
                    return true
                } catch {
                    print("Error playing ambient sound: \(error.localizedDescription)")
                }
            } else {
                print("ambient.mp3 not found in bundle. Mocking playback.")
                // Mock playing state
                return true
            }
        }
        return false
    }
    
    func stop() {
        audioPlayer?.stop()
    }
}
