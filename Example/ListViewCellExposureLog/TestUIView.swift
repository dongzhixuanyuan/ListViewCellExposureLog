//
//  TestUIView.swift
//  ListViewCellExposureLog_Example
//
//  Created by liudong on 2021/11/25.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import ListViewCellExposureLog
class TestUIView: UIView {

    init() {
        super.init(frame: .zero)
        setupUI()
        makeContainerViewContraints()
    }
    private let subviewHeight = [200, 250, 300, 350, 400]

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override var exposureCalculateViews: [UIView]? {
//        return [firstView, secondView, thirdView, fourthView, fiveView]
//    }
    
    func setupUI() {
        parentScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    lazy var parentScrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = UIColor.gray
        view.isPagingEnabled = true
        self.addSubview(view)
        return view
    }()
    
    /// 容器View，UIScrollView使用时，需要有一个ContainerView来承载所有的子View
    lazy var containerView: TestExposureUIView = {
        let view = TestExposureUIView.init()
        view.backgroundColor = UIColor.clear
        parentScrollView.addSubview(view)
        return view
    }()
    
    func makeContainerViewContraints() {
        var sum = subviewHeight.reduce(0) { x, y in
            x+y+50
        }
        sum += 40
        parentScrollView.contentSize = CGSize(width: 375, height: sum)
        containerView.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.width.equalTo(375)
            make.height.equalTo(sum)
        }
    }
}

class TestExposureUIView: CellExposureLogUIView<Int> {
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    private let subviewHeight = [200, 250, 300, 350, 400]
    
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
        return [firstView, secondView, thirdView, fourthView, fiveView]
    }
    
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
    
    lazy var firstView: UIView = {
        let view = UILabel()
        view.text = "0"
        view.textColor = UIColor.black
        view.backgroundColor = UIColor.blue
        addSubview(view)
        return view
    }()
    
    lazy var secondView: UIView = {
        let view = UILabel()
        view.text = "1"
        view.textColor = UIColor.black
        view.backgroundColor = UIColor.orange
        addSubview(view)

        return view
    }()
    
    lazy var thirdView: UIView = {
        let view = UILabel()
        view.text = "2"
        view.textColor = UIColor.black
        view.backgroundColor = UIColor.red
       addSubview(view)

        return view
    }()
    
    lazy var fourthView: UIView = {
        let view = UILabel()
        view.text = "3"
        view.textColor = UIColor.black
        view.backgroundColor = UIColor.yellow
        addSubview(view)

        return view
    }()
    
    lazy var fiveView: UIView = {
        let view = UILabel()
        view.text = "4"
        view.textColor = UIColor.black
        view.backgroundColor = UIColor.green
      addSubview(view)

        return view
    }()
    
    override func outputCompleteVisibleItems(items: Set<KeyIndexCompose<Int, CellExposureLogUIView<Int>.IndexType>>) {
        items.forEach { item in
            debugPrint("outputCompleteVisibleItems:\(item.identifier)")
        }
    }
}
