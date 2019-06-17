//
//  VideoPlayerView.swift
//  testTrim
//
//  Created by sloven graciet on 15/06/2019.
//  Copyright © 2019 Alizeum. All rights reserved.
//

import AVFoundation
import UIKit

class VideoPlayerView: UIView {
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
}
