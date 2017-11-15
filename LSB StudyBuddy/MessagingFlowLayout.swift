//
//  MessagingFlowLayout.swift
//  Clinical Study Buddy
//
//  Created by Yong Lu on 6/15/17.
//  Copyright © 2017 Abbey Thorpe. All rights reserved.
//  Copyright © 2016,2017 Yong Lu. All rights reserved.
//

import UIKit

class MessagingFlowLayout: UICollectionViewFlowLayout {
    //var currentCellPath: NSIndexPath?
    //var currentCellCenter: CGPoint?
    //var currentCellScale: CGFloat?
    //
    //func setCurrentCellScale(scale: CGFloat)
    //{
    //    currentCellScale = scale
    //    self.invalidateLayout()
    //}
    //
    //func setCurrentCellCenter(origin: CGPoint)
    //{
    //    currentCellCenter = origin
    //    self.invalidateLayout()
    //}
    //
    //override func layoutAttributesForItemAtIndexPath(indexPath:
    //    NSIndexPath) -> UICollectionViewLayoutAttributes {
    //        
    //        let attributes =
    //        super.layoutAttributesForItemAtIndexPath(indexPath)
    //        
    //        //self.modifyLayoutAttributes(attributes)
    //        return attributes!
    //}
    
    //let itemWidth: CGFloat = 50
    var cellSizes: [CGSize]!
    var xPosArray: [CGFloat] = []
    var yPosArray: [CGFloat] = []
    //let itemWidth: CGFloat = 200
    let itemSpacing: CGFloat = 10
    var layoutInfo: [NSIndexPath:UICollectionViewLayoutAttributes] = [NSIndexPath:UICollectionViewLayoutAttributes]()
    var maxXPos: CGFloat = 0
    
    override init() {
        super.init()
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    func setup() {
        // setting up some inherited values
        //self.itemSize = CGSizeMake(itemWidth, itemWidth)
        self.minimumInteritemSpacing = itemSpacing
        self.minimumLineSpacing = itemSpacing
        //self.scrollDirection = UICollectionViewScrollDirection.Horizontal
        self.scrollDirection = UICollectionViewScrollDirection.Vertical
    }
    
    override func prepareLayout() {
        layoutInfo = [NSIndexPath:UICollectionViewLayoutAttributes]()
        for var i = 0; i < self.collectionView?.numberOfItemsInSection(0); i += 1 {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            let itemAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            itemAttributes.frame = frameForItemAtIndexPath(indexPath)
            if itemAttributes.frame.origin.x > maxXPos {
                maxXPos = itemAttributes.frame.origin.x
            }
            layoutInfo[indexPath] = itemAttributes
        }
    }
    
    func frameForItemAtIndexPath(indexPath: NSIndexPath) -> CGRect {
        let itemWidth = cellSizes[indexPath.item].width
        let itemHeight = cellSizes[indexPath.item].height
        //let maxHeight = self.collectionView!.frame.height - 20
        //let numRows = floor((maxHeight+self.minimumLineSpacing)/(itemWidth+self.minimumLineSpacing))
        //let numRows = CGFloat((self.collectionView?.numberOfItemsInSection(0))!)
        
        //let currentColumn = floor(CGFloat(indexPath.row)/numRows)
        //let currentColumn = 0
        let currentRow = CGFloat(indexPath.row)
        
        var xPos:CGFloat = 0.0
        let viewSize = self.collectionView!.frame.size
        let defaultXpos = viewSize.width / 2
        //if( currentRow % 2 == 0) {
        if let cell = self.collectionView!.cellForItemAtIndexPath(indexPath) as? MessagingCollectionViewCell
        {
          if( cell.backgroundColor == self.collectionView!.tintColor) {
             //xPos = currentColumn*(itemWidth+self.minimumInteritemSpacing)+itemWidth*0.25
             //xPos = itemWidth*0.5
             xPos =  viewSize.width - itemWidth - 10
          } else {
             //xPos = currentColumn*(itemWidth+self.minimumInteritemSpacing)
             xPos = 10
          }
        } else {
            xPos = defaultXpos
        }
        //let yPos = currentRow*(itemHeight+self.minimumLineSpacing)+10
        var yPos:CGFloat = 0.0
        for i in 0 ..< indexPath.item {
            yPos = yPos + cellSizes[i].height + 10
        }
        
        if xPosArray.count > indexPath.item {
            if xPosArray[indexPath.item] != defaultXpos {
               xPos = xPosArray[indexPath.item]
               //yPos = yPosArray[indexPath.item]
               yPosArray[indexPath.item] = yPos
            } else {
               xPosArray[indexPath.item] = xPos
               yPosArray[indexPath.item] = yPos
            }                            
        } else {
            xPosArray.appendContentsOf([xPos])
            yPosArray.appendContentsOf([yPos])
       
        }
        
        let rect: CGRect = CGRectMake(xPos, yPos, itemWidth, itemHeight)
        return rect
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutInfo[indexPath]
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var allAttributes: [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
        
        for (indexPath, attributes) in layoutInfo {
            if CGRectIntersectsRect(rect, attributes.frame) {
                allAttributes.append(attributes)
            }
        }
        
        return allAttributes
    }
    
    override func collectionViewContentSize() -> CGSize {
        //let collectionViewHeight = self.collectionView!.frame.height
        let last = yPosArray.count - 1
        var collectionViewHeight = self.collectionView!.frame.height
        if last > 0 {
            collectionViewHeight = yPosArray[last] + cellSizes[last].height
        }
        //let contentWidth: CGFloat = maxXPos + itemWidth
        let contentWidth: CGFloat = self.collectionView!.frame.width
        
        return CGSizeMake(contentWidth, collectionViewHeight)
    }

}
