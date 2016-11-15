//
//  BasicPlaceholderView.swift
//  Example
//
//  Created by Alexander Schuch on 29/08/14.
//  Copyright (c) 2014 Alexander Schuch. All rights reserved.
//
import UIKit

class BasicPlaceholderView: UIView {
    
    let centerView: UIView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    func setupView() {
        backgroundColor = UIColor.white
        
        centerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(centerView)
        
        let vConstraint = NSLayoutConstraint(item: centerView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let hConstraint = NSLayoutConstraint(item: centerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        self.addConstraint(vConstraint)
        self.addConstraint(hConstraint)
    }
    
}
