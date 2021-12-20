//
//  BaseNestedScrollViewViewController.swift
//  YDDMain
//
//  Created by liudong on 2021/9/14.
//  嵌套2个ScrollView的基类，处理嵌套滚动。适用于那种向上滚动到一定位置后吸顶，然后子ScrollView继续滚动的UI交互需求。

import Foundation
import UIKit

open class BaseNestedScrollViewViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    // 动画相关
    var animator: UIDynamicAnimator?
    
    weak var decelerationBehavior: UIDynamicItemBehavior?
    
    weak var springBehavior: UIAttachmentBehavior?
    
    var dynamicItem = CustomDynamicItem()
        
    var panGesture: UIPanGestureRecognizer?
    
    var isVertical: Bool = true
    
    // scrollView顶部最多滑动距离
    open var maxOffsetY: CGFloat = 0
    
    open var hasFixedMaxOffsetY:Bool = false ///true:表示布局前就已经知道maxOffsetY的确定值;false:布局完成前，不知道maxOffsetY的值，需要在layoutSubviews中获取
    
    // 吸顶判断
    var reachTop: Bool = false {
        didSet {
            if reachTop == oldValue {
                return
            }
            if reachTop {
                mainScrollViewDidReachTop()
            } else {
                mainScrollViewNotInTop()
            }
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        setupScrollLogic()
    }
    
    open func mainScrollViewDidReachTop() {}
    
    open func mainScrollViewNotInTop() {}
    
    open func mainScrollViewContentOffsetIsZero() {} // 恢复到最初始的状态
    
    open var mainScrollView: UIScrollView?
    
    open var childScrollView: UIScrollView?
    
    func setupScrollLogic() {
        self.mainScrollView?.isScrollEnabled = false
        self.mainScrollView?.contentInsetAdjustmentBehavior = .never
        self.mainScrollView?.delegate = self
//        self.childScrollView?.contentInsetAdjustmentBehavior = .never
        self.childScrollView?.isScrollEnabled = false
        self.childScrollView?.delegate = self
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction(recognizer:)))
        panGesture?.delegate = self
        self.view.addGestureRecognizer(panGesture!)
        
        self.animator = UIDynamicAnimator(referenceView: self.view)
        self.dynamicItem = CustomDynamicItem()
    }
    
    @objc func panGestureRecognizerAction(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            let velocity = recognizer.velocity(in: self.view)
            if abs(velocity.y) > abs(velocity.x) {
                isVertical = true
            } else {
                isVertical = false
            }
         
            self.animator?.removeAllBehaviors()
        } else if recognizer.state == .changed {
            // locationInView:获取到的是手指点击屏幕实时的坐标点；
            // translationInView：获取到的是手指移动后，在相对坐标中的偏移量
            if isVertical {
                // 往上滑为负数，往下滑为正数
                
                let currentY = recognizer.translation(in: self.view).y
                self.controlScrollForVertical(detal: currentY, state: .changed)
            }
            
        } else if recognizer.state == .ended {
            if isVertical {
                // velocity是在手势结束的时候获取的竖直方向的手势速度
                let velocity = recognizer.velocity(in: self.view)
                
                startDecelerationBehavior(velocity: velocity)
            }
        }
        // 保证每次只是移动的距离，不是从头一直移动的距离
        recognizer.setTranslation(.zero, in: self.view)
    }
    
    func startDecelerationBehavior(velocity: CGPoint) {
        self.dynamicItem.center = self.view.bounds.origin
        
        let inertialBehavior = UIDynamicItemBehavior(items: [self.dynamicItem])

        inertialBehavior.addLinearVelocity(CGPoint(x: 0, y: velocity.y), for: self.dynamicItem)

        // 通过尝试取2.0比较像系统的效果
        inertialBehavior.resistance = 2.0
        var lastCenter: CGPoint = .zero
        inertialBehavior.action = { [weak self] in
            guard let self = self else { return }
            if self.isVertical {
                // 得到每次移动的距离
                let currentY = self.dynamicItem.center.y - lastCenter.y
                self.controlScrollForVertical(detal: currentY, state: .ended)
            }
            lastCenter = self.dynamicItem.center
        }
        self.animator?.addBehavior(inertialBehavior)
        self.decelerationBehavior = inertialBehavior
    }
    
    // 控制上下滚动的方法
    func controlScrollForVertical(detal: CGFloat, state: UIGestureRecognizer.State) {
        // 判断是主ScrollView滚动还是子ScrollView滚动,detal为手指移动的距离
        if mainScrollView!.contentOffset.y >= self.maxOffsetY {
            reachTop = true
            guard let childScrollView = childScrollView else {
                mainScrollView!.contentOffset = CGPoint(x: 0, y: mainScrollView!.contentOffset.y - detal)
                return
            }
            var offsetY = childScrollView.contentOffset.y - detal
            if offsetY < 0 {
                // 当子ScrollView的contentOffset小于0之后就不再移动子ScrollView，而要移动主ScrollView
                offsetY = 0
                mainScrollView!.contentOffset = CGPoint(x: 0, y: mainScrollView!.contentOffset.y - detal)
            } else if offsetY >= (childScrollView.contentSize.height - childScrollView.frame.height) {
                // 当子ScrollView的contentOffset大于tableView的可移动距离时
                offsetY = childScrollView.contentOffset.y - rubberBandDistance(offset: detal, dimension: view.frame.height)
                
            }
            childScrollView.contentOffset = CGPoint(x: 0, y: offsetY)
        } else {
            reachTop = false
            var mainOffsetY = mainScrollView!.contentOffset.y - detal
            if mainOffsetY < 0 {
                mainOffsetY = mainScrollView!.contentOffset.y - rubberBandDistance(offset: detal, dimension: self.view.frame.height)
            } else if mainOffsetY > self.maxOffsetY {
                mainOffsetY = self.maxOffsetY
            }
            
            mainScrollView!.contentOffset = CGPoint(x: 0, y: mainOffsetY)
            
            if mainScrollView!.contentOffset.y <= 0 {
                self.mainScrollViewContentOffsetIsZero()
            }
        }
        
        let outsideFrame = isOutsideFrame()
        
        if outsideFrame, self.decelerationBehavior != nil, self.springBehavior == nil {
            var target: CGPoint = .zero
            var isMain = false
            if mainScrollView!.contentOffset.y <= 0 {
                self.dynamicItem.center = mainScrollView!.contentOffset
                target = .zero
                isMain = true
            } else if let subScrollView = self.childScrollView , subScrollView.contentOffset.y > (subScrollView.contentSize.height - subScrollView.frame.height) {
                self.dynamicItem.center = subScrollView.contentOffset
                
                target.x = subScrollView.contentOffset.x
                target.y = subScrollView.contentSize.height > subScrollView.frame.height ? (subScrollView.contentSize.height - subScrollView.frame.height) : 0
                isMain = false
            }
            
            self.animator?.removeBehavior(self.decelerationBehavior!)
            
            let springBehavior = UIAttachmentBehavior(item: self.dynamicItem, attachedToAnchor: target)
            springBehavior.length = 0
            springBehavior.damping = 1
            springBehavior.frequency = 2
            springBehavior.action = { [weak self] in
                guard let self = self else { return }
                if isMain {
                    self.mainScrollView!.contentOffset = self.dynamicItem.center
                    if self.mainScrollView!.contentOffset.y == 0 {
                        self.mainScrollViewContentOffsetIsZero()
                    }
                } else {
                    self.childScrollView?.contentOffset = self.dynamicItem.center
                }
            }
            
            self.animator?.addBehavior(springBehavior)
            self.springBehavior = springBehavior
        }
    }
    
    /* f(x, d, c) = (x * d * c) / (d + c * x)
     where,
     x – distance from the edge
     c – constant (UIScrollView uses 0.55)
     d – dimension, either width or height */

    func rubberBandDistance(offset: CGFloat, dimension: CGFloat) -> CGFloat {
        let constant: CGFloat = 0.55
        
        let result = (constant * abs(offset) * dimension) / (dimension + constant * abs(offset))
        
        return offset < 0 ? -result : result
    }
    
    func isOutsideFrame() -> Bool {
        
        if let mainScrollView = mainScrollView, mainScrollView.contentOffset.y < 0 {
            return true
        }
        guard let childScrollView = childScrollView else {
            return false
        }
        if childScrollView.contentSize.height > childScrollView.frame.height {
            return childScrollView.contentOffset.y > (childScrollView.contentSize.height - childScrollView.frame.height)
        } else {
            return childScrollView.contentOffset.y > 0
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !hasFixedMaxOffsetY, let childScrollView = self.childScrollView {
            let childCoordinate = childScrollView.convert(childScrollView.bounds, to: mainScrollView)
            if childCoordinate.minY > maxOffsetY {
                maxOffsetY = childCoordinate.minY
            }
        }
    }
    
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !(scrollView === mainScrollView || scrollView === childScrollView), self.decelerationBehavior != nil { //如果不是目标scrollview滚动的话（有可能是可横向滚动的容器滚动），就将动画取消的。
            self.animator?.removeAllBehaviors()
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gesture = gestureRecognizer as? UIPanGestureRecognizer {
            let currentX = gesture.translation(in: self.view).x
            let currentY = gesture.translation(in: self.view).y
            
            if currentY == 0 {
                return false
            } else {
                if abs(currentX) / abs(currentY) >= 5.0 {
                   return false
                } else {
                    return true
                }
            }
        }
        return false
    }
    
    
}

@objc class CustomDynamicItem: NSObject, UIDynamicItem {
    @objc var center: CGPoint = .zero
    @objc var bounds = CGRect(x: 0, y: 0, width: 1, height: 1)
    @objc var transform: CGAffineTransform = .identity
}
