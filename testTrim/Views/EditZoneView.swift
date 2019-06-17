//
//  EditZoneView.swift
//  testTrim
//
//  Created by sloven graciet on 14/06/2019.
//  Copyright © 2019 Alizeum. All rights reserved.
//

import UIKit
import AVKit


public protocol EditZoneViewDelegate: class {
    func didSeekTimeUpdate(seekTime: CMTime)
    func didStartTimeUpdate(startTime: CMTime)
    func didEndTimeUpdate(endTime: CMTime)

}


class EditZoneView: UIView {
    
    var thumbnailCollector = ThumbnailCollector()
    
    weak var delegate : EditZoneViewDelegate?
    
    var url: URL! {
        didSet{
            thumbnailCollector.url = url
            trimSliderView.url = url
        }
    }
    
    var seekTime = CMTime(seconds: 0, preferredTimescale: 1)

    lazy var timeBarView: TimeBarView = {
        let timeBar = TimeBarView()
        
        timeBar.translatesAutoresizingMaskIntoConstraints = false
        timeBar.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return timeBar
    }()
    
    lazy var thumbnailStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = UIStackView.Distribution.fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    lazy var trimSliderView :  TrimSliderView = {
        let slider = TrimSliderView()
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    lazy var startTrimLabel: UILabel = {
        let label = UILabel()
        setupLabel(label: label)
        label.backgroundColor = .red
        
        
        return label
    }()
    
    lazy var endTrimLabel: UILabel = {
        let label = UILabel()
        setupLabel(label: label)
        label.backgroundColor = .lightGray

        return label
    }()
    
   
    
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        thumbnailCollector.delegate = self
        trimSliderView.delegate = self
        setupView()
    }
    
    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }
    
  
    private func setupView() {
        
        //set gradient background
        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.colors = [#colorLiteral(red: 0.2941176471, green: 0.2941176471, blue: 0.2941176471, alpha: 1).cgColor,#colorLiteral(red: 0.244545169, green: 0.244545169, blue: 0.244545169, alpha: 1).cgColor,#colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1).cgColor]
        gradientLayer.locations = [0.00, 0.10,1.00]
        
        addSubview(thumbnailStackView)
        setupThumbnailStackView()
        
        addSubview(trimSliderView)
        setupSliderView()
        
        addSubview(startTrimLabel)
        addSubview(endTrimLabel)
        
//        addSubview(timeBarView)
//        setupTimeBarView()
        

        startTrimLabel.bottomAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 0).isActive = true
        endTrimLabel.bottomAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 0).isActive = true
        
    }
    
    private func setupTimeBarView(){
        timeBarView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        timeBarView.leftAnchor.constraint(equalTo: thumbnailStackView.leftAnchor).isActive = true
        timeBarView.rightAnchor.constraint(equalTo: thumbnailStackView.rightAnchor).isActive = true
    }
    
  
    private func setupLabel(label: UILabel){
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 50).isActive = true
        label.heightAnchor.constraint(equalToConstant: 15).isActive = true
        label.layer.cornerRadius = 3
        label.font = label.font.withSize(8)
        label.textAlignment = .center
        label.alpha = 0
    }
    
    
    private func setupSliderView() {
        
        trimSliderView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        trimSliderView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        trimSliderView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9).isActive = true
        trimSliderView.heightAnchor.constraint(equalTo: thumbnailStackView.heightAnchor,multiplier: 1.06).isActive = true
    }
  
    private func setupThumbnailStackView() {
        
        //layout is still not set so get screen size to get the right number of thumbnails
        let width = UIScreen.main.bounds.width * 0.8
        let height = width * 75/345

        
        let n = Double(width / height)
        let thumbnailcount = Int(ceil(n))
        thumbnailCollector.number = thumbnailcount
        
        //set constraint for thumbnails and keep ratio 16/9
        thumbnailStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        thumbnailStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        thumbnailStackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.85).isActive = true
        thumbnailStackView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 75/345 ).isActive = true

    }
    
    private func addThumbnailsImage() {
        thumbnailStackView.arrangedSubviews.forEach{ $0.removeFromSuperview() }
        
        thumbnailCollector.images.forEach { (image) in
            let imageview = UIImageView(image: image)
            imageview.contentMode = .scaleAspectFill
            imageview.clipsToBounds = true
            thumbnailStackView.addArrangedSubview(imageview)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension EditZoneView : ThumbnailCollectorDelegate{
    func didImagesUpdate() {
        self.addThumbnailsImage()
        self.setupSliderView()
    }
}

extension EditZoneView: TrimSliderViewDelegate {
    
    func didEndTrimValueUpdate(value: Float, position: CGPoint) {
        endTrimLabel.alpha = 1

        let correctCenter = trimSliderView.convert(position, to: self)
        let labelPosition = CGPoint(x: correctCenter.x , y: endTrimLabel.center.y)
        
        endTrimLabel.center = labelPosition
        
        let timeInterval = TimeInterval(exactly: value)
        endTrimLabel.text = timeInterval?.stringFromTimeInterval()
        
        
        let seekTime = CMTimeMakeWithSeconds(Double(value),preferredTimescale: 60000)
        delegate?.didSeekTimeUpdate(seekTime: seekTime)
        layoutSubviews()
        
        
        let endTime = CMTime(seconds: Double(value), preferredTimescale: 1)
        delegate?.didEndTimeUpdate(endTime: endTime)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UIView.animate(withDuration: 0.5, animations: {
                self.endTrimLabel.alpha = 0
            })
        }
    }
    
    func didStartTrimValueUpdate(value: Float, position: CGPoint) {
        
        startTrimLabel.alpha = 1
        let correctCenter = trimSliderView.convert(position, to: self)
        let labelPosition = CGPoint(x: correctCenter.x , y: startTrimLabel.center.y)
        
        startTrimLabel.center = labelPosition
        
        let timeInterval = TimeInterval(exactly: value)
        startTrimLabel.text = timeInterval?.stringFromTimeInterval()
        
        
        let seekTime = CMTimeMakeWithSeconds(Double(value),preferredTimescale: 60000)
        delegate?.didSeekTimeUpdate(seekTime: seekTime)
        layoutSubviews()
        
        let startTime = CMTime(seconds: Double(value), preferredTimescale: 1)
        delegate?.didStartTimeUpdate(startTime: startTime)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UIView.animate(withDuration: 0.5, animations: {
                self.startTrimLabel.alpha = 0
            })
        }
    }
}
