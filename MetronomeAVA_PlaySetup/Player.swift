//
//  Player.swift
//  MetronomeAVA_PlaySetup
//
//  Created by Андрей Андриянов on 02.12.2024.
//

import AVFoundation

class Player {
    
    private var audioEngine: AVAudioEngine!
    private var playerNode: AVAudioPlayerNode!
    private var audioFileClickHigh: AVAudioFile!
    private var audioFileClickLow: AVAudioFile!
    init() {
        setupAudioEngine()
        prepareAudio()
    }

    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        audioEngine.attach(playerNode)

        let mixer = audioEngine.mainMixerNode
        audioEngine.connect(playerNode, to: mixer, format: nil)
        
        do {
            try audioEngine.start()
        } catch {
            print("Error AudioEngine: \(error)")
        }
    }

    private func prepareAudio() {
        guard let clickHighUrl = Bundle.main.url(forResource: "clickHigh", withExtension: "wav") else { return }
        
        guard let clickLowhUrl = Bundle.main.url(forResource: "clickLow", withExtension: "wav") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            audioFileClickHigh = try AVAudioFile(forReading: clickHighUrl)
            audioFileClickLow = try AVAudioFile(forReading: clickLowhUrl)
        } catch {
            print("Error: \(error)")
        }
    }

    func play() {
        if Metronome.totalBeat == 0 {
            playerNode.scheduleFile(audioFileClickHigh, at: nil, completionHandler: nil)
        } else {
            playerNode.scheduleFile(audioFileClickLow, at: nil, completionHandler: nil)
        }
        playerNode.play()
    }
    
    func stop() {
            playerNode.stop()
    }
}
