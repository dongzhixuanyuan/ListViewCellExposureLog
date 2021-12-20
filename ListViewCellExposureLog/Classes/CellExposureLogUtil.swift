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
}
