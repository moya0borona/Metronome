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
    private var bufferClickHigh: AVAudioPCMBuffer!
    private var bufferClickLow: AVAudioPCMBuffer!
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
        guard let clickHighUrl = Bundle.main.url(forResource: "clickHigh", withExtension: "wav"),
        let clickLowUrl = Bundle.main.url(forResource: "clickLow", withExtension: "wav") else {
            print("Audio files not found in bundle")
            return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            let audioFileClickHigh = try AVAudioFile(forReading: clickHighUrl)
            let audioFileClickLow = try AVAudioFile(forReading: clickLowUrl)
            
            bufferClickHigh = createPCMBuffer(from: audioFileClickHigh)
            bufferClickLow = createPCMBuffer(from: audioFileClickLow)
        } catch {
            print("Error: \(error)")
        }
    }
    private func createPCMBuffer(from file: AVAudioFile) -> AVAudioPCMBuffer? {
           guard let format = file.processingFormat as AVAudioFormat? else { return nil }
           guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(file.length)) else { return nil }

           do {
               try file.read(into: buffer)
           } catch {
               print("Error reading audio file into buffer: \(error)")
               return nil
           }

           return buffer
       }
    func play() {
        
        guard let buffer = Metronome.totalBeat == 0 ? bufferClickHigh : bufferClickLow else { return }
        playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
        playerNode.play()
    }
    
    func stop() {
            playerNode.stop()
    }
}
