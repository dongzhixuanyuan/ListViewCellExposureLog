//
//  CellExposureLogUtil.swift
//  ListViewCellExposureLog
//
//  Created by liudong on 2021/11/3.
//

import Foundation

public enum CellExposureLogUtil {
    /// 将一个CGRect的上下左右去除指定偏移量的值
    /// - Returns: 截取后的区域
    public static func transformRectWithEdgeInset(sourceRect: CGRect, edgeInset: UIEdgeInsets) -> CGRect {
        return CGRect(x: edgeInset.left + sourceRect.minX, y: edgeInset.top + sourceRect.minY, width: sourceRect.width-edgeInset.left-edgeInset.right, height: sourceRect.height-edgeInset.top-edgeInset.bottom)
    }
    
    /// 将Cell转化为ExposureItem
    /// - Returns: 转化后的ExposureItem
    public static func cellTransferToExposureItem<KeyType: Hashable, IndexType: Hashable>(key: KeyType, indexpath: IndexType, cell: UIView) -> ExposureItem<KeyType, IndexType>? {
        let screenRect = cell.convert(cell.bounds, to: cell.window)
        if screenRect.width > 0, screenRect.height > 0 {
            return ExposureItem(identifier: key, index: indexpath, rect: screenRect)
        }
        return nil
    }
}
