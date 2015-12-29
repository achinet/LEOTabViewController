import UIKit

class LEOCollectionViewFlowLayout : UICollectionViewFlowLayout {
    
    func pageWidth() -> CGFloat {
        return self.collectionView!.bounds.size.width
    }
    
    override func targetContentOffsetForProposedContentOffset(var proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let rawPageValue = self.collectionView!.contentOffset.x / self.pageWidth()
        let currentPage = (velocity.x > 0.0) ? floor(rawPageValue) : ceil(rawPageValue)
        let nextPage = (velocity.x > 0.0) ? ceil(rawPageValue) : floor(rawPageValue)
        
        let pannedLessThanAPage = fabs(1 + currentPage - rawPageValue) > 0.5
        let flicked = fabs(velocity.x) > self.flickVelocity()
        if pannedLessThanAPage && flicked {
            proposedContentOffset.x = nextPage * self.pageWidth();
        } else {
            proposedContentOffset.x = round(rawPageValue) * self.pageWidth();
        }
        
        proposedContentOffset.y = 0
        
        return proposedContentOffset;
    }
    
    func flickVelocity() -> CGFloat {
        return 0.2
    }
}
