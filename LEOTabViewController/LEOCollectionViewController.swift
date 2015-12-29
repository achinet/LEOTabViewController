import UIKit

public class LEOCollectionViewController: UIViewController {
    public var collectionView : UICollectionView!
    var layout : LEOCollectionViewFlowLayout!
    public var leoNavigationBar : LEONavigationBar?
    
    public var controllers : Array <UIViewController>? {
        didSet {
            if let letControllers = controllers {
                for vc in letControllers {
                    if let leoVc = vc as? LEOTableViewController {
                        leoVc.leoNavigationBar = self.leoNavigationBar
                    }
                }
            }
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        layout = LEOCollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsetsZero
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        layout.itemSize = self.view.frame.size
        collectionView.registerClass(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "MyCell")
        self.automaticallyAdjustsScrollViewInsets = false
        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        self.collectionView.backgroundColor = UIColor.clearColor()
        
        self.view.addSubview(collectionView)
        
        self.SetupCollectionViewController()
        
        if self.navigationController?.navigationBar is LEONavigationBar {
            self.leoNavigationBar = self.navigationController?.navigationBar as? LEONavigationBar
        }
    }
    
    func SetupCollectionViewController() {
        self.navigationItem.title = nil
        self.navigationItem.hidesBackButton = true
    }
    
    public func getCurrentIndexPath() -> NSIndexPath? {
        let visibleRect = CGRect(origin: self.collectionView.contentOffset, size: self.collectionView.bounds.size)
        let visiblePoint = CGPointMake(CGRectGetMidX(visibleRect), CGRectGetMidY(visibleRect))
        return self.collectionView.indexPathForItemAtPoint(visiblePoint)
    }
}

extension LEOCollectionViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

extension LEOCollectionViewController : UICollectionViewDataSource {
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let letControllers = controllers {
            return letControllers.count
        }
        return 0
    }
  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath)
        let vc = controllers![indexPath.row]
        cell.contentView.addSubview((vc.view)!)
        cell.contentView.userInteractionEnabled = true;
        
        return cell;
    }
  public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let viewController = controllers![indexPath.row] as? LEOTableViewController {
            viewController.willDisplayCell()
        }
    }
    
    public func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        //Do nothing yet
    }
}