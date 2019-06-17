//
//  TrimSliderView.swift
//  testTrim
//
//  Created by sloven graciet on 15/06/2019.
//  Copyright © 2019 Alizeum. All rights reserved.
//

import UIKit
import AVKit



public protocol TrimSliderViewDelegate: class {
    func didStartTrimValueUpdate(value: Float, position: CGPoint)
    func didEndTrimValueUpdate(value: Float, position: CGPoint)
}

class TrimSliderView: UIView{
    
    enum Constant {
        static let heightBorder : CGFloat = 5
        static let widthBorder : CGFloat = 20
        static let minimumTrim : CGFloat = 20
    }
    
    
    weak var delegate: TrimSliderViewDelegate?

    var url: URL! {
        didSet{
            updateDuration()
        }
    }
    var duration: Float64 = 0

    
    lazy var leftIndicator : UIImageView = {
        let indicator = UIImageView(image: #imageLiteral(resourceName: "startIndicator"))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggingView(_:)))
        
        indicator.addGestureRecognizer(panGesture)
        indicator.isUserInteractionEnabled = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    lazy var rightIndicator : UIImageView = {
        let indicator = UIImageView(image: #imageLiteral(resourceName: "endIndicator"))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggingView(_:)))
        
        indicator.addGestureRecognizer(panGesture)

        indicator.isUserInteractionEnabled = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    lazy var topIndicator : UIImageView = {
        let indicator = UIImageView(image: #imageLiteral(resourceName: "TopBorder"))
        
        indicator.isUserInteractionEnabled = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    lazy var bottomIndicator : UIImageView = {
        let indicator = UIImageView(image: #imageLiteral(resourceName: "BottomBorder"))
        
        indicator.isUserInteractionEnabled = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    
   
    
    var leftTopBorderConstraint : NSLayoutConstraint!
    var rightTopBorderConstraint : NSLayoutConstraint!
    var leftBottomBorderConstraint : NSLayoutConstraint!
    var rightBottomBorderConstraint : NSLayoutConstraint!
    
    var startPercentage: CGFloat = 0.0 {
        didSet{
            startInSecond = duration * Float64(startPercentage / 100)
            delegate?.didStartTrimValueUpdate(value: Float(startInSecond), position: leftIndicator.center)
        }
    }
    var endPercentage: CGFloat = 100.0 {
        didSet{
            endInSecond = duration * Float64(endPercentage / 100)
            delegate?.didEndTrimValueUpdate(value: Float(endInSecond), position: rightIndicator.center)

        }
    }
    
    var startInSecond : Float64 = 0
    var endInSecond: Float64 = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(leftIndicator)
        addSubview(rightIndicator)
        addSubview(topIndicator)
        addSubview(bottomIndicator)
        
        setupView()
    }
    
    private func setupView(){
        
       
        leftIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        leftIndicator.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        leftIndicator.widthAnchor.constraint(equalToConstant: Constant.widthBorder).isActive = true
        leftIndicator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        rightIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        rightIndicator.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        rightIndicator.widthAnchor.constraint(equalToConstant: Constant.widthBorder).isActive = true
        rightIndicator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        topIndicator.heightAnchor.constraint(equalToConstant: Constant.heightBorder).isActive = true
        topIndicator.topAnchor.constraint(equalTo: topAnchor).isActive = true
        leftTopBorderConstraint = topIndicator.leftAnchor.constraint(equalTo: leftIndicator.rightAnchor)
        leftTopBorderConstraint.isActive = true
        rightTopBorderConstraint = topIndicator.rightAnchor.constraint(equalTo: rightIndicator.leftAnchor)
        rightTopBorderConstraint.isActive = true
        
        bottomIndicator.heightAnchor.constraint(equalToConstant: Constant.heightBorder).isActive = true
        bottomIndicator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        leftBottomBorderConstraint = bottomIndicator.leftAnchor.constraint(equalTo: leftIndicator.rightAnchor)
        leftBottomBorderConstraint.isActive = true
        rightBottomBorderConstraint = bottomIndicator.rightAnchor.constraint(equalTo: rightIndicator.leftAnchor)
        rightBottomBorderConstraint .isActive = true
        
  }
    
    private func updateBorder(){
        topIndicator.frame = CGRect(x: leftIndicator.frame.origin.x + leftIndicator.frame.width,
                                    y: 0,
                                    width: rightIndicator.frame.origin.x - leftIndicator.frame.origin.x - rightIndicator.frame.size.width,
                                    height: Constant.heightBorder)
        
        bottomIndicator.frame = CGRect(x: leftIndicator.frame.origin.x + leftIndicator.frame.width,
                                    y: self.frame.size.height - Constant.heightBorder,
                                    width: rightIndicator.frame.origin.x - leftIndicator.frame.origin.x - rightIndicator.frame.size.width,
                                    height: Constant.heightBorder)
    }
    
    
    private func updatePercentagePosition(view: UIView){
        
        switch view {
        case leftIndicator:
            startPercentage = (leftIndicator.center.x - Constant.widthBorder / 2) * 100 / self.frame.width
        case rightIndicator:
            endPercentage = (rightIndicator.center.x + Constant.widthBorder / 2) * 100 / self.frame.width
        default:
            return
        }
    }
    
    private func updateDuration() {
        let source = AVURLAsset(url: url)
        duration = CMTimeGetSeconds(source.duration)
    }
  
    @objc func draggingView(_ sender:UIPanGestureRecognizer) {
        
        guard let currentView = sender.view else { return }
        
        let point = sender.location(in: self)
        var newCenter = CGPoint(x: point.x, y:currentView.center.y)
        let offsetWidthBorder =  Constant.widthBorder / 2

        switch currentView {
        case leftIndicator:
            if newCenter.x < offsetWidthBorder {
                newCenter.x = offsetWidthBorder
            }
            else if newCenter.x + offsetWidthBorder >= rightIndicator.center.x - offsetWidthBorder - Constant.minimumTrim {
                newCenter.x =  rightIndicator.center.x - offsetWidthBorder - Constant.minimumTrim
            }
        case rightIndicator:
            if newCenter.x + offsetWidthBorder > self.frame.width {
                newCenter.x = self.frame.width - offsetWidthBorder
            }
            else if newCenter.x - offsetWidthBorder <= leftIndicator.center.x + offsetWidthBorder + Constant.minimumTrim {
                newCenter.x =  leftIndicator.center.x + offsetWidthBorder + Constant.minimumTrim
            }
        default:
            return
        }
        currentView.center = newCenter
        updatePercentagePosition(view: currentView)
        updateBorder()
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TimeInterval{
    
    func stringFromTimeInterval() -> String {
        
        let time = NSInteger(self)
        
        let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
//        return String(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)
        return String(format: "%0.2d:%0.2d.%0.3d",minutes,seconds,ms)

    }
}
