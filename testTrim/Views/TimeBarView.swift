//
//  TimeBarView.swift
//  testTrim
//
//  Created by sloven graciet on 16/06/2019.
//  Copyright © 2019 Alizeum. All rights reserved.
//

import UIKit

class TimeBarView: UIView {
    

    lazy var hStack : UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = #colorLiteral(red: 0.1921568627, green: 0.1921568627, blue: 0.1921568627, alpha: 1)
        
        addSubview(hStack)
        
        let v = UIView()
        hStack.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
        hStack.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        hStack.addArrangedSubview(v)
        
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
