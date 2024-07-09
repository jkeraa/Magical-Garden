//
//  SoundManager.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 08/07/24.
//

import AVFoundation

class SoundManager: NSObject {
    
    // MARK: - Properties
    
    static let shared = SoundManager()
    private var backgroundPlayer: AVAudioPlayer?
    private var effectPlayers: [AVAudioPlayer] = []

    // MARK: - Initialization
    
    private override init() {
        super.init()
    }

    // MARK: - Background Music
    
    /// Plays background music with the specified file name and type.
    func playBackgroundMusic(fileName: String, fileType: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
            print("Background music file not found.")
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)

            backgroundPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundPlayer?.numberOfLoops = -1
            backgroundPlayer?.play()
        } catch {
            print("Failed to initialize background music player: \(error)")
        }
    }

    // MARK: - Sound Effects
    
    /// Plays a sound effect with the specified file name and type.
    func playSoundEffect(fileName: String, fileType: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
            print("Sound effect file not found.")
            return
        }

        do {
            let effectPlayer = try AVAudioPlayer(contentsOf: url)
            effectPlayers.append(effectPlayer)
            effectPlayer.delegate = self
            effectPlayer.play()
        } catch {
            print("Failed to initialize sound effect player: \(error)")
        }
    }
}

extension SoundManager: AVAudioPlayerDelegate {
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let index = effectPlayers.firstIndex(of: player) {
            effectPlayers.remove(at: index)
        }
    }
}
