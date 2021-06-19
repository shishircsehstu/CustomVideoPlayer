//
//  VideoPlayerViewController.swift
//  TestApps
//
//  Created by Saddam on 10/6/21.
//

import UIKit
import Photos
import AVFoundation

class VideoPlayerViewController: UIViewController {

    @IBOutlet weak var forgroundWidthConstrain: NSLayoutConstraint!
    @IBOutlet weak var currentTileLbl: UILabel!
    @IBOutlet weak var playPauseIcon: UIImageView!
    @IBOutlet weak var videoPlayerView: VideoPlayer!
    @IBOutlet weak var durationsLbl: UILabel!
    @IBOutlet weak var backgroundProgressView: UIView!
    @IBOutlet weak var forgroundProgressView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoPlayerView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadVideoURL()
    }
    func loadVideoURL(){
        
        guard let path = Bundle.main.path(forResource: "clip", ofType: "mp4") else {
            print("Failed to get clip from main bundle!"); return
        }
        
        let videoURL = URL(fileURLWithPath: path)
        let avAsset = AVAsset(url: videoURL)
        videoPlayerView.videoAvAeet = avAsset
    }

}
extension VideoPlayerViewController: VideoPlayerDelegate{
    func getCurrentTimeAndDuration(currentTime: String, duration: String, progress: Double) {
        currentTileLbl.text = currentTime
        durationsLbl.text = duration
        
        let progressWidth = self.backgroundProgressView.frame.width * CGFloat(progress)
        forgroundWidthConstrain.constant = progressWidth
    }
    
    func playerViewPlayReachedEnd() {
        playPauseIcon.isHidden = false
    }
    
    func playAndPause(playState: Bool) {
        playPauseIcon.isHidden = !playState
    }
    
    func getPlayerCurrentTime(currentTime: Double) {
        
        print(currentTime)
    }
}
