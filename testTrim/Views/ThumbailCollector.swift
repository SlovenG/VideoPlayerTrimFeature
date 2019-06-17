//
//  ThumbailCollector.swift
//  testTrim
//
//  Created by sloven graciet on 15/06/2019.
//  Copyright © 2019 Alizeum. All rights reserved.
//

import UIKit
import AVFoundation


public protocol ThumbnailCollectorDelegate: class {
    func didImagesUpdate()
}

class ThumbnailCollector {

    weak var delegate: ThumbnailCollectorDelegate?
    var duration: Float64 = 0
    var number = 0
    

    
    var url: URL! {
        didSet{
            updateDuration()
            updateThumbnails()
        }
    }
    
    var time: CMTime = CMTime(value: 0, timescale: 1) {
        didSet{
            images.removeAll()
            updateThumbnails()
        }
    }
    
    var images = [UIImage]()
    
    private func updateDuration() {
        let source = AVURLAsset(url: url)
        duration = CMTimeGetSeconds(source.duration)
    }
    
    private func updateThumbnails() {
        
        images.removeAll()
        var offset: Float64 = 0
        
        for i in 0..<number {
            getThumbnail(time: offset)
            offset = Float64(i) * (duration / Float64(number))
        }
        
        delegate?.didImagesUpdate()
    }
        
    private func getThumbnail(time: Float64) {
        
        let cmTime = CMTimeMake(value: Int64(time), timescale: Int32(NSEC_PER_SEC))
        let asset = AVAsset(url: url)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        
        do {
            let img = try imgGenerator.copyCGImage(at: cmTime, actualTime: nil)
            images.append(UIImage(cgImage: img))
        }
        catch {
            print("error cpyImge")
        }
    }
}
