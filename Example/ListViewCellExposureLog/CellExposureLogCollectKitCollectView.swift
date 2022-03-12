//
//  CellExposureLogCollectKitCollectView.swift
//  ListViewCellExposureLog
//
//  Created by liudong on 2021/11/3.
//

import CollectionKit
import Foundation
import ListViewCellExposureLog

open class CellExposureLogCollectKitCollectView<KeyType: Hashable>: CollectionView, ExposureCellInputer, ExposureCellOutputer, KeyIndexMapper {
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
    
    open  func reloadDataWrapper(contentOffsetAdjustFn: (() -> CGPoint)? = nil) {
        super.reloadData(contentOffsetAdjustFn: contentOffsetAdjustFn)
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

    open var extraEdgeInset: UIEdgeInsets?
    
    open func curVisibleItems() -> [ExposureItem<KeyType, IndexType>] {
        return visibleIndexes.compactMap { index in
            if let cell = cell(at: index) ,let key = indexMapToKey(index: index){
                return CellExposureLogUtil.cellTransferToExposureItem(key: key, indexpath: index, cell: cell)
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
    
    public func currentExposureItems(partVisibleItems: Set<KeyIndexCompose<KeyType, IndexType>>, completeVisibleItems: Set<KeyIndexCompose<KeyType, IndexType>>, customExposureRatioVisibleItems: Set<KeyIndexCompose<KeyType, IndexType>>, curVisibleRect: CGRect) {
        self.exposureOutputerDelegate?.currentExposureItems(partVisibleItems: partVisibleItems, completeVisibleItems: completeVisibleItems, customExposureRatioVisibleItems: customExposureRatioVisibleItems, curVisibleRect: curVisibleRect)
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
