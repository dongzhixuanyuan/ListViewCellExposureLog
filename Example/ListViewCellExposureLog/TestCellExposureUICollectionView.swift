//
//  TestCellExposureUICollectionView.swift
//  ListViewCellExposureLog_Example
//
//  Created by liudong on 2021/10/30.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import ListViewCellExposureLog
import MJRefresh

class TestCellExposureUICollectionView: CellExposureLogUICollectionView<String>, UICollectionViewDataSource {
    open var dataChangeType: DataChangeType = .UpdateRangeData

    override var customExposureRatio: Double? {
        get {
            return 0.5
        }
        set {
            self.customExposureRatio = newValue
        }
    }
    
    var testData = [Int]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return testData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestUICollectionViewCell", for: indexPath)
        (cell as! TestUICollectionViewCell).updateUI(text: String(testData[indexPath.row]), index: indexPath.row)
        return cell
    }
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.estimatedItemSize = CGSize(width: 100, height: 100)
        
        super.init(frame: .zero, collectionViewLayout: layout)
        register(TestUICollectionViewCell.self, forCellWithReuseIdentifier: "TestUICollectionViewCell")
        let mjFooter = MJRefreshAutoStateFooter.init { [weak self] in
            guard let self = self else { return }
           
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.mj_footer?.endRefreshing()
                switch self.dataChangeType {
                case .AddOrSetData:
                    let start = self.testData.count
                    let end = start + 12
                    self.testData.append(contentsOf: [Int](start...end))
//                    self.updateData()
                    self.reloadData()
                case .ClearAndSetData:
                    let start = 0
                    let end = 11
                    self.testData.removeAll()
                    self.testData.append(contentsOf: [Int](start...end))
//                    self.updateData(dataChangeType: .ClearAndSetData)
                    self.reloadData()
                case .UpdateRangeData:
                    let start = self.testData.count
                    let end = start + 5 //  (6-12)->(12,18)
                    self.testData.replaceSubrange(6...11, with: [Int](start...end))
//                    self.updateData(dataChangeType: .UpdateRangeData, updateIndexPaths: [Int](6...11).map { value in
//                        IndexPath(row: value, section: 0)
//                    })
                    self.reloadData()
                default:
                    fatalError()
                }
            }
        }
        mjFooter.setTitle("·都在这里了哦·", for: .noMoreData)
        mjFooter.setTitle("上拉加载更多", for: .idle)
        self.mj_footer = mjFooter
        showsVerticalScrollIndicator = false
        delegate = self
        dataSource = self
    }
    
    override func indexMapToKey(index: CellExposureLogUICollectionView<String>.IndexType) -> String {
        return String(testData[index.row])
    }
    
    override func outputCompleteVisibleItems(items: Set<KeyIndexCompose<String, CellExposureLogUICollectionView<String>.IndexType>>) {
        super.outputCompleteVisibleItems(items: items)
        var result = ""
        items.forEach { item in
            result += item.toString()
        }
        debugPrint("CellExposureLogUICollectionView::CompleteVisibleItems:\(result)")
    }
  
    override func outputPartVisibleItems(items: Set<KeyIndexCompose<String, CellExposureLogUICollectionView<String>.IndexType>>) {
        super.outputPartVisibleItems(items: items)
        var result = ""
        items.forEach { item in
            result += item.toString()
        }
        debugPrint("CellExposureLogUICollectionView::PartVisibleItems:\(result)")
    }
    
    override func outputCustomExposureRatioItems(items: Set<KeyIndexCompose<String, CellExposureLogUICollectionView<String>.IndexType>>) {
        super.outputCustomExposureRatioItems(items: items)
        var result = ""
        items.forEach { item in
            result += item.toString()
        }
        debugPrint("CellExposureLogUICollectionView::outputCustomExposureRatioItems:\(result)")
    }

    deinit {
        debugPrint("TestCellExposureUICollectionView::deinit")
    }
}

private class TestUICollectionViewCell: UICollectionViewCell {
    var index: Int?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setUpUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI() {
        contentLabel.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(100)
            make.edges.equalToSuperview()
        }
    }
    
    func updateUI(text: String, index: Int) {
        contentLabel.text = text
        switch index % 3 {
        case 0:
            contentLabel.snp.updateConstraints { make in
                make.height.equalTo(100)
            }
        case 1:
            contentLabel.snp.updateConstraints { make in
                make.height.equalTo(300)
            }
        case 2:
            contentLabel.snp.updateConstraints { make in
                make.height.equalTo(200)
            }
        default:
            fatalError()
        }
    }
    
    lazy var contentLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.numberOfLines = 1
        view.layer.borderColor = UIColor.green.cgColor
        view.layer.borderWidth = 2
        contentView.addSubview(view)
        return view
    }()
}
