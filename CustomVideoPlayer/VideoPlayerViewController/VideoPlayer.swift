//
//  VideoPlayer.swift
//  TestApps
//
//  Created by Saddam on 10/6/21.
//

import Foundation
import UIKit
import Photos
import MobileCoreServices

class VideoPlayer: UIView{
    
    var playerView = UIView()
    var player: AVPlayer?
    var delegate: VideoPlayerDelegate!
    var pauseIcon: UIImage?
    var playerItem: AVPlayerItem?
    fileprivate var timeObserver: Any?
    fileprivate var playerStatusObservationContext = 1
    var videoAvAeet: AVAsset?{
        didSet{
            manageUI()
            playVideo()
        }
    }
    
    func manageUI(){
        
        playerView.frame = self.bounds
        playerView.backgroundColor = .red
        let tap = UITapGestureRecognizer(target: self, action: #selector(playPause))
        playerView.addGestureRecognizer(tap)
        addSubview(playerView)
        
    }
    
    func playVideo(){
        
        
        
        playerItem = AVPlayerItem(asset: videoAvAeet!)
        player = AVPlayer(playerItem: playerItem)
        let layer: AVPlayerLayer = AVPlayerLayer(player: player)
        layer.backgroundColor = UIColor.black.cgColor
        layer.frame = CGRect(x: 0, y: 0, width: playerView.frame.width, height: playerView.frame.height)
        
        print("baker test: layer frame: ", layer.frame)
        
        layer.videoGravity = .resizeAspect
        playerView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
        playerView.layer.addSublayer(layer)
        //  player?.play()
        addTimeObserverToPlayer()
        addPlayerItemStatusObserver()
        
        
    }
    
    @objc func playPause(gesture: UITapGestureRecognizer) -> Void {
        
        guard let player = player else { return }
        if !player.isPlaying {
            player.play()
            // startPlaybackTimeChecker()
            // playButton.isHidden = true
        } else {
            
            player.pause()
            //  stopPlaybackTimeChecker()
            // playButton.isHidden = false
        }
        let currentTime = player.currentTime().seconds
        
        delegate.getPlayerCurrentTime(currentTime: currentTime)
        delegate.playAndPause(playState: !player.isPlaying)
    }
    
    func playerItemDuration() -> CMTime {
        
        var itemDuration = CMTime.invalid
        guard let playerItem = self.player!.currentItem else { return itemDuration }
        
        if playerItem.status == .readyToPlay {
            itemDuration = playerItem.duration
        }
        
        return itemDuration
    }
    
    func addTimeObserverToPlayer() {
        
        guard let player = self.player else { return }
        
        let interval = 0.01
        let updateTime = CMTimeMakeWithSeconds(interval, preferredTimescale: Int32(NSEC_PER_SEC))
        
        timeObserver =
            player.addPeriodicTimeObserver(forInterval: updateTime, queue: DispatchQueue.main,
                                           using: { [unowned self] _ in
                                            self.updatePlayerProgress()
                                           })
        
    }
    
    func removeTimeObserverFromPlayer() {
        
        guard let timeObserver = self.timeObserver else { return }
        guard let player = self.player else {
            return
        }
        
        player.removeTimeObserver(timeObserver)
        self.timeObserver = nil
        
    }
    
    func addPlayerItemStatusObserver() {
//
//        playerItem!.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status),
//                            options: [.new],
//                            context: &playerStatusObservationContext)
//
//        //Add observer for player item reached end
//        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(_:)),
//                                               name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    func removePlayerItemStatusObserver() {
        
        //        guard let playerItem = self.playerItem else { return }
        //
        //        playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        //        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        //
        //        self.playerItem = nil
    }
    
    func updatePlayerProgress() {
        
        updatePlayerProgressUI()
    }
    
    func updatePlayerProgressUI() {
        
        guard let player = self.player else { return }
        guard let playerItem = player.currentItem else { return }
        
        let currentTime = playerItem.currentTime().seconds
        let duration = playerItem.duration.seconds
        let currentTimeStr = getFormattedTime(seconds: currentTime)
        let durationsStr = getFormattedTime(seconds: duration)
        let progress = currentTime / duration
        delegate.getCurrentTimeAndDuration(currentTime: currentTimeStr, duration: durationsStr, progress: progress)
        
        //  let progressWidth = self.progressBackground.frame.width * CGFloat(progress)
        // progressForegroundWidthConstraint.constant = progressWidth
    }
    
    func getFormattedTime(seconds: Double) -> String {
        
        var iTime = Int(seconds)
        
        let hour = iTime / 3600
        iTime = iTime % 3600
        let minute = iTime / 60
        iTime = iTime % 60
        let second = iTime
        
        var result = ""
        if hour > 0 {
            result = String(format: "%02d:%02d:%02d", hour, minute, second)
        } else {
            result = String(format: "%02d:%02d", minute, second)
        }
        
        return result
    }
    
    func getPlayerProgress() -> CGFloat {
        guard let player = self.player else { return 0 }
        guard let playerItem = player.currentItem else { return 0 }
        
        let currentTime = playerItem.currentTime().seconds
        let duration = playerItem.duration.seconds
        
        let progress = currentTime / duration
        return CGFloat(progress)
    }
    @objc func playerItemDidReachEnd(_ notification: Notification?) {
        
        // After the movie has played to its end time, seek back to time zero to play it again.
        //TODO: IMPLEMENT
        print("Player reached end!")
        guard let player = self.player else { return }
        player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero) { _ in
            self.delegate?.playerViewPlayReachedEnd()
        }
    }
    
}

extension AVPlayer {
    
    var isPlaying: Bool {
        return self.rate != 0 && self.error == nil
    }
}

protocol VideoPlayerDelegate: AnyObject {
    
    func getPlayerCurrentTime(currentTime: Double)
    func playAndPause(playState: Bool)
    func getCurrentTimeAndDuration(currentTime: String, duration: String, progress: Double)
    func playerViewPlayReachedEnd()
}
