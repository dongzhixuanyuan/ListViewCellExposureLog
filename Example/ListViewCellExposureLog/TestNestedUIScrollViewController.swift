//
//  TestNestedUIScrollViewController.swift
//  ListViewCellExposureLog_Example
//
//  Created by liudong on 2021/11/5.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import ListViewCellExposureLog
import MJRefresh
import RxSwift
import SnapKit
import UIKit

/// 嵌套滑动，当外层ScrollView滑动时，需要手动触发内层ScrollView的曝光计算。
class TestNestedUIScrollViewController: BaseNestedScrollViewViewController, ExposureCellOutputer,KeyIndexMapper {
    typealias KeyType = Int
    typealias IndexType = Int
    private let TAG = "TestNestedUIScrollViewController"
    
    func indexMapToKey(index: Int) -> Int? {
        return index
    }
    
    var customExposureRatio: Double?
    
    func outputCompleteVisibleItems(items: Set<KeyIndexCompose<Int, Int>>) {
        debugPrint("\(TAG)::outputCompleteVisibleItems:\(items)")
    }
    
    func outputPartVisibleItems(items: Set<KeyIndexCompose<Int, Int>>) {
        debugPrint("\(TAG)::outputPartVisibleItems:\(items)")
    }
    
    func outputCustomExposureRatioItems(items: Set<KeyIndexCompose<Int, Int>>) {
        debugPrint("\(TAG)::outputCustomExposureRatioItems:\(items)")
    }
    
    let disposeBag = DisposeBag()
    private var scrollViewType: UIScrollViewSubType = .UITableView
    
    init(_ scrollViewTypeParam: UIScrollViewSubType) {
        scrollViewType = scrollViewTypeParam
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var hasFixedMaxOffsetY: Bool {
        get {
            return true
        }
        set {
            self.hasFixedMaxOffsetY = newValue
        }
    }
    
    override var maxOffsetY: CGFloat {
        get {
            return 300
        }
        set {
            self.maxOffsetY = newValue
        }
    }
    
    override var mainScrollView: UIScrollView? {
        get {
            return parentScrollView
        }
        set {
            self.mainScrollView = newValue
        }
    }
    
    override var childScrollView: UIScrollView? {
        get {
            return customUIScrollView
        }
        set {
            self.childScrollView = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        backIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(44)
        }
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backIcon)
            make.centerX.equalToSuperview()
        }
        backIcon.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }
            self.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
        parentScrollView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        parentScrollView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.width.equalTo(self.view.bounds.width)
            make.height.equalTo(self.maxOffsetY + self.view.bounds.height)
        }
        topView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(self.maxOffsetY)
        }
        customUIScrollView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(self.view.bounds.height) // 子的UIScrollView高度定位屏幕高度
        }
        parentScrollView.contentSize = CGSize(width: self.view.bounds.width, height: self.maxOffsetY + self.view.bounds.height)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
//        if scrollView == mainScrollView {
//            customUIScrollView.calculateSignal(forceCalculate: false, delaySeconds: DELAYTIME_FOR_UI_FRAME_CHANGE)
//        }
    }
    
    lazy var backIcon: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "ic_nav_back"), for: .normal)
        self.view.addSubview(btn)
        return btn
    }()
    
    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.text = self.scrollViewType.displayTitle()
        view.textAlignment = .center
        view.textColor = UIColor.black
        self.view.addSubview(view)
        return view
    }()
    
    lazy var topView: UIView = {
        let view = UILabel()
        view.text = "顶部固定View"
        view.backgroundColor = UIColor.gray
        self.containerView.addSubview(view)
        return view
    }()
    
    lazy var parentScrollView: UIScrollView = {
        let view = UIScrollView()
        self.view.addSubview(view)
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var customUIScrollView: TestUIScrollView = {
        let view = TestUIScrollView()
        view.exposureOutputerDelegate = ExposureCellOutputerTemplate.make(self)
        containerView.addSubview(view)
        return view
    }()
}
