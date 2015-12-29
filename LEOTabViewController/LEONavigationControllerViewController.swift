import UIKit

public class LEONavigationController: UINavigationController {
    public var lEONavigationBar : LEONavigationBar? = nil
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        SetupNavigationController()
    }
    
    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        
        SetupNavigationController()
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        SetupNavigationController()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        SetupNavigationController()
    }
    
    func SetupNavigationController() {
        lEONavigationBar = LEONavigationBar()
        self.setValue(lEONavigationBar, forKey: "navigationBar")
    }
}
