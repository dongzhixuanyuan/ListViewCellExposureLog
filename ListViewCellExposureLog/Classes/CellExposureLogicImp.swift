//
//  CellExposureCalculate.swift
//  ListViewCellExposureLog
//
//  Created by liudong on 2021/10/28.
//

import Foundation

public class CellExposureLogicImp<KeyType: Hashable,IndexType:Hashable> {
    private let TAG = "CellExposureCalculate"
    open var logEnable = false
    
    var preVisibleItems = Set<KeyIndexCompose<KeyType,IndexType>>.init() // 前一次的可见Item(包含部分和完全可见)
    var preCompleteVisibleItems = Set<KeyIndexCompose<KeyType,IndexType>>.init() // 前一次完全可见Item
    var preCustomExposureRatioItems = Set<KeyIndexCompose<KeyType,IndexType>>.init() // 前一次自定义曝光比例的可见Item
    
    var inputer: ExposureCellInputerTemplate<KeyType,IndexType>? // 最新数据提供者
    var outputer: ExposureCellOutputerTemplate<KeyType,IndexType>? // 计算结果输出对象
    var calculateTimeinterval: Int = 10 * 1_000_000_000 / 60 // 以60帧为标准,两次计算的时间间隔为10帧，约为160ms//两次计算的时间间隔，单位纳秒
    private var preCalculateTimeStamp = Date(timeIntervalSince1970: 0)
    var forceCalculate = false
    private var calculateWorkItem: DispatchWorkItem?
    
    public init<T: ExposureCellInputer>(realImp: T) where T: ExposureCellOutputer, T.KeyType == KeyType,T.IndexType == IndexType {
        self.inputer = ExposureCellInputerTemplate.make(realImp)
        self.outputer = ExposureCellOutputerTemplate.make(realImp)
    }
    
    required init() {
        fatalError()
    }
    
