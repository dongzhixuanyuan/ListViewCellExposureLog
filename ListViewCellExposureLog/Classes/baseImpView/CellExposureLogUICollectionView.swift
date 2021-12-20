//
//  CellExposureLogUICollectionView.swift
//  ListViewCellExposureLog
//
//  Created by liudong on 2021/10/28.
//

import Foundation

open class CellExposureLogUICollectionView<KeyType: Hashable>: UICollectionView, UICollectionViewDelegate, ExposureCellInputer, ExposureCellOutputer,KeyIndexMapper {
    public typealias KeyType = KeyType

    public typealias IndexType = IndexPath

    private let TAG = "CellExposureLogUICollectionView"
    public var exposureOutputerDelegate: ExposureCellOutputerTemplate<KeyType, IndexType>?
    public var keyIndexMapper: KeyIndexMapperTemplate<KeyType, IndexType>?

    private var cellExposureCalculator: CellExposureLogicImp<KeyType, IndexType>?
    private var viewPropertyObserver:UIViewPropertyObserver<KeyType,IndexType>?

    private var isAttached = false

    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        cellExposureCalculator = CellExposureLogicImp(realImp: self)
        viewPropertyObserver = UIViewPropertyObserver.init(view: self, input: self)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("CellExposureLogUICollectionView::init(coder:) has not been implemented")
    }

    //  override一些数据更新方法，保证数据更新后的Cell曝光准确
    override open func reloadData() {
        super.reloadData()
        self.cellExposureCalculator?.calculateItemExposureWithDelay(forceCalculate: true, delaySeconds: DELAYTIME_FOR_DATA_CHANGE_CALCULATE)
    }

    override open func reloadItems(at indexPaths: [IndexPath]) {
        super.reloadItems(at: indexPaths)
        self.cellExposureCalculator?.calculateItemExposureWithDelay(forceCalculate: true, delaySeconds: DELAYTIME_FOR_DATA_CHANGE_CALCULATE)
    }

    /// MARK:
    open func indexMapToKey(index: IndexType) -> KeyType? {
        if keyIndexMapper != nil {
            return keyIndexMapper!.indexMapToKey(index: index)
        }
        if index is KeyType {
            return (index as! KeyType)
        }
        fatalError("如果未设置keyIndexMapper代理，并且IndexType和KeyType类型不一致，则必须复写该函数")    }

    //  MARK: ExposureCellInputer Delegate

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
        if indexPathsForVisibleItems.isEmpty {
            return []
        }
        return indexPathsForVisibleItems.compactMap { indexpath in
            if let cell = cellForItem(at: indexpath) {
                let screenRect = cell.convert(cell.bounds, to: self.window)
                if screenRect.width > 0, screenRect.height > 0,let key = indexMapToKey(index: indexpath) {
                    return ExposureItem(identifier: key, index: indexpath, rect: screenRect)
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

    //  MARK: ExposureCellOutputer Delegate

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
