//
//  Metronome.swift
//  MetronomeAVA_PlaySetup
//
//  Created by Андрей Андриянов on 03.11.2024.
//

import Foundation
//import AVFoundation

class Metronome {
    
    let player = Player()
    var click: DispatchTime = DispatchTime.distantFuture
    
    var pressTimes: [TimeInterval] = []
    
    let maxBpm: Float = 200
    let minBpm: Float = 20
    var bpm: Float = 120 {
        didSet {
            if bpm < minBpm {
                bpm = minBpm
            }
            if bpm > maxBpm {
                bpm = maxBpm
            }
        }
    }
    static var totalBeat = 0
    static var topNum = 4
    var countTap = 0
    var isRunning: Bool = false {
        didSet {
            isRunning ? start() : stop()
        }
    }
    
    var clickForAnimate: ((_ interval: DispatchTime) -> Void)?
// MARK: - Tap tempo
    
    func calculateTapSum() {

        guard pressTimes.count == 4 else { return }
        
        let interval1 = pressTimes[1] - pressTimes[0]
        let interval2 = pressTimes[2] - pressTimes[1]
        let interval3 = pressTimes[3] - pressTimes[2]
        
        let totalSum = interval1 + interval2 + interval3
        let newBpm = 180 / totalSum
        
        bpm = Float(newBpm.rounded())
        
        pressTimes.removeAll()
    }

    
// MARK: - Start / Stop
    func start() {
        click = DispatchTime.now()
        startClick()
        }
    
    func stop() {
        player.stop()
        Metronome.totalBeat = 0
    }
    
    func startClick() {
        guard isRunning,
                click <= DispatchTime.now()
        else { return }
        let interval: TimeInterval = 60.0 / Double(bpm)
        click = click + interval
        print(click)
        
        DispatchQueue.main.asyncAfter(deadline: click) { [weak self] in
            self?.startClick()
        }
        player.play()
        clickForAnimate?(click)
    }
}

