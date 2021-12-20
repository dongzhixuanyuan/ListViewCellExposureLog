//
//  ExposureItem.swift
//  ListViewCellExposureLog
//
//  Created by liudong on 2021/10/30.
//

import Foundation
import UIKit

/// 被曝光的数据项。将每个曝光的卡片认为是一个数据项曝光了，而不是认为是某个View曝光。
/// 如果将View作为曝光项（就是以View绑定的数据在 数据集合中的位置作为唯一标识符），带来的问题点是当更新数据集合中某个位置的数据后，需要额外处理当前已经缓存的标识符集合，这种操作包括删除某个数据，更新某一段数据，或者在中间插入某些数据。这样针对不同的数据操作方式，曝光计算类需要做出不同的行为。太过复杂，且容易出错。
/// 当把曝光项定义为数据项后，就避免了上述问题。但是劣势是需要额外引入一个接口，用来将下标转化为唯一标识符。
public struct ExposureItem<Key: Hashable, Index: Hashable>: Hashable {
    private let identifier: Key // 数据项标识符
    private let index: Index //  数据项在数据集合中的索引。其实即使不加这个属性也能基本满足需求，因为可以根据identifier来找到曝光数据。但是用这个index可以指定位置查找，提高效率。
    let rect: CGRect // 卡片View在屏幕中的rect
    let typeCombine: KeyIndexCompose<Key, Index>

    public init(identifier: Key, index: Index, rect: CGRect) {
        self.identifier = identifier
        self.index = index
        self.rect = rect
        self.typeCombine = KeyIndexCompose(identifier: identifier, index: index)
    }

    public static func == (lhs: ExposureItem<Key, Index>, rhs: ExposureItem<Key, Index>) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

/// 数据标识符和数据在集合中的下标的组合类
public class KeyIndexCompose<Key: Hashable, Index: Hashable>: Hashable {
    public let identifier: Key // 数据项标识符
    public let index: Index //  数据项在SuperView中的索引
    public init(identifier: Key, index: Index) {
        self.identifier = identifier
        self.index = index
    }

    public static func == (lhs: KeyIndexCompose<Key, Index>, rhs: KeyIndexCompose<Key, Index>) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    public func toString() -> String {
        return "{index:\(index),identifier:\(identifier)}"
    }
    
}

public enum DataChangeType {
    case AddOrSetData // 添加或者设置数据
    case ClearAndSetData // 清空现在所有数据，并更新
    case UpdateRangeData // 更新部分数据
}


/// 更新数据后，重新查找当前曝光Cell的延时
public let DELAYTIME_FOR_DATA_CHANGE_CALCULATE = 0.5
/// UI布局更新后，重新查找曝光Cell延时
public let DELAYTIME_FOR_UI_FRAME_CHANGE = 0.25
