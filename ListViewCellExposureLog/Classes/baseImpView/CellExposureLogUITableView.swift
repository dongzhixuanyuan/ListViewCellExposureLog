//
//  UITableViewWithItemExposureFeature.swift
//  AFNetworking
//
//  Created by liudong on 2021/10/21.
//

import Foundation
import UIKit

/// 带有Cell曝光统计功能的UITableView
open class CellExposureLogUITableView<KeyType: Hashable>: UITableView, ExposureCellInputer, ExposureCellOutputer, KeyIndexMapper {
    public typealias KeyType = KeyType
    
    public typealias IndexType = IndexPath
    
    private let TAG = "CellExposureLogUITableView"
    private var isAttached = false
    public var exposureOutputerDelegate: ExposureCellOutputerTemplate<KeyType, IndexType>?
    public var keyIndexMapper: KeyIndexMapperTemplate<KeyType, IndexType>?

    private var cellExposureCalculator: CellExposureLogicImp<KeyType, IndexType>?
    private var viewPropertyObserver:UIViewPropertyObserver<KeyType,IndexType>?
 
    override public init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        cellExposureCalculator = CellExposureLogicImp(realImp: self)
        viewPropertyObserver = UIViewPropertyObserver.init(view: self, input: self)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override一些数据更新方法，保证数据更新后的Cell曝光准确
    override open func reloadData() {
        super.reloadData()
        self.calculateSignal(forceCalculate: true, delaySeconds: DELAYTIME_FOR_DATA_CHANGE_CALCULATE)
    }
    
    override open func reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        super.reloadRows(at: indexPaths, with: animation)
        self.calculateSignal(forceCalculate: true, delaySeconds: DELAYTIME_FOR_DATA_CHANGE_CALCULATE)
    }
    
//    MARK: ExposureCellInputer Delegate

    open var extraEdgeInset: UIEdgeInsets?
    
    /// Must override
    open func indexMapToKey(index: IndexType) -> KeyType? {
        if keyIndexMapper != nil {
            return keyIndexMapper!.indexMapToKey(index: index)
        }
        if index is KeyType {
            return (index as! KeyType)
        }
        fatalError("如果未设置keyIndexMapper代理，并且IndexType和KeyType类型不一致，则必须复写该函数")
    }

    open func curVisibleItems() -> [ExposureItem<KeyType, IndexType>] {
        return indexPathsForVisibleRows?.compactMap { indexpath in
            if let cell = cellForRow(at: indexpath), let key = indexMapToKey(index: indexpath) {
                return CellExposureLogUtil.cellTransferToExposureItem(key: key, indexpath: indexpath, cell: cell)
            }
            return nil
        } ?? []
    }
    
    open func calculateSignal(forceCalculate: Bool, delaySeconds: Double?) {
        if isAttached {
            self.cellExposureCalculator?.calculateItemExposureWithDelay(forceCalculate: forceCalculate, delaySeconds: delaySeconds)
        }
    }
    
    //    MARK: ExposureCellOutputer Delegate

    open var customExposureRatio: Double?

    open func outputCompleteVisibleItems(items: Set<KeyIndexCompose<KeyType, IndexType>>) {
        self.exposureOutputerDelegate?.outputCompleteVisibleItems(items: items)
    }

    open func outputPartVisibleItems(items: Set<KeyIndexCompose<KeyType, IndexType>>) {
        self.exposureOutputerDelegate?.outputPartVisibleItems(items: items)
    }
        
    open func outputCustomExposureRatioItems(items: Set<KeyIndexCompose<KeyType, IndexType>>) {
        self.exposureOutputerDelegate?.outputCustomExposureRatioItems(items: items)
    }
    
    open func currentExposureItems(partVisibleItems: Set<KeyIndexCompose<KeyType, IndexType>>, completeVisibleItems: Set<KeyIndexCompose<KeyType, IndexType>>, customExposureRatioVisibleItems: Set<KeyIndexCompose<KeyType, IndexType>>, curVisibleRect: CGRect) {
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
