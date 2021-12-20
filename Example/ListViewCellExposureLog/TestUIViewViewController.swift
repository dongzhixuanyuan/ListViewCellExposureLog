//
//  File.swift
//  ListViewCellExposureLog_Example
//
//  Created by liudong on 2021/10/28.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import ListViewCellExposureLog
import MJRefresh
import RxSwift
import SnapKit
import UIKit

enum UIScrollViewSubType {
    case UITableView
    case UICollectionView
    case UIScrollView
    case NestedUIScrollView
    case CollectionKitView
    case ComposeHorizontalAndVerticalScrollView
    case UIView
    func displayTitle() -> String {
        switch self {
        case .UITableView:
            return "TestUITableView"
        case .UICollectionView:
            return "TestUICollectionView"
        case .UIScrollView:
            return "TestUIScrollview"
        case .NestedUIScrollView:
            return "NestedUIScrollView"
        case .CollectionKitView:
            return "TestCollectionKitView"
        case .ComposeHorizontalAndVerticalScrollView:
            return "ComposeHorizontalAndVerticalScrollView"
        case .UIView:
            return "TestUIView"
        }
    }
}

class TestExposureViewController: UIViewController, ExposureCellOutputer, KeyIndexMapper {
    
    typealias KeyType = String
    typealias IndexType = IndexPath
    
    private let TAG = "TestExposureViewController"
    
    var customExposureRatio: Double?
    func indexMapToKey(index: IndexPath) -> String? {
        return "\(index.section),\(index.row)"
    }

    func outputCompleteVisibleItems(items: Set<KeyIndexCompose<String, IndexPath>>) {
        debugPrint("\(TAG)::outputCompleteVisibleItems::\(items)")
    }
    
    func outputPartVisibleItems(items: Set<KeyIndexCompose<String, IndexPath>>) {
        debugPrint("\(TAG)::outputPartVisibleItems::\(items)")
    }
    
    func outputCustomExposureRatioItems(items: Set<KeyIndexCompose<String, IndexPath>>) {
        debugPrint("\(TAG)::outputCustomExposureRatioItems::\(items)")
    }
    
    private var scrollViewType: UIScrollViewSubType = .UITableView
    
    static let addFloatView = false
    let disposeBag = DisposeBag()
    
    init(scrollViewTypePara: UIScrollViewSubType) {
        scrollViewType = scrollViewTypePara
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        backIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(44)
        }
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backIcon)
            make.centerX.equalToSuperview()
        }
        fpsLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backIcon)
            make.right.equalToSuperview().inset(10)
        }
        backIcon.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }
            self.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
        switch scrollViewType {
        case .UITableView:
            tableView.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            tableView.testData = [Int](0...11)
        case .UICollectionView:
            collectionVIew.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            collectionVIew.testData = [Int](0...11)
        case .UIScrollView:
            scrollView.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        case .NestedUIScrollView:
            fatalError()
        case .CollectionKitView:
            collectionKitView.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        case .ComposeHorizontalAndVerticalScrollView:
            composeHorizontalAndVerticalScrollView.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        case .UIView:
            uiview.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        }
        
        
        if TestExposureViewController.addFloatView {
            floatingView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(200)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [self] in
//            self.tableView.transform = CGAffineTransform.init(translationX: 0, y: -190)
//            self.tableView.snp.remakeConstraints { make in
//                make.top.equalTo(fpsLabel.snp.bottom).offset(10)
//                make.left.right.equalToSuperview()
//                make.bottom.equalToSuperview()
//            }
        }
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
    
    lazy var tableView: CustomUITableView = {
        let view = CustomUITableView()
        view.exposureOutputerDelegate = ExposureCellOutputerTemplate.make(self)
        view.keyIndexMapper = KeyIndexMapperTemplate.make(self)
        self.view.addSubview(view)
        return view
    }()
    
    lazy var collectionVIew: TestCellExposureUICollectionView = {
        let view = TestCellExposureUICollectionView()
        view.backgroundColor = UIColor.white
        view.exposureOutputerDelegate = ExposureCellOutputerTemplate.make(self)
        view.keyIndexMapper = KeyIndexMapperTemplate.make(self)

        self.view.addSubview(view)
        return view
    }()
    
    lazy var collectionKitView: TestCollectionKitCollectionView = {
        let view = TestCollectionKitCollectionView()
        view.backgroundColor = UIColor.white
        self.view.addSubview(view)
        return view
    }()
    
    lazy var scrollView: TestUIScrollView = {
        let view = TestUIScrollView()
        view.backgroundColor = UIColor.white
        self.view.addSubview(view)
        return view
    }()
    
    lazy var composeHorizontalAndVerticalScrollView: TestHorizontalScrollViewComposeVerticalScrollView = {
        let view = TestHorizontalScrollViewComposeVerticalScrollView.init(width: self.view.bounds.width, height: self.view.bounds.height)
        view.backgroundColor = UIColor.white
        self.view.addSubview(view)
        return view
    }()
    
    lazy var uiview: TestUIView = {
        let view = TestUIView.init()
        view.backgroundColor = UIColor.white
        self.view.addSubview(view)
        return view
    }()
    
    
    lazy var floatingView: UIView = {
        let view = UILabel()
        view.backgroundColor = UIColor.black
        view.text = "盖在UIScrollView上的悬浮View"
        view.textColor = UIColor.white
        view.sizeToFit()
        self.view.addSubview(view)
        return view
    }()
    
    lazy var fpsLabel: FPSLabel = {
        let view = FPSLabel()
        self.view.addSubview(view)
        return view
    }()
    
    deinit {
        debugPrint("UITableViewDemoViewController::deinit")
    }
}
