//
//  TestUIScrollView.swift
//  ListViewCellExposureLog_Example
//
//  Created by liudong on 2021/10/31.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import ListViewCellExposureLog
import SnapKit
import UIKit
class TestUIScrollView: CellExposureLogUIScrollView<Int> {
    private let TAG = "TestUIScrollView"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        makeContainerViewContraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeContainerViewContraints() {
        var sum = subviewHeight.reduce(0) { x, y in
            x+y+50
        }
        sum += 40
        contentSize = CGSize(width: 375, height: sum)
        containerView.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.width.equalTo(375)
            make.height.equalTo(sum)
        }
    }
    
     override var extraEdgeInset: UIEdgeInsets? {
        get {
            if TestExposureViewController.addFloatView {
                return UIEdgeInsets(top: 0, left: 0, bottom: 200, right: 0)
            }
            return nil
        }
        set {
            self.extraEdgeInset = newValue
        }
    }
    
    override var exposureCalculateViews: [UIView]? {
        get {
            return [firstView, secondView, thirdView, fourthView, fiveView]
        }
        set {
            self.exposureCalculateViews = newValue
        }
    }
    
    override var customExposureRatio: Double? {
        get {
            return 0.5
        }
        set {
            self.customExposureRatio = newValue
        }
    }
    
    private let subviewHeight = [200, 250, 300, 350, 400]
    func setupUI() {
        firstView.snp.makeConstraints { make in
            make.top.right.left.equalToSuperview()
            make.height.equalTo(subviewHeight[0])
        }
        secondView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(firstView.snp.bottom).offset(50)
            make.height.equalTo(subviewHeight[1])
        }
        thirdView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(secondView.snp.bottom).offset(50)
            make.height.equalTo(subviewHeight[2])
        }
        fourthView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(thirdView.snp.bottom).offset(50)
            make.height.equalTo(subviewHeight[3])
        }
        fiveView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(fourthView.snp.bottom).offset(50)
            make.height.equalTo(subviewHeight[4])
        }
        self.calculateSignal(forceCalculate: false, delaySeconds: DELAYTIME_FOR_DATA_CHANGE_CALCULATE)
    }
    
    override func indexMapToKey(index: CellExposureLogUIScrollView<Int>.IndexType) -> Int {
        return index
    }

    override func outputCompleteVisibleItems(items: Set<KeyIndexCompose<Int, CellExposureLogUIScrollView<Int>.IndexType>>) {
        super.outputCompleteVisibleItems(items: items)
        var result = ""
        items.forEach { item in
            result += item.toString()
        }
        debugPrint("\(TAG)::outputCompleteVisibleItems:\(result)")
    }

    override func outputPartVisibleItems(items: Set<KeyIndexCompose<Int, CellExposureLogUIScrollView<Int>.IndexType>>) {
        super.outputPartVisibleItems(items: items)
        var result = ""
        items.forEach { item in
            result += item.toString()
        }
        debugPrint("\(TAG)::outputPartVisibleItems:\(result)")
    }
    
    override func outputCustomExposureRatioItems(items: Set<KeyIndexCompose<Int, CellExposureLogUIScrollView<Int>.IndexType>>) {
        super.outputCustomExposureRatioItems(items: items)
        var result = ""
        items.forEach { item in
            result += item.toString()
        }
        debugPrint("\(TAG)::outputCustomExposureRatioItems:\(result)")
    }
    
    lazy var firstView: UIView = {
        let view = UILabel()
        view.text = "0"
        view.textColor = UIColor.black
        view.backgroundColor = UIColor.blue
        containerView.addSubview(view)
        return view
    }()
    
    lazy var secondView: UIView = {
        let view = UILabel()
        view.text = "1"
        view.textColor = UIColor.black
        view.backgroundColor = UIColor.orange
        containerView.addSubview(view)

        return view
    }()
    
    lazy var thirdView: UIView = {
        let view = UILabel()
        view.text = "2"
        view.textColor = UIColor.black
        view.backgroundColor = UIColor.red
        containerView.addSubview(view)

        return view
    }()
    
    lazy var fourthView: UIView = {
        let view = UILabel()
        view.text = "3"
        view.textColor = UIColor.black
        view.backgroundColor = UIColor.yellow
        containerView.addSubview(view)

        return view
    }()
    
    lazy var fiveView: UIView = {
        let view = UILabel()
        view.text = "4"
        view.textColor = UIColor.black
        view.backgroundColor = UIColor.green
        containerView.addSubview(view)

        return view
    }()
    
    /// 容器View，UIScrollView使用时，需要有一个ContainerView来承载所有的子View
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        self.addSubview(view)
        return view
    }()
    
    deinit {
        debugPrint("TestUIScrollView::deinit")
    }
}
