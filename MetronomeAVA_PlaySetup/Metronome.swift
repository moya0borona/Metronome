//
//  Metronome.swift
//  MetronomeAVA_PlaySetup
//
//  Created by Андрей Андриянов on 03.11.2024.
//

import Foundation

class Metronome {
    
    let player = Player()
    var click: DispatchTime = DispatchTime.distantFuture
    var saveTapTime: [TimeInterval] = []
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
    var isRunning: Bool = false {
        didSet {
            isRunning ? start() : stop()
        }
    }
    var dataForAnimate: ((_ interval: DispatchTime) -> Void)?
        
    func start() {
        click = DispatchTime.now()
        playClick()
    }
    
    func stop() {
        player.stop()
        Metronome.totalBeat = 0
    }
    
    func calculateTap() {
        guard saveTapTime.count > 1 else { return }
        let intervals = zip(saveTapTime.dropLast(), saveTapTime.dropFirst()).map { $1 - $0 }
        let averageInterval = intervals.reduce(0, +) / Double(intervals.count)
        bpm = Float((60.0 / averageInterval).rounded())
        if saveTapTime.count > 5 {
            saveTapTime.removeFirst(saveTapTime.count - 5)
        }
    }

    func playClick() {
        guard isRunning,
              click <= DispatchTime.now()
        else { return }
        let interval: TimeInterval = 60.0 / Double(bpm)
        click = click + interval
        print(click)
        
        DispatchQueue.main.asyncAfter(deadline: click) { [weak self] in
            self?.playClick()
        }
        player.play()
        dataForAnimate?(click)
    }
}

