//
//  TestHorizontalScrollViewComposeVerticalScrollView.swift
//  ListViewCellExposureLog_Example
//
//  Created by liudong on 2021/11/25.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

/// 水平方向是一个UIScrollView，竖直方向也是一个UIScrollview。
class TestHorizontalScrollViewComposeVerticalScrollView: UIView {
    
    var screenWidth: CGFloat = 375
    var screenHeight: CGFloat = 870
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(width: CGFloat, height: CGFloat) {
        super.init(frame: .zero)
        screenWidth = width
        screenHeight = height
        setupUi()
    }
    
    func setupUi() {
        parentScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        containerView.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.equalTo(screenWidth * 2)
            make.height.equalTo(screenHeight)
        }
        leftView.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.width.equalTo(screenWidth)
            make.height.equalTo(screenHeight)
        }
        rightView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(leftView.snp.right)
            make.width.equalTo(screenWidth)
            make.height.equalTo(screenHeight)
        }
        
        parentScrollView.contentSize = CGSize(width: screenWidth * 2, height: screenHeight)
    }
    
    lazy var parentScrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = UIColor.gray
        view.isPagingEnabled = true
        self.addSubview(view)
        return view
    }()
    
    /// 容器View，UIScrollView使用时，需要有一个ContainerView来承载所有的子View
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        parentScrollView.addSubview(view)
        return view
    }()
    
    lazy var leftView: TestUIScrollView = {
        let view = TestUIScrollView()
        view.backgroundColor = UIColor.red
        containerView.addSubview(view)
        return view
    }()
    
    lazy var rightView: TestUIScrollView = {
        let view = TestUIScrollView()
        view.backgroundColor = UIColor.blue
        containerView.addSubview(view)
        return view
    }()
}
