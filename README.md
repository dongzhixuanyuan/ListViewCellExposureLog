# ListViewCellExposureLog

[![CI Status](https://img.shields.io/travis/liudong/ListViewCellExposureLog.svg?style=flat)](https://travis-ci.org/liudong/ListViewCellExposureLog)
[![Version](https://img.shields.io/cocoapods/v/ListViewCellExposureLog.svg?style=flat)](https://cocoapods.org/pods/ListViewCellExposureLog)
[![License](https://img.shields.io/cocoapods/l/ListViewCellExposureLog.svg?style=flat)](https://cocoapods.org/pods/ListViewCellExposureLog)
[![Platform](https://img.shields.io/cocoapods/p/ListViewCellExposureLog.svg?style=flat)](https://cocoapods.org/pods/ListViewCellExposureLog)

## Example
支持的需求场景，UIScrollview及其子类在滚动时，需要曝光其中出现的Cell或者子View，可支持子View部分曝光上报，子View完整曝光上报，自定义曝光比例上报。  

1、内置支持UITableview、UICollectionview、UIScrollview、UIScrollviewCollectionKit的CollectView。  
2、另一种比较特殊的场景，某个UIView作为一个容器，在UIScrollview中滚动，需要曝光统计该UIView容器中的子View.  
3、支持嵌套UIScrollview的曝光，譬如UIScrollview A中包含一个SubView UIScrollview B，如果需要统计B中的子View曝光情况。  
如果UIView已经继承了其他基类，不能多继承曝光基类，也可以参照基类代码实现库中的`ExposureCellInputer`和`ExposureCellOutputer`接口即可。

下面以UITableview为例。继承CellExposureLogUITableView,并根据需要override对应的ouput回调函数即可。  
如下方式适用于，tableview的数据定义在CustomUITableView内部的情况，这样可以直接回调输出当前曝光的卡片。
```
class CustomUITableView: CellExposureLogUITableView<String> {
    var testData = [Int]()

<!-- 这个一般返回数据的唯一id，跟选择的泛型类型匹配即可 -->
    override func indexMapToKey(index: CellExposureLogUITableView<String>.IndexType) -> String {
        return String(testData[index.row])
    }

    override func outputCompleteVisibleItems(items: Set<KeyIndexCompose<String, CellExposureLogUITableView<String>.IndexType>>) {
        super.outputCompleteVisibleItems(items: items)
    }

    override func outputPartVisibleItems(items: Set<KeyIndexCompose<String, CellExposureLogUITableView<String>.IndexType>>) {
        super.outputPartVisibleItems(items: items)
    }

    override func outputCustomExposureRatioItems(items: Set<KeyIndexCompose<String, CellExposureLogUITableView<String>.IndexType>>) {
        super.outputCustomExposureRatioItems(items: items)
    }
}
```
如果数据不在CustomUITableview内部，那么可以通过添加delegate的方式来获取曝光卡片的结果。
```
class CustomUITableView: CellExposureLogUITableView {

}

class SomeXXXViewController:ExposureCellOutputer,KeyIndexMapper {
    typealias KeyType = String
    typealias IndexType = IndexPath
    lazy var tableView: CellExposureLogUITableView<String> = {
        let view = CellExposureLogUITableView<String>.init()
        <!--需要设置outputer和KeyIndexMapper代理-->
        view.exposureOutputerDelegate = ExposureCellOutputerTemplate.make(self)
        view.keyIndexMapper = KeyIndexMapperTemplate.make(self)
        self.view.addSubview(view)
        return view
    }()

    func indexMapToKey(index: IndexPath) -> String? {
           return "\(index.section),\(index.row)"
    }

   func outputCompleteVisibleItems(items: Set<KeyIndexCompose<String, IndexPath>>) {
       debugPrint("\(TAG)::outputCompleteVisibleItems::\(items)")
   }

   func outputPartVisibleItems(items: Set<KeyIndexCompose<String, IndexPath>>) {
       debugPrint("\(TAG)::outputPartVisibleItems::\(items)")
   }

   func outputCustomExposureRatioItems(items: Set<KeyIndexCompose<String, IndexPath>>) {
       debugPrint("\(TAG)::outputCustomExposureRatioItems::\(items)")
   }
}
```
这些曝光View的contentoffset变化，父容器的contentoffset变化，Frame变换，约束更新，transform更新，会重新曝光卡片；  
CellExposureLogUITableView,CellExposureLogUICollectionView,CellExposureLogCollectKitCollectView复写了reloadData函数，当更新数据时，会自动触发曝光计算。CellExposureLogUIScrollView和CellExposureLogUIView，当数据更新后，需要手动调用calculateSignal(forceCalculate: Bool, delaySeconds: Double?)函数来触发曝光统计。

## Architecture

![Image text](https://raw.githubusercontent.com/dongzhixuanyuan/ListViewCellExposureLog/main/images/architecture_UML.jpg)

## Requirements

## Installation

ListViewCellExposureLog is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ListViewCellExposureLog'
```

## Author

liudong, 735106520@qq.com

## License

ListViewCellExposureLog is available under the MIT license. See the LICENSE file for more info.
