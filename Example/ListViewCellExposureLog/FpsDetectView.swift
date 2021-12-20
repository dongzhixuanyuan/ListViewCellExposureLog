//
//  FpsDetectView.swift
//  ListViewCellExposureLog_Example
//
//  Created by liudong on 2021/11/6.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

import UIKit

class FPSLabel: UILabel {

    private var link:CADisplayLink?
    
    private var lastTime:TimeInterval = 0.0;
    
    private var count:Int = 0;

    override init(frame: CGRect) {
        super.init(frame: frame)
        
    
        link = CADisplayLink.init(target: self, selector: #selector(didTick(link: )))
        link?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        link?.invalidate()
    }
    
    @objc func didTick(link:CADisplayLink){
    
        if lastTime == 0 {
            lastTime = link.timestamp
            return
        }
        count += 1
        
        let delta = link.timestamp - lastTime
        
        if delta < 1 {
            return
        }
        
        lastTime = link.timestamp
        
        // 帧数========>可以自己定义作为label显示
        let fps = Double(count) / delta
        
        
        count = 0
        
        text = String(format: "%02.0f帧",round(fps))
        
        // 打印帧数
//        print(text ?? "0")
        
    }
}
