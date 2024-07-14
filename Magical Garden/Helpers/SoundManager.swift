//
//  SoundManager.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 08/07/24.
//

import AVFoundation

/// Manages audio playback for the Magical Garden application.
class SoundManager: NSObject {
    
    static let shared = SoundManager()
    private var backgroundPlayer: AVAudioPlayer?
    private var effectPlayers: [AVAudioPlayer] = []
    private var cachedEffects: [String: AVAudioPlayer] = [:] // Cache for sound effects
    private var isMuted: Bool = false // Track mute state
    
    private override init() {
        super.init()
        configureAudioSession()
    }
    
    /// Configures the audio session for playback.
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.multiRoute, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    /// Preloads sound effects into cache for efficient playback.
    /// - Parameter soundNames: An array of tuples containing the file name and file type.
    func preloadSoundEffects(soundNames: [(String, String)]) {
        for (fileName, fileType) in soundNames {
            guard let url = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
                print("Sound effect file not found: \(fileName).\(fileType)")
                continue
            }
            do {
                let effectPlayer = try AVAudioPlayer(contentsOf: url)
                effectPlayer.prepareToPlay() // Prepares the player
                cachedEffects[fileName] = effectPlayer
            } catch {
                print("Failed to preload sound effect: \(error)")
            }
        }
    }
    
    /// Plays background music from a specified file.
    /// - Parameters:
    ///   - fileName: The name of the music file.
    ///   - fileType: The type of the music file.
    func playBackgroundMusic(fileName: String, fileType: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
            print("Background music file not found.")
            return
        }
        
        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundPlayer?.numberOfLoops = -1 // Loop indefinitely
            if !isMuted {
                backgroundPlayer?.play()
            }
        } catch {
            print("Failed to initialize background music player: \(error)")
        }
    }
    
    /// Plays a sound effect from a specified file.
    /// - Parameters:
    ///   - fileName: The name of the sound effect file.
    ///   - fileType: The type of the sound effect file.
    func playSoundEffect(fileName: String, fileType: String) {
        // Use cached effect if available
        if let cachedPlayer = cachedEffects[fileName] {
            let effectPlayer = cachedPlayer // Reuse cached player
            effectPlayers.append(effectPlayer)
            effectPlayer.delegate = self
            if !isMuted {
                effectPlayer.play()
            }
        } else {
            guard let url = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
                print("Sound effect file not found: \(fileName).\(fileType)")
                return
            }
            
            do {
                let effectPlayer = try AVAudioPlayer(contentsOf: url)
                effectPlayers.append(effectPlayer)
                effectPlayer.delegate = self
                if !isMuted {
                    effectPlayer.play()
                }
            } catch {
                print("Failed to initialize sound effect player: \(error)")
            }
        }
    }
    
    /// Clears the audio cache and stops all sounds.
    func clearCache() {
        effectPlayers.forEach { $0.stop() }
        effectPlayers.removeAll()
        cachedEffects.removeAll()
        backgroundPlayer?.stop()
        backgroundPlayer = nil
    }
    
    /// Mutes all sounds in the application.
    func muteAllSounds() {
        isMuted = true
        backgroundPlayer?.volume = 0
        effectPlayers.forEach { $0.volume = 0 }
    }
    
    /// Resumes all sounds in the application.
    func resumeAllSounds() {
        isMuted = false
        backgroundPlayer?.volume = 1
        effectPlayers.forEach { $0.volume = 1 }
    }
}

extension SoundManager: AVAudioPlayerDelegate {
    
    /// Called when an audio player finishes playing.
    /// - Parameters:
    ///   - player: The audio player that finished playing.
    ///   - flag: Indicates if the playback finished successfully.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let index = effectPlayers.firstIndex(of: player) {
            effectPlayers.remove(at: index)
        }
    }
}
