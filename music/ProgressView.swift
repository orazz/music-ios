//
//  ProgressView.swift
//  Ertir
//
//  Created by Atakishiyev Orazdurdy on 2/25/15.
//  Copyright (c) 2015 Atakishiyev Orazdurdy. All rights reserved.
//

import Foundation
import UIKit

public class ProgressView {
    
    var containerView = UIView()
    var progressView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    class var shared: ProgressView {
        struct Static {
            static let instance: ProgressView = ProgressView()
        }
        return Static.instance
    }
    
    func showProgressView(view: UIView) {
        //println(view.frame)
        containerView.frame = UIScreen.mainScreen().applicationFrame

        containerView.center = view.center
        
        containerView.backgroundColor = UIColor.clearColor()//UIColor.blackColor().colorWithAlphaComponent(0.3)
        
        progressView.frame = CGRectMake(0, 0, 320, 105)
        progressView.center = view.center
        progressView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        progressView.clipsToBounds = true
        progressView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRectMake(0, 0, 80, 80)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.transform = CGAffineTransformMakeScale(1.75, 1.75)
        activityIndicator.center = CGPointMake(progressView.bounds.width / 2, progressView.bounds.height / 2)
        
        progressView.addSubview(activityIndicator)
        containerView.addSubview(progressView)
        view.addSubview(containerView)
        
        activityIndicator.startAnimating()
    }
    
    func hideProgressView() {
        activityIndicator.stopAnimating()
        containerView.removeFromSuperview()
    }
}