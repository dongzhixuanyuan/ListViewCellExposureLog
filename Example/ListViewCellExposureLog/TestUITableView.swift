//
//  TestUITableView.swift
//  ListViewCellExposureLog_Example
//
//  Created by liudong on 2021/11/5.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import ListViewCellExposureLog
import MJRefresh
class CustomUITableView: CellExposureLogUITableView<String>, UITableViewDataSource {
    private let TAG = "CustomUITableView"
    var testData = [Int]()
    open var dataChangeType: DataChangeType = .ClearAndSetData
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
    
    init() {
        super.init(frame: .zero, style: .plain)
        register(TestUITableViewCell.self, forCellReuseIdentifier: "TestUITableViewCell")
        separatorStyle = .none
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
                    let start = 13
                    let end = 24
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
        separatorStyle = .none
        dataSource = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var customExposureRatio: Double? {
        get {
            return 0.5
        }
        set {
            self.customExposureRatio = newValue
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TestUITableViewCell", for: indexPath)
        (cell as! TestUITableViewCell).updateUI(text: String(testData[indexPath.row]))
        return cell
    }
    
    override func indexMapToKey(index: CellExposureLogUITableView<String>.IndexType) -> String {
        return String(testData[index.row])
    }
    
    override func outputCompleteVisibleItems(items: Set<KeyIndexCompose<String, CellExposureLogUITableView<String>.IndexType>>) {
        super.outputCompleteVisibleItems(items: items)
        var result = ""
        items.forEach { item in
            result += item.toString()
        }
        debugPrint(TAG + "CompleteVisibleItems:\(result)")
    }
    
    override func outputPartVisibleItems(items: Set<KeyIndexCompose<String, CellExposureLogUITableView<String>.IndexType>>) {
        super.outputPartVisibleItems(items: items)
        var result = ""
        items.forEach { item in
            result += item.toString()
        }
        debugPrint(TAG + "PartVisibleItems:\(result)")
    }
   
    override func outputCustomExposureRatioItems(items: Set<KeyIndexCompose<String, CellExposureLogUITableView<String>.IndexType>>) {
        super.outputCustomExposureRatioItems(items: items)
        var result = ""
        items.forEach { item in
            result += item.toString()
        }
        debugPrint(TAG + "CustomExposureRatioItems:\(result)")
    }
}

private class TestUITableViewCell: UITableViewCell {
    var index: Int?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI() {
        contentLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(100)
        }
    }
    
    func updateUI(text: String) {
        contentLabel.text = text
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
