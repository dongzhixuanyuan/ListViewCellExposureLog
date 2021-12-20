//
//  ExposureCellInputer.swift
//  ListViewCellExposureLog
//
//  Created by liudong on 2021/10/30.
//

import Foundation

public protocol ExposureCellInputer: class {
    associatedtype KeyType: Hashable
    associatedtype IndexType: Hashable
    var visibleRect: CGRect { get set }
    var extraEdgeInset: UIEdgeInsets? { get set } /// 视图部分有被遮挡的区域的top、left、right、bottom，暂时只支持矩形边缘区域被遮挡，不支持中间区域被遮挡。

    func curVisibleItems() -> [ExposureItem<KeyType, IndexType>]

    func calculateSignal(forceCalculate: Bool, delaySeconds: Double?)
}

/// 为了解决"Swift-Generics: "Cannot specialize non-generic type"问题，不能直接使用带泛型的 ExposureCellInputer Protocol
/// 通过下面的两个包装类来擦除泛型来达到使用目的。
open class ExposureCellInputerTemplate<KeyType: Hashable, IndexType: Hashable>: ExposureCellInputer {
    public var visibleRect: CGRect
    public var extraEdgeInset: UIEdgeInsets?
    init() {
        visibleRect = .zero
    }

    public func curVisibleItems() -> [ExposureItem<KeyType, IndexType>] {
        fatalError()
    }

    public func calculateSignal(forceCalculate: Bool, delaySeconds: Double?) {
        fatalError()
    }
}

public class ExposureCellInputerWrapper<Input: ExposureCellInputer>: ExposureCellInputerTemplate<Input.KeyType, Input.IndexType> {
    /// 需要[weak]修饰，传进来的实现类引用链：[CellExposureLogicImp]->[ExposureCellInputerWrapper]->[input].不使用weak，会导致循环引用
    weak var input: Input?

    init(_ input: Input) {
        self.input = input
    }

    override public var visibleRect: CGRect {
        get {
            return self.input?.visibleRect ?? .zero
        }
        set {
            self.input?.visibleRect = newValue
        }
    }

    override public var extraEdgeInset: UIEdgeInsets? {
        get {
            return self.input?.extraEdgeInset
        }
        set {
            self.input?.extraEdgeInset = newValue
        }
    }

    override public func curVisibleItems() -> [ExposureItem<Input.KeyType, Input.IndexType>] {
        return self.input?.curVisibleItems() ?? []
    }

    override public func calculateSignal(forceCalculate: Bool, delaySeconds: Double?) {
        self.input?.calculateSignal(forceCalculate: forceCalculate, delaySeconds: delaySeconds)
    }
}

public extension ExposureCellInputerTemplate {
    static func make<Input: ExposureCellInputer>(_ input: Input) -> ExposureCellInputerTemplate<KeyType, IndexType> where KeyType == Input.KeyType, IndexType == Input.IndexType {
        return ExposureCellInputerWrapper<Input>.init(input)
    }
}
