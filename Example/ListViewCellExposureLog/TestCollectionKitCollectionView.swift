//
//  TestCollectionKitCollectionView.swift
//  ListViewCellExposureLog_Example
//
//  Created by liudong on 2021/11/8.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import CollectionKit
import Foundation
import ListViewCellExposureLog
import MJRefresh

class TestCollectionKitCollectionView: CellExposureLogCollectKitCollectView<String> {
    private let TAG = "TestCollectionKitCollectionView"
    open var dataChangeType: DataChangeType = .ClearAndSetData

    public lazy var testData = [Int]()
    lazy var dataSource = ArrayDataSource(data: self.testData)
    let viewSource = ClosureViewSource(viewUpdater: { (view: UILabel, data: Int, index: Int) in
        switch index % 4 {
        case 0:
            view.backgroundColor = .red
        case 1:
            view.backgroundColor = .green
        case 2:
            view.backgroundColor = .blue
        case 3:
            view.backgroundColor = .yellow
        default:
            fatalError()
        }

        view.text = "\(data)"
    })
    let sizeSource = { (index: Int, _: Int, _: CGSize) -> CGSize in
        let ratio = index % 3

        return CGSize(width: 120, height: 300)
    }

    lazy var myProvider = BasicProvider(
        dataSource: self.dataSource,
        viewSource: self.viewSource,
        sizeSource: self.sizeSource
    )
    init() {
        super.init(frame: .zero)
        let mjFooter = MJRefreshAutoStateFooter.init { [weak self] in
            guard let self = self else { return }

            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [self] in
                self.mj_footer?.endRefreshing()
                switch self.dataChangeType {
                case .AddOrSetData:
                    let start = self.testData.count
                    let end = start + 12
                    self.testData.append(contentsOf: [Int](start...end))
                    self.dataSource.data.append(contentsOf: [Int](start ..< end))
//                    self.calculateSignal(forceCalculate: true, delaySeconds: DELAYTIME_FOR_DATA_CHANGE_CALCULATE)
                case .ClearAndSetData:
                    let start = 12
                    let end = 23
                    self.testData.removeAll()
                    self.testData.append(contentsOf: [Int](start...end))
                    self.dataSource.data = self.testData
//                    self.calculateSignal(forceCalculate: true, delaySeconds: DELAYTIME_FOR_DATA_CHANGE_CALCULATE)

                case .UpdateRangeData:
                    let start = self.testData.count
                    let end = start + 5 //  (6-12)->(12,18)
                    self.testData.replaceSubrange(6...11, with: [Int](start...end))
                    self.dataSource.data = self.testData
//                    self.calculateSignal(forceCalculate: true, delaySeconds: DELAYTIME_FOR_DATA_CHANGE_CALCULATE)

                default:
                    fatalError()
                }
            }
        }
        mjFooter.setTitle("·都在这里了哦·", for: .noMoreData)
        mjFooter.setTitle("上拉加载更多", for: .idle)
        self.mj_footer = mjFooter
        showsVerticalScrollIndicator = false
        self.provider = myProvider
        testData = [Int](0...11)
        self.dataSource.data.append(contentsOf: testData)
    }

    override func indexMapToKey(index: CellExposureLogCollectKitCollectView<String>.IndexType) -> String {
        return String(testData[index])
    }

    override func outputCompleteVisibleItems(items: Set<KeyIndexCompose<String, CellExposureLogCollectKitCollectView<String>.IndexType>>) {
        super.outputCompleteVisibleItems(items: items)
        var result = ""
        items.forEach { item in
            result += item.toString()
        }
        debugPrint("\(TAG)::outputCompleteVisibleItems::\(result)")
    }

    override func outputPartVisibleItems(items: Set<KeyIndexCompose<String, CellExposureLogCollectKitCollectView<String>.IndexType>>) {
        super.outputPartVisibleItems(items: items)
        var result = ""
        items.forEach { item in
            result += item.toString()
        }
        debugPrint("\(TAG)::outputPartVisibleItems::\(result)")
    }

    override func outputCustomExposureRatioItems(items: Set<KeyIndexCompose<String, CellExposureLogCollectKitCollectView<String>.IndexType>>) {
        super.outputCustomExposureRatioItems(items: items)
        var result = ""
        items.forEach { item in
            result += item.toString()
        }
        debugPrint("\(TAG)::outputCustomExposureRatioItems::\(result)")
    }
}
