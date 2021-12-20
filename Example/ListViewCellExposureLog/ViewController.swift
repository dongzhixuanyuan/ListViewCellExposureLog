//
//  ViewController.swift
//  ListViewCellExposureLog
//
//  Created by liudong on 10/28/2021.
//  Copyright (c) 2021 liudong. All rights reserved.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit
import ListViewCellExposureLog

class ViewController: UIViewController {
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(88)
        }
        containerView.addArrangedSubview(tableViewDemo)
        containerView.addArrangedSubview(collectionViewDemo)
        containerView.addArrangedSubview(scrollViewDemo)
        containerView.addArrangedSubview(collectionKitDemo)
        containerView.addArrangedSubview(nestedScrollViewDemo)
        containerView.addArrangedSubview(composeHorizontalAndVerticalScrollViewDemo)
        containerView.addArrangedSubview(uiViewDemo)
        containerView.addArrangedSubview(logUIView)

        tableViewDemo.rx.tap.subscribe { [weak self] _ in
            let vc = TestExposureViewController(scrollViewTypePara: .UITableView)
            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true, completion: nil)
        }.disposed(by: disposeBag)

        collectionViewDemo.rx.tap.subscribe { [weak self] _ in
            let vc = TestExposureViewController(scrollViewTypePara: .UICollectionView)
            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true, completion: nil)
        }.disposed(by: disposeBag)
        scrollViewDemo.rx.tap.subscribe { [weak self] _ in
            let vc = TestExposureViewController(scrollViewTypePara: .UIScrollView)
            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true, completion: nil)
        }.disposed(by: disposeBag)
        nestedScrollViewDemo.rx.tap.subscribe { [weak self] _ in
            let vc = TestNestedUIScrollViewController(.NestedUIScrollView)
            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true, completion: nil)
        }.disposed(by: disposeBag)
        collectionKitDemo.rx.tap.subscribe { [weak self] _ in
            let vc = TestExposureViewController(scrollViewTypePara: .CollectionKitView)
            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true, completion: nil)
        }.disposed(by: disposeBag)
        composeHorizontalAndVerticalScrollViewDemo.rx.tap.subscribe { [weak self] _ in
            let vc = TestExposureViewController(scrollViewTypePara: .ComposeHorizontalAndVerticalScrollView)
            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        uiViewDemo.rx.tap.subscribe { [weak self] _ in
            let vc = TestExposureViewController(scrollViewTypePara: .UIView)
            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true, completion: nil)
        }.disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    lazy var tableViewDemo: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("UITableViewPageTest", for: .normal)
        btn.titleLabel?.textColor = UIColor.black
        btn.backgroundColor = UIColor.blue
        btn.sizeToFit()
        return btn
    }()

    lazy var collectionViewDemo: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("UICollectionViewPageTest", for: .normal)
        btn.titleLabel?.textColor = UIColor.black
        btn.backgroundColor = UIColor.blue
        btn.sizeToFit()
        return btn
    }()

    lazy var scrollViewDemo: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("UIScrollViewPageTest", for: .normal)
        btn.titleLabel?.textColor = UIColor.black
        btn.backgroundColor = UIColor.blue
        btn.sizeToFit()
        return btn
    }()

    lazy var collectionKitDemo: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("CollectionKitViewPageTest", for: .normal)
        btn.titleLabel?.textColor = UIColor.black
        btn.backgroundColor = UIColor.blue
        btn.sizeToFit()
        return btn
    }()

    lazy var nestedScrollViewDemo: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("NestedScrollViewPageTest", for: .normal)
        btn.titleLabel?.textColor = UIColor.black
        btn.backgroundColor = UIColor.blue
        btn.sizeToFit()
        return btn
    }()

    lazy var composeHorizontalAndVerticalScrollViewDemo: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("HorizontalAndVerticalScrollViewPageTest", for: .normal)
        btn.titleLabel?.textColor = UIColor.black
        btn.backgroundColor = UIColor.blue
        btn.sizeToFit()
        return btn
    }()

    lazy var uiViewDemo: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("UiViewDemoPageTest", for: .normal)
        btn.titleLabel?.textColor = UIColor.black
        btn.backgroundColor = UIColor.blue
        btn.sizeToFit()
        return btn
    }()

    lazy var containerView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = CGFloat(16)
        stackView.distribution = .equalSpacing
        self.view.addSubview(stackView)
        return stackView
    }()
    
    lazy var logUIView: CellExposureLogUIView<Int> = {
        let view = TestUIViewControllerAppearChange.init()
        view.backgroundColor = UIColor.red
        return view
    }()
}


class TestUIViewControllerAppearChange: CellExposureLogUIView<Int> {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    override var exposureCalculateViews: [UIView]? {
        return [content]
    }
    
    override func outputCompleteVisibleItems(items: Set<KeyIndexCompose<Int, CellExposureLogUIView<Int>.IndexType>>) {
        super.outputCompleteVisibleItems(items: items)
        debugPrint("测试跳转到另一个UIViewController后，再回到当前UIViewController需要重新曝光")
    }
    
    func setUpUI()  {
        
        content.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

    }
    
    lazy var content: UILabel = {
        let view = UILabel.init()
        view.backgroundColor = .red
        view.text = "测试UIViewController切换后的上报"
        view.sizeToFit()
        addSubview(view)
        return view
    }()
}
