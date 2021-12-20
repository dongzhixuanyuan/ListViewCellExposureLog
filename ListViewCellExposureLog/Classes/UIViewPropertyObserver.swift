//
//  UIViewPropertyObserver.swift
//  ListViewCellExposureLog
//
//  Created by liudong on 2021/11/11.
//

import Foundation
import UIKit

/// 监听UIView是否可见、尺寸、位置、内部滚动触发重新计算曝光
public final class UIViewPropertyObserver<KeyType: Hashable, IndexType: Hashable>: NSObject {
    weak var obserableView: UIView?
    var trigger: ExposureCellInputerTemplate<KeyType, IndexType>
    private let observerProperties = ["contentOffset", "frame", "center", "transform"]

    private var superUIScroolView: NSHashTable<UIScrollView> = NSHashTable.weakObjects()
    public init<T: ExposureCellInputer>(view: UIView, input: T) where T.KeyType == KeyType, T.IndexType == IndexType {
        trigger = ExposureCellInputerTemplate.make(input)
        obserableView = view
        super.init()
        observerProperties.forEach { property in
            self.obserableView?.addObserver(self, forKeyPath: property, options: [.new], context: nil)
        }
    }

    /// 遍历superview，如果superview是UIScrollview的话，那么就监听superview的contentoffset，触发曝光计算
    public func addSuperviewScrollObserver() {
        superUIScroolView.allObjects.forEach { scrollView in
            scrollView.removeObserver(self, forKeyPath: "contentOffset")
        }
        superUIScroolView.removeAllObjects()
        var superView = obserableView?.superview
        while superView != nil, superView != obserableView?.window {
            if let uiscrollView = superView as? UIScrollView {
                superUIScroolView.add(uiscrollView)
            }
            superView = superView!.superview
        }
        superUIScroolView.allObjects.forEach { scrollView in
            scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.new], context: nil)
        }
    }

    public func removeSuperUIScrollViewObserver() {
        superUIScroolView.allObjects.forEach { scrollView in
            scrollView.removeObserver(self, forKeyPath: "contentOffset")
        }
        superUIScroolView.removeAllObjects()
    }

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if observerProperties.contains(keyPath ?? "") {
            self.trigger.calculateSignal(forceCalculate: false, delaySeconds: DELAYTIME_FOR_UI_FRAME_CHANGE)
        }
    }

    deinit {
        observerProperties.forEach { property in
            self.obserableView?.removeObserver(self, forKeyPath: property)
        }
        superUIScroolView.allObjects.forEach { scrollView in
            scrollView.removeObserver(self, forKeyPath: "contentOffset")
        }
    }
}
