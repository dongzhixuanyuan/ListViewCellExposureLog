//
//  MockExposureCellInputer.swift
//  ListViewCellExposureLog_Tests
//
//  Created by liudong on 2021/12/2.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import ListViewCellExposureLog

/**
 Mock测试类。测试核心逻辑[CellExposureLogicImp]
 */

class MockExposureCellInputer: ExposureCellInputer, ExposureCellOutputer {
    typealias KeyType = String
    
    typealias IndexType = Int
    
    var mockVisibleChild = [ExposureItem<String, Int>]()
    
    var completeVisibleItems = Set<KeyIndexCompose<KeyType, IndexType>>.init()
    var particalVisibleItems = Set<KeyIndexCompose<KeyType, IndexType>>.init()
    var customRatioVisibleItems = Set<KeyIndexCompose<KeyType, IndexType>>.init()
    private var cellExposureCalculator: CellExposureLogicImp<KeyType, IndexType>?

    init() {
        self.cellExposureCalculator = CellExposureLogicImp(realImp: self)
    }
    
    var visibleRect = CGRect.zero

    var extraEdgeInset: UIEdgeInsets?
    
    func curVisibleItems() -> [ExposureItem<String, Int>] {
        return mockVisibleChild
    }
    
    func calculateSignal(forceCalculate: Bool, delaySeconds: Double?) {
        self.cellExposureCalculator?.calculateItemExposureWithDelay(forceCalculate: true, delaySeconds: nil)
    }
    
    var customExposureRatio: Double?
    
    func outputCompleteVisibleItems(items: Set<KeyIndexCompose<String, Int>>) {
        completeVisibleItems.removeAll()
        items.forEach { item in
            completeVisibleItems.insert(item)
        }
    }
    
    func outputPartVisibleItems(items: Set<KeyIndexCompose<String, Int>>) {
        particalVisibleItems.removeAll()
        items.forEach { item in
            particalVisibleItems.insert(item)
        }
    }
    
    func outputCustomExposureRatioItems(items: Set<KeyIndexCompose<String, Int>>) {
        customRatioVisibleItems.removeAll()
        items.forEach { item in
            customRatioVisibleItems.insert(item)
        }
    }
}
