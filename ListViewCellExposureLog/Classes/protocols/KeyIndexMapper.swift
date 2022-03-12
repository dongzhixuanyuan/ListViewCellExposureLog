//
//  KeyIndexMapper.swift
//  ListViewCellExposureLog
//
//  Created by liudong on 2021/11/11.
//

import Foundation
import UIKit

/// 将ScrollView中卡片的Index转为数据项的唯一标识符
public protocol KeyIndexMapper: class {
    associatedtype KeyType: Hashable
    associatedtype IndexType: Hashable

    /// View的下标转化为唯一标识符Key
    /// - Returns: 唯一标识符
    func indexMapToKey(index: IndexType) -> KeyType?
}

open class KeyIndexMapperTemplate<KeyType: Hashable, IndexType: Hashable>: KeyIndexMapper {
    public func indexMapToKey(index: IndexType) -> KeyType? {
        fatalError()
    }
}

public final class KeyIndexMapperWrapper<Mapper: KeyIndexMapper>: KeyIndexMapperTemplate<Mapper.KeyType, Mapper.IndexType> {
    weak var mapper: Mapper?

    init(_ mapper: Mapper) {
        self.mapper = mapper
    }

    override public func indexMapToKey(index: Mapper.IndexType) -> Mapper.KeyType? {
        guard self.mapper != nil else {
            return nil
        }
        return self.mapper!.indexMapToKey(index: index)
    }
}

public extension KeyIndexMapperTemplate {
    static func make<Mapper: KeyIndexMapper>(_ mapper: Mapper) -> KeyIndexMapperTemplate<KeyType, IndexType> where Mapper.KeyType == KeyType, Mapper.IndexType == IndexType {
        return KeyIndexMapperWrapper<Mapper>.init(mapper)
    }
}

public extension KeyIndexMapper {
    func indexMapToKey(index: Int) -> Int? {
        return index
    }

    func indexMapToKey(index: IndexPath) -> IndexPath? {
        return index
    }
}
