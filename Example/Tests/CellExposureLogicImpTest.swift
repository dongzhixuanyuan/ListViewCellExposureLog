//
//  MyCustomTest.swift
//  ListViewCellExposureLog_Tests
//
//  Created by liudong on 2021/12/1.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import ListViewCellExposureLog
import XCTest

class CellExposureLogicImpTest: XCTestCase {
    let mockTest = MockExposureCellInputer()
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        mockTest.visibleRect = CGRect(x: 50, y: 50, width: 200, height: 200) // 总的可见范围的坐标值为：(50,50,250,250)
        //        可见子View范围从(0,0,50,50),(300,300,350,350)
        let test = [0, 1, 2, 3, 4, 5, 6].map { index in
            ExposureItem<String, Int>.init(identifier: String(index), index: index, rect: CGRect(x: index * 50, y: index * 50, width: 50, height: 50))
        }
        mockTest.mockVisibleChild = test
        mockTest.calculateSignal(forceCalculate: true, delaySeconds: nil)

//      根据visibleRect和mockVisibleChild的值，预期completeVisibleItems的下标为[1,2,3,4]
        XCTAssert(mockTest.completeVisibleItems.count == 4)
        XCTAssert(mockTest.completeVisibleItems.filter { item in
            item.index == 1
        }.count == 1)
        XCTAssert(mockTest.completeVisibleItems.filter { item in
            item.index == 2
        }.count == 1)
        XCTAssert(mockTest.completeVisibleItems.filter { item in
            item.index == 3
        }.count == 1)
        XCTAssert(mockTest.completeVisibleItems.filter { item in
            item.index == 4
        }.count == 1)
        XCTAssert(mockTest.completeVisibleItems.filter { item in
            item.index == 5
        }.count == 0)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