    public func calculateItemExposureWithDelay(forceCalculate: Bool = false, delaySeconds: Double?) {
        if delaySeconds != nil {
            if calculateWorkItem == nil || forceCalculate {
                calculateWorkItem?.cancel()
                calculateWorkItem = DispatchWorkItem(block: {
                    [weak self] in
                    guard let self = self else { return }
                    self.calculateItemExposure(forceCalculate: forceCalculate)
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds!) { [weak self] in
                    guard let self = self else { return }
                    self.calculateWorkItem?.perform()
                    self.calculateWorkItem = nil
                }
            }
        } else {
            calculateItemExposure(forceCalculate: forceCalculate)
        }
    }
    
    private func calculateItemExposure(forceCalculate: Bool = false) {
        guard let inputer = self.inputer else {
            return
        }
        let now = Date()
        if !forceCalculate {
            let interval = Calendar.current.dateComponents([.nanosecond], from: preCalculateTimeStamp, to: now).nanosecond ?? calculateTimeinterval
            if interval < calculateTimeinterval {
                if logEnable {
                    debugPrint("\(TAG):未到计算间隔时间")
                }
                return
            }
        }
        preCalculateTimeStamp = now
        var curCompleteVisibleItems = Set<KeyIndexCompose<KeyType,IndexType>>.init() // 当前完全可见的Cell的indexpath
        var curVisibleItems = Set<KeyIndexCompose<KeyType,IndexType>>.init() // 可见集合c（包括部分可见和完全可见）
        var curCustomExposureRatioVisibleItems = Set<KeyIndexCompose<KeyType,IndexType>>.init() // 达到自定义曝光比例的Item集合
        let visibleRect = inputer.visibleRect
        let customExposureRatio = outputer?.customExposureRatio
        inputer.curVisibleItems().filter { item in
            item.rect.width > 0 && item.rect.height > 0 //过滤掉长或宽为0的Item,
        }.forEach { exposureItem in
            if visibleRect.contains(exposureItem.rect) {
                curCompleteVisibleItems.insert(exposureItem.typeCombine)
                curCustomExposureRatioVisibleItems.insert(exposureItem.typeCombine)
                curVisibleItems.insert(exposureItem.typeCombine)
            } else if visibleRect.intersects(exposureItem.rect) {
                let intersectionSize = exposureItem.rect.intersection(visibleRect).size
                let exposureRatio = (intersectionSize.width * intersectionSize.height) / (exposureItem.rect.height * exposureItem.rect.width)
                if exposureRatio > 0.05 {
//                  过滤掉在屏幕上的可见区域小于卡片面积95%的item（譬如PageView滑动到下一页时，程序检测到前一页依然可见，但实际人眼是看不出来的，可能就1-2像素而已。）
                    curVisibleItems.insert(exposureItem.typeCombine)
                    if let validCustomExposureRatio = customExposureRatio {
                        if Double(exposureRatio) >= validCustomExposureRatio {
                            curCustomExposureRatioVisibleItems.insert(exposureItem.typeCombine)
                        }
                    }
                }
            }
        }
        
        let newCompleteExposureItems = curCompleteVisibleItems.subtracting(self.preCompleteVisibleItems)
        if !newCompleteExposureItems.isEmpty {
            outputer?.outputCompleteVisibleItems(items: newCompleteExposureItems)
        }
        if logEnable {
            newCompleteExposureItems.forEach { item in
                debugPrint("\(TAG):completeVisibleIndexpath:\(item)")
            }
        }
//        CustomExposureRatioCell计算逻辑
        let newCustomExposureRatioItems = curCustomExposureRatioVisibleItems.subtracting(self.preCustomExposureRatioItems)
        if !newCustomExposureRatioItems.isEmpty {
            outputer?.outputCustomExposureRatioItems(items: newCustomExposureRatioItems)
        }
        if logEnable {
            newCustomExposureRatioItems.forEach { item in
                debugPrint("\(TAG):customExposureRatioIndexpath:\(item)")
            }
        }
        
//        PartialVisibleCell计算逻辑
        let newVisibleItems = curVisibleItems.subtracting(self.preVisibleItems)
        if !newVisibleItems.isEmpty {
            outputer?.outputPartVisibleItems(items: newVisibleItems)
        }
        if logEnable {
            newVisibleItems.forEach { item in
                debugPrint("\(TAG):partialVisibleIndexpath:\(item)")
            }
        }
        
//        重新设置几个preItems的值
        self.preVisibleItems = curVisibleItems
        
        let stillVisibleButExposureRatioNotEnoughInPreCustomExposureItems = self.preCustomExposureRatioItems.intersection(curVisibleItems) // 上次的曝光Item中，如果没有完全移出屏幕.也需要加入到preCustomExposureRatioItems集合中
        self.preCustomExposureRatioItems = stillVisibleButExposureRatioNotEnoughInPreCustomExposureItems.union(curCustomExposureRatioVisibleItems)
        
        let stillVisibleButNotCompleteVisibleInPreCompleteVisibleItems = self.preCompleteVisibleItems.intersection(curVisibleItems) // 上次完全曝光的item中，如果没有完全移出屏幕。也需要添加到self.preCompleteVisibleItems
        self.preCompleteVisibleItems = stillVisibleButNotCompleteVisibleInPreCompleteVisibleItems.union(curCompleteVisibleItems)
    }
    
    /// 重置上报记录
    public func resetReportedVisibleItems() {
        self.preCompleteVisibleItems.removeAll()
        self.preVisibleItems.removeAll()
        self.preCustomExposureRatioItems.removeAll()
    }
    
    /// 清除指定的Item
    /// - Parameter items: 需要重置的Item标识符
    public func removeSpecifiedItems(items:[KeyIndexCompose<KeyType,IndexType>]) {
        items.forEach { item in
            self.preCompleteVisibleItems.remove(item)
            self.preVisibleItems.remove(item)
            self.preCustomExposureRatioItems.remove(item)
        }
    }
}
