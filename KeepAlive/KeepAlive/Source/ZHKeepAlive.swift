//
//  ZHKeepAlive.swift
//  KeepAlive
//
//  Created by Ryan on 2024/1/10.
//

import UIKit
import Foundation
import AVFoundation

public final class ZHKeepAlive {
    private static let shared = ZHKeepAlive()
    
    private let isLogEnabled = true
    
    private var audioPlayer: AVAudioPlayer?
    private var bgTaskIdentifier: UIBackgroundTaskIdentifier?
    
    private init() {
        setupAudioSession()
        setupAudioPlayer()
    }
    
    class func start() {
        ZHKeepAlive.shared.start()
    }
    
    class func stop() {
        ZHKeepAlive.shared.stop()
    }
}

private extension ZHKeepAlive {
    func start() {
        audioPlayer?.play()
        applyforBackgroundTask()
    }
    
    func stop() {
        audioPlayer?.stop()
        ka_debugPrint("后台保活关闭")
    }
    
    func applyforBackgroundTask() {
        endTask()
        
        bgTaskIdentifier = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endTask()
            self?.start()
        }
        ka_debugPrint("后台保活开启,申请后台任务: \(String(describing: bgTaskIdentifier))")
    }
    
    func endTask() {
        if bgTaskIdentifier != nil, bgTaskIdentifier != .invalid {
            ka_debugPrint("后台任务结束: \(String(describing: bgTaskIdentifier))")
            if bgTaskIdentifier != nil {
                UIApplication.shared.endBackgroundTask(bgTaskIdentifier!)
            }
            bgTaskIdentifier = .invalid
        }
    }
}

private extension ZHKeepAlive {
    func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playback, options: .mixWithOthers)
            try audioSession.setActive(true)
        } catch {
            debugPrint(error)
        }
    }
    
    func setupAudioPlayer() {
        guard let audioPath = Bundle.main.path(forResource: "blank", ofType: "wav") else {
            debugPrint("缺少音频文件")
            return
        }
        let fileURL = URL(fileURLWithPath: audioPath)
        do {
            let player = try AVAudioPlayer(contentsOf: fileURL)
            player.volume = 0
            player.numberOfLoops = 1
            player.prepareToPlay()
            audioPlayer = player
        } catch {
            debugPrint(error)
        }
    }
    
    func ka_debugPrint(_ message: Any) {
        if isLogEnabled {
            debugPrint(message)
        }
    }
}
