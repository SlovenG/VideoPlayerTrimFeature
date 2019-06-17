//
//  PlayerZoneView.swift
//  testTrim
//
//  Created by sloven graciet on 14/06/2019.
//  Copyright © 2019 Alizeum. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices



class PlayerZoneView: UIView {
    
    private let player = AVPlayer()
    
    
    var seekTime: CMTime?{
        didSet{
            player.seek(to: seekTime!)
        }
    }
    
    var endTime: CMTime?
    var startTime: CMTime?
    
    lazy var selectButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "AddButton"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    lazy var trimButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "trimButton"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.isEnabled = false
        return button
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "playButton"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(handlePlay(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.text = "00:00"
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 12)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    lazy var playerVideoView : VideoPlayerView = {
        let playerView = VideoPlayerView()
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.backgroundColor = .black
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePause(_:)))
        
        playerView.addGestureRecognizer(tapGesture)
        playerView.player = self.player
        return playerView
    }()
    
    lazy var trackSlider: UISlider = {
        let slider = UISlider()
        
      //  slider.setThumbImage(#imageLiteral(resourceName: "ProgressStick") , for: .normal)
       // slider.maximumTrackTintColor = .clear
      //  slider.minimumTrackTintColor = .clear
        slider.addTarget(self, action: #selector(sliderValueDidChange), for: .valueChanged)
        slider.tintColor = #colorLiteral(red: 0.5880631627, green: 0, blue: 0.005505303573, alpha: 1)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.isUserInteractionEnabled = false
        return slider
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupPlayer()
    }
    
    private func setupPlayer() {
        
        //register for notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd),
                                               name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: nil)
        
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/30.0, preferredTimescale: Int32(NSEC_PER_SEC)), queue: nil) { (progressTime) in

            
            let seconds = CMTimeGetSeconds(progressTime)
            self.progressLabel.text = "\(String(format: "%02d", Int(seconds) / 60)):\(String(format: "%02d", Int(seconds) % 60)):\(String(format: "%02d", Int((seconds.truncatingRemainder(dividingBy: 1)) * 1000)))"
            
            if let duration = self.player.currentItem?.duration {
                let durationSeconds = CMTimeGetSeconds(duration)
                
                let progress = Float(seconds/durationSeconds)
                self.trackSlider.value = progress
                
                
                if let endTime = self.endTime, self.playButton.alpha == 0 {
                    let endTimeSecond = CMTimeGetSeconds(endTime)
                    if seconds >= endTimeSecond {
                        self.player.pause()
                        self.playButton.setImage(#imageLiteral(resourceName: "playButton"), for: .normal)
                        self.playButton.alpha = 1
                        self.player.seek(to: self.startTime ?? .zero)
                    }
                }
            }
        }
    }
    
    // handle notification
    @objc func playerItemDidReachEnd(notification: Notification) {
        playButton.setImage(#imageLiteral(resourceName: "playButton"), for: .normal)
        playButton.alpha = 1
        player.seek(to: startTime ?? .zero)
        
    }
    
    private func setupView() {
        
        self.backgroundColor = #colorLiteral(red: 0.1180580179, green: 0.1180580179, blue: 0.1180580179, alpha: 1)
        addSubview(playerVideoView)
        addSubview(selectButton)
        addSubview(trimButton)
        addSubview(playButton)
        addSubview(progressLabel)
        addSubview(trackSlider)
        // set constraint to get 16/9 frame
        playerVideoView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        playerVideoView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        playerVideoView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        playerVideoView.heightAnchor.constraint(equalTo: playerVideoView.widthAnchor, multiplier: 9/16).isActive = true
      
    
        selectButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        selectButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        selectButton.topAnchor.constraint(equalTo: playerVideoView.bottomAnchor, constant: 10).isActive = true
        selectButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        
        trimButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        trimButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        trimButton.topAnchor.constraint(equalTo: playerVideoView.bottomAnchor, constant: 10).isActive = true
        trimButton.rightAnchor.constraint(equalTo: selectButton.leftAnchor, constant: -10).isActive = true
        
        playButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        playButton.centerXAnchor.constraint(equalTo: playerVideoView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: playerVideoView.centerYAnchor).isActive = true
  
        progressLabel.topAnchor.constraint(equalTo: playerVideoView.bottomAnchor, constant: 10).isActive = true
        progressLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        progressLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        progressLabel.widthAnchor.constraint(equalToConstant: 70).isActive = true
        
        trackSlider.heightAnchor.constraint(equalToConstant: 15).isActive = true
        trackSlider.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        trackSlider.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        trackSlider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        
    }
    
    @objc func handlePause(_ sender: UITapGestureRecognizer) {
        if playButton.alpha == 0 {
            player.pause()
            playButton.alpha = 1
        }
    }
    
    @objc func handlePlay(_ sender: UIButton) {
        self.playButton.setImage(#imageLiteral(resourceName: "playButton"), for: .normal)
        UIView.animate(withDuration: 0.3, animations: {
            self.playButton.alpha = 0
        }) { (finished) in
            self.playButton.setImage(#imageLiteral(resourceName: "pauseButton"), for: .normal)
        }
        player.play()
    }
    
    @objc func sliderValueDidChange(){
        trackSlider.alpha = 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UIView.animate(withDuration: 0.5) {
                self.trackSlider.alpha = 0
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //remove observers
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


