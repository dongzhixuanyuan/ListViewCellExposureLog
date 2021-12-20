//
//  ExposureCellOutputer.swift
//  ListViewCellExposureLog
//
//  Created by liudong on 2021/10/30.
//

import Foundation

public protocol ExposureCellOutputer: class {
    associatedtype KeyType: Hashable // 曝光卡片对应的标识符
    associatedtype IndexType: Hashable
    var customExposureRatio: Double? { get set } // 自定义卡片曝光面积占卡片面积的百分比。譬如0.5,就表示卡片曝光二分之一就会塞到[outputCustomExposureRatioItems]中

    /// 卡片完全展示时上报
    /// 当卡片完全移除屏幕后，再移回屏幕并且完全展示时，会重新上报。在屏幕内上下移动，只要没有完全消失，不会重新上报。
    /// - Parameter items: 新添加的完全展示的KeyType集合
    func outputCompleteVisibleItems(items: Set<KeyIndexCompose<KeyType, IndexType>>)
    /// 上报可见的Item（包括完全可见和不完全可见）
    /// 当卡片完全移除屏幕后，再移回屏幕并且部分展示时，会重新上报。在屏幕内上下移动，只要没有完全消失，不会重新上报。
    /// - Parameter items: 新添加的部分展示的KeyType集合
    func outputPartVisibleItems(items: Set<KeyIndexCompose<KeyType, IndexType>>)

    /// 自定义曝光百分比的Item
    /// 当卡片完全移除屏幕后，再移回屏幕并且达到曝光比例时，会重新上报。在屏幕内上下移动，只要没有完全消失，不会重新上报。
    /// - Parameter items: 新添加的达到曝光比例的KeyType集合
    func outputCustomExposureRatioItems(items: Set<KeyIndexCompose<KeyType, IndexType>>)
}

open class ExposureCellOutputerTemplate<KeyType: Hashable, IndexType: Hashable>: ExposureCellOutputer {
    public var customExposureRatio: Double?

    public func outputCustomExposureRatioItems(items: Set<KeyIndexCompose<KeyType, IndexType>>) {
        fatalError()
    }

    public func outputCompleteVisibleItems(items: Set<KeyIndexCompose<KeyType, IndexType>>) {
        fatalError()
    }

    public func outputPartVisibleItems(items: Set<KeyIndexCompose<KeyType, IndexType>>) {
        fatalError()
    }
}

final class ExposureCellOutputerTemplateWrapper<Output: ExposureCellOutputer>: ExposureCellOutputerTemplate<Output.KeyType, Output.IndexType> {
    weak var delegate: Output?

    init(_ realDelegate: Output) {
        self.delegate = realDelegate
    }

    override var customExposureRatio: Double? {
        get {
            self.delegate?.customExposureRatio
        }
        set {
            self.delegate?.customExposureRatio = newValue
        }
    }

    override func outputPartVisibleItems(items: Set<KeyIndexCompose<KeyType, IndexType>>) {
        self.delegate?.outputPartVisibleItems(items: items)
    }

    override func outputCompleteVisibleItems(items: Set<KeyIndexCompose<KeyType, IndexType>>) {
        self.delegate?.outputCompleteVisibleItems(items: items)
    }

    override func outputCustomExposureRatioItems(items: Set<KeyIndexCompose<KeyType, IndexType>>) {
        self.delegate?.outputCustomExposureRatioItems(items: items)
    }
}

public extension ExposureCellOutputerTemplate {
    static func make<Output: ExposureCellOutputer>(_ realDelegate: Output) -> ExposureCellOutputerTemplate<KeyType, IndexType> where KeyType == Output.KeyType, IndexType == Output.IndexType {
        return ExposureCellOutputerTemplateWrapper<Output>.init(realDelegate)
    }
}
