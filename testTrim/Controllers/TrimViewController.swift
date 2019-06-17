//
//  TrimViewController.swift
//  testTrim
//
//  Created by sloven graciet on 14/06/2019.
//  Copyright © 2019 Alizeum. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices
import Photos

class TrimViewController: UIViewController {
    
    
    var asset: AVAsset!
    var startTime: CMTime!{
        didSet{
            self.playerZoneView.startTime = startTime
        }
    }
    
    var endTime: CMTime!{
        didSet{
            self.playerZoneView.endTime = endTime
        }
    }
    
    lazy var playerZoneView: PlayerZoneView = {
        let playerZone = PlayerZoneView()
        playerZone.translatesAutoresizingMaskIntoConstraints = false
        
        return playerZone
    }()
    
    lazy var editZoneView: EditZoneView = {
        let editZone = EditZoneView()
        editZone.translatesAutoresizingMaskIntoConstraints = false
        
        return editZone
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupLayout()
        setupActions()
        initWithDemoVideo()
        // Do any additional setup after loading the view.
    }
    
    private func setupView(){
        self.view.backgroundColor = .white
        self.view.addSubview(playerZoneView)
        self.view.addSubview(editZoneView)
        
        editZoneView.delegate = self

    }
    
    private func setupLayout(){
        
        //set constraint for playerzone view
        playerZoneView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.66).isActive = true
        playerZoneView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        playerZoneView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        
        playerZoneView.clipsToBounds = false
        //set constraint for editzone view
        editZoneView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        editZoneView.topAnchor.constraint(equalTo: playerZoneView.bottomAnchor).isActive = true
        editZoneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    private func setupActions() {
        
        let selectTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectButtonDidTap(_:)))
        playerZoneView.selectButton.addGestureRecognizer(selectTapGesture)
        
        let trimTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectButtonDidTap(_:)))
        playerZoneView.trimButton.addGestureRecognizer(trimTapGesture)
    }
    
    
    private func initWithDemoVideo(){
        guard let path = Bundle.main.path(forResource: "car", ofType: "mp4") else { return }
        
        let url = URL(fileURLWithPath: path)
        self.asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: self.asset)
        
        self.playerZoneView.playerVideoView.player?.replaceCurrentItem(with: item)
        self.editZoneView.url = url
    }
    
    @objc private func selectButtonDidTap(_ sender: UIGestureRecognizer) {
        
        let view = sender.view
        switch  view {
        case playerZoneView.selectButton:
            let videoPicker = UIImagePickerController()
            videoPicker.sourceType = .savedPhotosAlbum
            videoPicker.mediaTypes = [kUTTypeMovie as String]
            videoPicker.allowsEditing = true
            videoPicker.delegate = self
            
            self.present(videoPicker, animated: true, completion: nil)
        case playerZoneView.trimButton:
            trim(startTime: startTime, endTime: endTime)
        default:
            return
        }
        
    }

    
    func trim(startTime: CMTime, endTime: CMTime) {
        
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            else {
                return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: Date())
        let url = documentDirectory.appendingPathComponent("trimVideo-\(date).mov")
        
        guard let exporter = AVAssetExportSession(asset: asset,
                                                  presetName: AVAssetExportPresetHighestQuality)
            else{
                return
        }
        
        let timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
        
        exporter.outputURL = url
        exporter.outputFileType = AVFileType.mov
        exporter.shouldOptimizeForNetworkUse = true
        exporter.timeRange = timeRange
        exporter.exportAsynchronously() {
            DispatchQueue.main.async {
                self.exportDidFinish(exporter: exporter)
            }
        }
    }
    
    func exportDidFinish(exporter: AVAssetExportSession) {
        
        guard exporter.status == AVAssetExportSession.Status.completed,
            let outputURL = exporter.outputURL
            else {
                return
        }
        
        let saveVideo = {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
            }) { saved, error in
                let success = saved && (error == nil)
                let title = success ? "Success" : "Error"
                let message = success ? "Video saved" : "Failed to save video"
                
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    saveVideo()
                }
            }
        } else {
            saveVideo()
        }
    }

}


extension TrimViewController : UIImagePickerControllerDelegate {
    
   @objc  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard
            let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
            mediaType == (kUTTypeMovie as String),
            let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL
            else {
                return
        }
        
        dismiss(animated: true) {
            self.asset = AVURLAsset(url: url)
            let item = AVPlayerItem(asset: self.asset)
        
            self.playerZoneView.playerVideoView.player?.replaceCurrentItem(with: item)
            self.editZoneView.url = url
        }
    }
}

extension TrimViewController : UINavigationControllerDelegate {
    
}


extension TrimViewController: EditZoneViewDelegate {
    func didStartTimeUpdate(startTime: CMTime) {
        self.startTime = startTime
    }
    
    func didEndTimeUpdate(endTime: CMTime) {
        self.endTime = endTime
    }
    
    func didSeekTimeUpdate(seekTime: CMTime) {
        self.playerZoneView.seekTime = seekTime
        
        if startTime != nil && endTime != nil  {
            playerZoneView.trimButton.isEnabled = true
        }
    }
}


