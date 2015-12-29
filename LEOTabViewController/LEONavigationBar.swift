import UIKit

public class LEONavigationBar: UINavigationBar {
    let nc = NSNotificationCenter.defaultCenter()
    
    let topLayerHeight : CGFloat = 44.0
    let bottomLayerHeight : CGFloat = 46.0
    let shadowHeight : CGFloat = 1
    var buttonDim : CGFloat = 50.0
    var buttomMargin : CGFloat = 0
    var titleSeparationWithButtons : CGFloat = 8
    var bottomLayerAlphaMin : CGFloat = 0.3
    
    var statusBarLayer : UIView!
    var topLayer : UIView!
    public var bottomLayer : UIView!
    var shadowLayer : UIView!
    var leftButton : UIButton!
    var rightButton : UIButton!
    var titleLabel : UILabel!
    
    var _startTouchOffsetY : CGFloat?
    var _startTouchInsetTop : CGFloat?
    var _LasetOffsetY : CGFloat?
    var _isDraggin = false
    var _isDecelerating = false
    var _isEndDragginAnimation = false
    
    var gapAttached : Bool?
    var habilitaDespliegeRepliege : Bool?
    
    var firstTime = true
    
    //MARK: Init
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        
        SetupNavigationBar()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        SetupNavigationBar()
    }
    
    override public func sizeThatFits(size: CGSize) -> CGSize {
        let newSize = super.sizeThatFits(size)
        
        if !firstTime { return CGSizeMake(newSize.width, self.frame.height) }
        
        firstTime = false
        return CGSizeMake(newSize.width, topLayerHeight + bottomLayerHeight + shadowHeight)
    }
    
    func SetupNavigationBar() {
        self.backIndicatorImage = UIImage()
        self.shadowImage = UIImage()
        self.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.backgroundColor = UIColor.whiteColor()
        habilitaDespliegeRepliege = true
        
        registerObserver()
        buildLayouts()
    }
    
    func registerObserver() {
        nc.addObserver(self, selector: "scrollViewWillBeginDragging:", name: "LEO_scrollViewWillBeginDragging", object: nil)
        nc.addObserver(self, selector: "scrollViewDidEndDragging:", name: "LEO_scrollViewDidEndDragging", object: nil)
        nc.addObserver(self, selector: "scrollViewWillBeginDecelerating:", name: "LEO_scrollViewWillBeginDecelerating", object: nil)
        nc.addObserver(self, selector: "scrollViewDidEndDecelerating:", name: "LEO_scrollViewDidEndDecelerating", object: nil)
        nc.addObserver(self, selector: "scrollViewDidScroll:", name: "LEO_scrollViewDidScroll", object: nil)
    }
    
    func buildLayouts() {
        statusBarLayer = UIView(frame: CGRectMake(0, -20, self.frame.width, 20))
        statusBarLayer!.backgroundColor = UIColor.whiteColor()
        
        topLayer = UIView(frame: CGRectMake(0, 0, self.frame.width, topLayerHeight))
        topLayer!.backgroundColor = UIColor.whiteColor()
        
        bottomLayer = UIView(frame: CGRectMake(0, topLayer!.frame.size.height, self.frame.width, bottomLayerHeight))
        bottomLayer!.backgroundColor = UIColor.clearColor()
        
        shadowLayer = UIView(frame: CGRectMake(0, bottomLayer.frame.origin.y + bottomLayer.frame.size.height, self.frame.size.width, shadowHeight))
        shadowLayer!.backgroundColor = UIColor.lightGrayColor()
    
        leftButton = UIButton(type: UIButtonType.Custom)
        leftButton.frame = CGRectMake(buttomMargin, buttomMargin, buttonDim, buttonDim)
        leftButton.imageView?.contentMode = UIViewContentMode.Center
        leftButton.setImage(UIImage(named:"nav_bar_back"), forState: .Normal)
        leftButton.addTarget(self, action: "leftPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        rightButton = UIButton(type: UIButtonType.Custom)
        rightButton.frame = CGRectMake(self.frame.size.width - buttonDim - buttomMargin, buttomMargin, buttonDim, buttonDim)
        rightButton.imageView?.contentMode = UIViewContentMode.Center
        rightButton.addTarget(self, action: "rightPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        rightButton.hidden = true
        
        titleLabel = UILabel(frame: CGRectMake(leftButton.frame.origin.x + buttonDim + buttomMargin,
            buttomMargin,
            self.frame.size.width - 2 * buttomMargin - 2 * buttonDim - 2 * titleSeparationWithButtons,
            self.frame.size.height - 2 * buttomMargin))
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.font = UIFont(name: "ArialMT", size: 18)
        titleLabel.textColor = UIColor.darkGrayColor()
        
        navigationAddConstraints()
    }
    
    func navigationAddConstraints() {
        statusBarLayer.translatesAutoresizingMaskIntoConstraints = false
        topLayer.translatesAutoresizingMaskIntoConstraints = false
        bottomLayer.translatesAutoresizingMaskIntoConstraints = false
        shadowLayer.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(bottomLayer!)
        self.addSubview(topLayer!)
        self.addSubview(statusBarLayer!)
        self.addSubview(shadowLayer!)
        
        let viewsDictionary = ["topLayer": topLayer, "bottomLayer": bottomLayer, "statusBarLayer": statusBarLayer, "shadowLayer": shadowLayer]
        let metricsDictionary = ["topLayerWidth": topLayerHeight, "bottomLayerHeight": bottomLayerHeight, "statusBarLayerHeight": 20, "satusBarLayerYPosition": -20, "shadowHeight": shadowHeight]
        
        let constraint_H_TopLayer = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[topLayer]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary)
        
        let constraint_V_TopLayer = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[topLayer(topLayerWidth)]",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: metricsDictionary,
            views: viewsDictionary)
        
        let constraint_H_BottomLayer = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[bottomLayer]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary)
        
        let constraint_V_BottomLayerLayer = NSLayoutConstraint.constraintsWithVisualFormat("V:[bottomLayer(bottomLayerHeight)]-0-[shadowLayer(shadowHeight)]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: metricsDictionary,
            views: viewsDictionary)
        
        let constraint_H_StatusBarLayer = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[statusBarLayer]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary)
        
        let constraint_V_statusBarLayer = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(satusBarLayerYPosition)-[statusBarLayer(statusBarLayerHeight)]",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: metricsDictionary,
            views: viewsDictionary)
        
        let constraint_H_ShadowLayer = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[shadowLayer]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary)

        self.addConstraints(constraint_H_TopLayer)
        self.addConstraints(constraint_V_TopLayer)
        self.addConstraints(constraint_H_BottomLayer)
        self.addConstraints(constraint_V_BottomLayerLayer)
        self.addConstraints(constraint_H_StatusBarLayer)
        self.addConstraints(constraint_V_statusBarLayer)
        self.addConstraints(constraint_H_ShadowLayer)
        
        topLayerAddSubviewsAndConstraints()
    }
    
    func topLayerAddSubviewsAndConstraints() {
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        topLayer.addSubview(leftButton!)
        topLayer.addSubview(rightButton!)
        topLayer.addSubview(titleLabel!)
        
        let viewsDictionary = ["leftButton": leftButton, "rightButton": rightButton, "titleLabel": titleLabel]
        let metricsDictionary = ["buttomMargin": buttomMargin, "buttonDim": buttonDim, "titleSeparationWithButtons": titleSeparationWithButtons]
        
        let constraint_H_Layer = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(buttomMargin)-[leftButton(buttonDim)]-(titleSeparationWithButtons)-[titleLabel]-(titleSeparationWithButtons)-[rightButton(buttonDim)]-(buttomMargin)-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: metricsDictionary,
            views: viewsDictionary)
        
        let constraintLeftButtonCentrado = NSLayoutConstraint(
            item: topLayer,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: leftButton,
            attribute: NSLayoutAttribute.CenterY,
            multiplier: 1,
            constant: 0)
        
        let constraintLeftButtonAspectRatio = NSLayoutConstraint(
            item: leftButton,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: leftButton,
            attribute: NSLayoutAttribute.Height,
            multiplier: 1,
            constant: 0)
        
        let constraintTitleLabelCentrado = NSLayoutConstraint(
            item: topLayer,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: titleLabel,
            attribute: NSLayoutAttribute.CenterY,
            multiplier: 1,
            constant: 0)
        
        let constraintRightButtonCentrado = NSLayoutConstraint(
            item: topLayer,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: rightButton,
            attribute: NSLayoutAttribute.CenterY,
            multiplier: 1,
            constant: 0)
        
        let constraintRightButtonAspectRatio = NSLayoutConstraint(
            item: rightButton,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: rightButton,
            attribute: NSLayoutAttribute.Height,
            multiplier: 1,
            constant: 0)
        
        topLayer.addConstraints(constraint_H_Layer)
        topLayer.addConstraint(constraintLeftButtonCentrado)
        topLayer.addConstraint(constraintLeftButtonAspectRatio)
        topLayer.addConstraint(constraintTitleLabelCentrado)
        topLayer.addConstraint(constraintRightButtonCentrado)
        topLayer.addConstraint(constraintRightButtonAspectRatio)
    }
    
    //MARK: Scroll events
    func scrollViewWillBeginDragging(notif: NSNotification) {
        if _isEndDragginAnimation { return }
        guard let leoTableViewController = notif.object as? LEOTableViewController
            else { return }
        
        if self.habilitaDespliegeRepliege! && !self._isDraggin {
            self._isDraggin = true
            _startTouchOffsetY = leoTableViewController.tableView.contentOffset.y
            _LasetOffsetY = _startTouchOffsetY
            gapAttached = false
        }
    }
    
    func scrollViewDidEndDragging(notif: NSNotification) {
        if _isEndDragginAnimation { return }
        guard let leoTableViewController = notif.object as? LEOTableViewController
            else { return }
        
        self._isDraggin = false
        if self.habilitaDespliegeRepliege! && !self._isDraggin && !self._isDecelerating {
            self.mannageEndDragginScrollingTopView(leoTableViewController)
        }
    }
    
    func scrollViewWillBeginDecelerating(notif: NSNotification) {
        if _isEndDragginAnimation { return }
        guard let _ = notif.object as? LEOTableViewController
            else { return }
        
        self._isDecelerating = true
    }
    
    func scrollViewDidEndDecelerating(notif: NSNotification) {
        if _isEndDragginAnimation { return }
        guard let leoTableViewController = notif.object as? LEOTableViewController
            else { return }
        
        self._isDecelerating = false
        if self.habilitaDespliegeRepliege! && !leoTableViewController.tableView.dragging && !leoTableViewController.tableView.tracking {
            self.mannageEndDragginScrollingTopView(leoTableViewController)
        }
    }
    
    func scrollViewDidScroll(notif: NSNotification) {
        if _isEndDragginAnimation { return }
        guard let leoTableViewController = notif.object as? LEOTableViewController
            else { return }
        
        if self.habilitaDespliegeRepliege! {
            mannageHeight(leoTableViewController)
        }
        
        self.putAlphaForSectionsOfTheBar()
    }
    
    func mannageHeight(leoTableViewController : LEOTableViewController) {
        guard let _ = self._LasetOffsetY else { return }
        guard let _ = self._startTouchOffsetY else { return }

        let scrollView = leoTableViewController.tableView
        
        let maxBar = self.getBackLayerMaxHeight() + 20
        let minBar = self.getBackLayerMinHeight() + 20

        if (-scrollView.contentOffset.y < maxBar ||
            (self.frame.size.height + 20) < maxBar) && (self._isDraggin ||
            self._isDecelerating) {
            let gap = _startTouchOffsetY! - scrollView.contentOffset.y
            
            //Se entra en el if si: ya se ha entrado en este dragging, se mueve hacia arriba, o se mueve hacia bajao y se llega al gap que es el mínimo entre el propio alto de la barra abierta y el contentOfsety
            // gap <= 0 : Si e mueve hacia arriba
            // gap >= min(self.getBackLayerMaxHeight(), scrollView.contentOffset.y + self.getBackLayerMaxHeight()) : se alcanza el gap
            // gapAttached
            if (gap <= 0 ||
                gap >= min(maxBar, scrollView.contentOffset.y + maxBar) ||
                scrollView.contentSize.height < scrollView.frame.size.height ||
                scrollView.contentInset.top == minBar ||
                gapAttached!) &&
            !((-scrollView.contentOffset.y < minBar) && gap < 0 && self._isDraggin && (scrollView.contentSize.height < scrollView.frame.size.height )) {
                    
                gapAttached = true
                
                //Solo considero los offset positivos con respecto al origen marcado por el inset
                //let ofsetPositivoRespectoAlIndex = max((scrollView.contentOffset.y + scrollView.contentInset.top), 0.0)
                let delta = _LasetOffsetY! - scrollView.contentOffset.y
                let candidatoANuevoHeight = scrollView.contentInset.top + delta
                
                //El siguiente if lo pongo para que no apareza cuando rebota con el fondo de la tabla
                //Ojo con el or, es para cuando el contenido de la tabla tiene un tamaño mayor que el screen - navigationBarMaxHeight pero menor
                //que scree - navigationBarMinHeight
                let contentHeight = scrollView.contentSize.height + scrollView.contentInset.bottom
                
                if ((contentHeight - scrollView.contentOffset.y) > scrollView.frame.size.height) ||
                    ((contentHeight <= scrollView.frame.size.height - minBar) && (delta < 0)) ||
                    scrollView.contentSize.height < scrollView.frame.size.height {
                    let inset = min(maxBar, max(minBar, candidatoANuevoHeight))

                    //inset = max(inset, minBar)
                    var edgeInsets = scrollView.contentInset
                    edgeInsets.top = inset
                    leoTableViewController.scrollNotificationEnabled = false
                    scrollView.contentInset = edgeInsets
                    leoTableViewController.scrollNotificationEnabled = true

                    var rect = self.frame
                    rect.size.height = inset - 20
                    self.frame = rect
                }
            }
        }
        _LasetOffsetY = scrollView.contentOffset.y
    }
    
    func mannageEndDragginScrollingTopView(leoTableViewController : LEOTableViewController) {
        self._isEndDragginAnimation = true
        
        let scrollView = leoTableViewController.tableView
        
        let medBar = self.getBackLayerMediumHeight() + 20
        let maxBar = self.getBackLayerMaxHeight() + 20
        let minBar = self.getBackLayerMinHeight() + 20

        let delta = (scrollView.contentInset.top < medBar) ? minBar - scrollView.contentInset.top : maxBar - scrollView.contentInset.top
        var inset = scrollView.contentInset
        inset.top = inset.top + delta
        
        var offset = scrollView.contentOffset
        offset.y = offset.y - delta

        var rect : CGRect = self.frame
        rect.size.height = inset.top - 20

        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            scrollView.contentInset = inset
            scrollView.contentOffset = offset
            self.frame = rect
            self.putAlphaForSectionsOfTheBar()
            self.layoutIfNeeded() //si no pongo esto no funciona o funciona mal https://github.com/PureLayout/PureLayout/issues/82
        }) { (Bool) -> Void in
            self._isEndDragginAnimation = false
        }
    }

    func putAlphaForSectionsOfTheBar() {
        //Barra de botones
        //Lo hice con la ecuación de la recta que pasa por dos puntos (P = (alto, alpha)). Lo hice de tal menar que cuando el alto de la tabla barra está mitad => el alpha es cero
        bottomLayer.alpha = ((self.frame.size.height - self.getBackLayerMediumHeight())/(self.getBackLayerMaxHeight() - self.getBackLayerMediumHeight())) * (1 - bottomLayerAlphaMin) + bottomLayerAlphaMin
    }
    
    func getBackLayerMaxHeight() -> CGFloat {
        return getBackLayerMinHeight() + bottomLayerHeight
    }
    
    func getBackLayerMinHeight() -> CGFloat {
        return topLayerHeight + shadowHeight;
    }
    
    func getBackLayerMediumHeight() -> CGFloat {
        return getBackLayerMinHeight() + bottomLayerHeight/2
    }
}