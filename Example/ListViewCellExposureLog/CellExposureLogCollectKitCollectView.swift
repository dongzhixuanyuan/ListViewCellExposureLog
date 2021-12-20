//
//  CellExposureLogCollectKitCollectView.swift
//  ListViewCellExposureLog
//
//  Created by liudong on 2021/11/3.
//

import CollectionKit
import Foundation
import ListViewCellExposureLog

open class CellExposureLogCollectKitCollectView<KeyType: Hashable>: CollectionView, UIScrollViewDelegate, ExposureCellInputer, ExposureCellOutputer, KeyIndexMapper {
    public typealias KeyType = KeyType
    
    public typealias IndexType = Int

    public var exposureOutputerDelegate: ExposureCellOutputerTemplate<KeyType, IndexType>?
    public var keyIndexMapper: KeyIndexMapperTemplate<KeyType, IndexType>?
    
    private var cellExposureCalculator: CellExposureLogicImp<KeyType, IndexType>?
    private var viewPropertyObserver: UIViewPropertyObserver<KeyType, IndexType>?

    private var isAttached = false

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.cellExposureCalculator = CellExposureLogicImp(realImp: self)
        self.viewPropertyObserver = UIViewPropertyObserver.init(view: self, input: self)
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadDataWrapper(contentOffsetAdjustFn: (() -> CGPoint)? = nil) {
        reloadData(contentOffsetAdjustFn: contentOffsetAdjustFn)
        calculateSignal(forceCalculate: true, delaySeconds: DELAYTIME_FOR_DATA_CHANGE_CALCULATE)
    }
    
    //  MARK:  Must override
    open func indexMapToKey(index: IndexType) -> KeyType? {
        if keyIndexMapper != nil {
            return keyIndexMapper!.indexMapToKey(index: index)
        }
        if index is KeyType {
            return (index as! KeyType)
        }
        fatalError("如果未设置keyIndexMapper代理的话，则必须复写该函数")
    }
    
    //    MARK: ExposureCellInputer Delegate

    open var visibleRect: CGRect {
        get {
            var windowVisibleRect = self.window?.bounds ?? .zero
            if let edgeInset = self.extraEdgeInset {
                //            UIView有被其他顶层View遮挡的情况
                windowVisibleRect = CellExposureLogUtil.transformRectWithEdgeInset(sourceRect: windowVisibleRect, edgeInset: edgeInset)
            }
            return self.convert(self.bounds, to: self.window).intersection(windowVisibleRect) // 在屏幕范围内的可见区域
        }
        set {
            self.visibleRect = newValue
        }
    }

    open var extraEdgeInset: UIEdgeInsets?
    
    open func curVisibleItems() -> [ExposureItem<KeyType, IndexType>] {
        if visibleIndexes.isEmpty {
            return []
        }
        
        return visibleIndexes.compactMap { index in
            if let cell = cell(at: index) {
                let screenRect = cell.convert(cell.bounds, to: self.window)
                if screenRect.width > 0, screenRect.height > 0,let key = indexMapToKey(index: index) {
                    return ExposureItem(identifier: key, index: index, rect: screenRect)
                }
                return nil
            }
            return nil
        }
    }
    
    open func calculateSignal(forceCalculate: Bool, delaySeconds: Double?) {
        if isAttached {
            self.cellExposureCalculator?.calculateItemExposureWithDelay(forceCalculate: forceCalculate, delaySeconds: delaySeconds)
        }
    }
    
    //    MARK: ExposureCellOutputer Delegate

    open var customExposureRatio: Double?
    
    public func outputCompleteVisibleItems(items: Set<KeyIndexCompose<KeyType, IndexType>>) {
        self.exposureOutputerDelegate?.outputCompleteVisibleItems(items: items)
    }
   
    public func outputPartVisibleItems(items: Set<KeyIndexCompose<KeyType, IndexType>>) {
        self.exposureOutputerDelegate?.outputPartVisibleItems(items: items)
    }

    public func outputCustomExposureRatioItems(items: Set<KeyIndexCompose<KeyType, IndexType>>) {
        self.exposureOutputerDelegate?.outputCustomExposureRatioItems(items: items)
    }

    override open func willMove(toSuperview newSuperview: UIView?) {
        isAttached = (newSuperview != nil)
    }
       
    open override func didMoveToWindow() {
        isAttached = (self.window != nil)
        if isAttached {
            viewPropertyObserver?.addSuperviewScrollObserver()
            calculateSignal(forceCalculate: true, delaySeconds: DELAYTIME_FOR_UI_FRAME_CHANGE)
        } else {
            viewPropertyObserver?.removeSuperUIScrollViewObserver()
            cellExposureCalculator?.resetReportedVisibleItems()
        }
    }
}
