
import Foundation

/// UIScrollView跟UITableview和UICollectionview曝光有个区别，tablewview和collectionview都是以cell为单位进行曝光计算的，但是UIScrollview对哪些View曝光计算是需要自己定义的
open class CellExposureLogUIScrollView<KeyType: Hashable>: UIScrollView, ExposureCellInputer, ExposureCellOutputer,KeyIndexMapper {
    
    public typealias KeyType = KeyType
    
    public typealias IndexType = Int
    
    /// 需要进行曝光统计的指定View.
    open var exposureCalculateViews: [UIView]? {
        fatalError("必须复写")
    }
    public var exposureOutputerDelegate: ExposureCellOutputerTemplate<KeyType, IndexType>?
    public var keyIndexMapper: KeyIndexMapperTemplate<KeyType, IndexType>?

    private var cellExposureCalculator: CellExposureLogicImp<KeyType, IndexType>?
    private var viewPropertyObserver:UIViewPropertyObserver<KeyType,IndexType>?

    private var isAttached = false
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.cellExposureCalculator = CellExposureLogicImp(realImp: self)
        self.viewPropertyObserver = UIViewPropertyObserver.init(view: self, input: self)
    }
    
    /// Must override
    open func indexMapToKey(index: IndexType) -> KeyType? {
        if keyIndexMapper != nil {
            return keyIndexMapper!.indexMapToKey(index: index)
        }
        if index is KeyType {
            return index as? KeyType
        }
        fatalError("如果未设置keyIndexMapper代理，并且IndexType和KeyType类型不一致，则必须复写该函数")    }
    
//    MARK: ExposureCellInputer Delegate

    open var extraEdgeInset: UIEdgeInsets?
        
    open func curVisibleItems() -> [ExposureItem<KeyType,IndexType>] {
       return exposureCalculateViews?.enumerated().compactMap({ iterator in
            if let key = indexMapToKey(index: iterator.offset) {
                return CellExposureLogUtil.cellTransferToExposureItem(key: key, indexpath: iterator.offset, cell: iterator.element)
            }
            return nil
        }) ?? []
    }
    
    open func calculateSignal(forceCalculate: Bool, delaySeconds: Double?) {
        if isAttached {
            self.cellExposureCalculator?.calculateItemExposureWithDelay(forceCalculate: forceCalculate, delaySeconds: delaySeconds)
        }
    }
    
//    MARK: ExposureCellOutputer Delegate

    open var customExposureRatio: Double?
    
    open func outputCompleteVisibleItems(items: Set<KeyIndexCompose<KeyType, IndexType>>) {
        self.exposureOutputerDelegate?.outputCompleteVisibleItems(items: items)
    }

    open func outputPartVisibleItems(items: Set<KeyIndexCompose<KeyType, IndexType>>) {
        self.exposureOutputerDelegate?.outputPartVisibleItems(items: items)
    }

    open func outputCustomExposureRatioItems(items: Set<KeyIndexCompose<KeyType, IndexType>>) {
        self.exposureOutputerDelegate?.outputCustomExposureRatioItems(items: items)
    }
    
    open func currentExposureItems(partVisibleItems: Set<KeyIndexCompose<KeyType, IndexType>>, completeVisibleItems: Set<KeyIndexCompose<KeyType, IndexType>>, customExposureRatioVisibleItems: Set<KeyIndexCompose<KeyType, IndexType>>, curVisibleRect: CGRect) {
        self.exposureOutputerDelegate?.currentExposureItems(partVisibleItems: partVisibleItems, completeVisibleItems: completeVisibleItems, customExposureRatioVisibleItems: customExposureRatioVisibleItems, curVisibleRect: curVisibleRect)
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        isAttached = (newSuperview != nil)
    }
   
    open override func didMoveToWindow() {
        isAttached = (self.window != nil)
        if isAttached {
            viewPropertyObserver?.addSuperviewScrollObserver()
            calculateSignal(forceCalculate: true, delaySeconds: DELAYTIME_FOR_UI_FRAME_CHANGE)
        } else {
            viewPropertyObserver?.removeSuperUIScrollViewObserver()
            cellExposureCalculator?.resetReportedVisibleItems()
        }
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("CellExposureLogUIScrollView::init(coder:) has not been implemented")
    }
    
    deinit {
//        debugPrint("CellExposureLogUIScrollView::deinit")
    }
}
