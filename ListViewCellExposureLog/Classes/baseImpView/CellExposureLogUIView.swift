//
//  CellExposureLogUIView.swift
//  ListViewCellExposureLog
//
//  Created by liudong on 2021/11/10.
//

import Foundation
import UIKit

/// 适用于一个普通的UIView作为容器，在一个UIScrollview中滚动，需要记录该UIView容器内部子View的曝光情况
/// 注意：如果数据更新了，需要手动调用[calculateSignal(true,DELAYTIME_FOR_DATA_CHANGE_CALCULATE)]
open class CellExposureLogUIView<KeyType:Hashable>: UIView, ExposureCellInputer, ExposureCellOutputer,KeyIndexMapper {
    public typealias KeyType = KeyType
    
    public typealias IndexType = Int
    
    /// 需要进行曝光统计的指定View.
    open var exposureCalculateViews: [UIView]? {
        fatalError("必须复写")
    }
    public var exposureOutputerDelegate: ExposureCellOutputerTemplate<KeyType,IndexType>?
    public var keyIndexMapper:KeyIndexMapperTemplate<KeyType,IndexType>?
    
    private var cellExposureCalculator: CellExposureLogicImp<KeyType,IndexType>?
    private var viewPropertyObserver:UIViewPropertyObserver<KeyType,IndexType>?

    private var isAttached = false
    private weak var uiscrollViewContainer: UIScrollView?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.cellExposureCalculator = CellExposureLogicImp(realImp: self)
        self.viewPropertyObserver = UIViewPropertyObserver.init(view: self, input: self)
    }
    
    // MARK: Must Override

    open func indexMapToKey(index: IndexType) -> KeyType? {
        if keyIndexMapper != nil {
            return keyIndexMapper!.indexMapToKey(index: index)
        }
        if index is KeyType {
            return (index as! KeyType)
        }
        fatalError("如果未设置keyIndexMapper代理，并且IndexType和KeyType类型不一致，则必须复写该函数")
    }
    
//    MARK: ExposureCellInputer Delegate

    open var extraEdgeInset: UIEdgeInsets?
    open var visibleRect: CGRect {
        get {
            var windowVisibleRect = self.window?.bounds ?? .zero
            if let edgeInset = self.extraEdgeInset {
    //            UIView有被其他顶层View遮挡的情况
                windowVisibleRect = CellExposureLogUtil.transformRectWithEdgeInset(sourceRect: windowVisibleRect, edgeInset: edgeInset)
            }
            let result = self.convert(self.bounds, to: self.window).intersection(windowVisibleRect) // 在屏幕范围内的可见区域
            if let container = uiscrollViewContainer {
                let parentRect = container.convert(container.bounds, to: self.window)
                return result.intersection(parentRect)
            }
            return result
        }
        set {
            self.visibleRect = newValue
        }
    }
        
    open func curVisibleItems() -> [ExposureItem<KeyType,IndexType>] {
        var result = [ExposureItem<KeyType,IndexType>]()
        exposureCalculateViews?.enumerated()
            .forEach { iterator in
                let screenFrame = iterator.element.convert(iterator.element.bounds, to: self.window)
                if screenFrame.width > 0, screenFrame.height > 0,let  key = indexMapToKey(index: iterator.offset) {
                    result.append(ExposureItem<KeyType,IndexType>.init(identifier: key,index: iterator.offset, rect: screenFrame))
                }
            }
        return result
    }
    
    open func calculateSignal(forceCalculate: Bool, delaySeconds: Double?) {
        if isAttached {
            self.cellExposureCalculator?.calculateItemExposureWithDelay(forceCalculate: forceCalculate, delaySeconds: delaySeconds)
        }
    }
    
//    MARK: ExposureCellOutputer Delegate

    open var customExposureRatio: Double?
    
    open func outputCompleteVisibleItems(items: Set<KeyIndexCompose<KeyType,IndexType>>) {
        self.exposureOutputerDelegate?.outputCompleteVisibleItems(items: items)
    }

    open func outputPartVisibleItems(items: Set<KeyIndexCompose<KeyType,IndexType>>) { self.exposureOutputerDelegate?.outputPartVisibleItems(items: items)
    }
    
    open func outputCustomExposureRatioItems(items: Set<KeyIndexCompose<KeyType,IndexType>>) {
        self.exposureOutputerDelegate?.outputCustomExposureRatioItems(items: items)
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        isAttached = (newSuperview != nil)
    }
   
    open override func didMoveToWindow() {
        isAttached = (self.window != nil)
        uiscrollViewContainer = getNearUIScroolView()
        if isAttached {
            viewPropertyObserver?.addSuperviewScrollObserver()
            calculateSignal(forceCalculate: true, delaySeconds: DELAYTIME_FOR_UI_FRAME_CHANGE)
        } else {
            viewPropertyObserver?.removeSuperUIScrollViewObserver()
            cellExposureCalculator?.resetReportedVisibleItems()
        }
    }
    
    /// 如果是被放入UIScrollview中，可见范围要与UIScrollView的可见范围取交集。
    /// - Returns: 最近的UIScrollView容器
    private func getNearUIScroolView() -> UIScrollView? {
        var superView = self.superview
        while superView != nil, superView != self.window {
            if let uisrollView = superView as? UIScrollView {
                return uisrollView
            }
            superView = superView?.superview
        }
        return nil
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("CellExposureLogUIScrollView::init(coder:) has not been implemented")
    }
    
    deinit {
//        debugPrint("CellExposureLogUIScrollView::deinit")
    }
}
