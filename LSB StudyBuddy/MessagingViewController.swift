//
//  MessagingViewController.swift
//  Clinical Study Buddy
//
//  Created by Yong Lu on 6/15/17.
//  Copyright © 2017 Abbey Thorpe. All rights reserved.
//  Copyright © 2016,2017 Yong Lu. All rights reserved.
//

import Foundation
import UIKit

class MessagingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout //, UITextViewDelegate
{
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    @IBOutlet weak var msgCollectionView: UICollectionView!
    @IBOutlet weak var msgInputBox: UITextView!
    @IBOutlet var topmostView: UIView!
    @IBOutlet weak var vStackView: UIStackView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    let reuseCellID = "msgCell"
    //var cellSizes: [CGSize]!
    var messages : [Message] = []
    var refresher:UIRefreshControl!
    var myAwesomeCells = [
        "Lorem ipsum dolor sit amet.",
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed massa leo, mollis id tortor at posuere.",
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque semper vitae mi vel hendrerit. Suspendisse et feugiat mi. Donec quis sollicitudin quam, non porttitor nulla. Phasellus in luctus lorem, sed auctor enim. Suspendisse potenti. Ut maximus pharetra diam, ac laoreet est dignissim eu nullam.",
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque semper vitae mi vel hendrerit. Suspendisse et feugiat mi. Donec quis sollicitudin quam, non porttitor nulla. Phasellus in luctus lorem, sed auctor enim. Suspendisse potenti. Ut maximus pharetra diam, ac laoreet est dignissim eu nullam.",
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque semper vitae mi vel hendrerit. Suspendisse et feugiat mi. Donec quis sollicitudin quam, non porttitor nulla. Phasellus in luctus lorem, sed auctor enim. Suspendisse potenti. Ut maximus pharetra diam, ac laoreet est dignissim eu nullam.",
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque semper vitae mi vel hendrerit. Suspendisse et feugiat mi. Donec quis sollicitudin quam, non porttitor nulla. Phasellus in luctus lorem, sed auctor enim. Suspendisse potenti. Ut maximus pharetra diam, ac laoreet est dignissim eu nullam.",
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque semper vitae mi vel hendrerit. Suspendisse et feugiat mi. Donec quis sollicitudin quam, non porttitor nulla. Phasellus in luctus lorem, sed auctor enim. Suspendisse potenti. Ut maximus pharetra diam, ac laoreet est dignissim eu nullam.",
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque semper vitae mi vel hendrerit. Suspendisse et feugiat mi. Donec quis sollicitudin quam, non porttitor nulla. Phasellus in luctus lorem, sed auctor enim. Suspendisse potenti. Ut maximus pharetra diam, ac laoreet est dignissim eu nullam.",
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque semper vitae mi vel hendrerit. Suspendisse et feugiat mi. Donec quis sollicitudin quam, non porttitor nulla. Phasellus in luctus lorem, sed auctor enim. Suspendisse potenti. Ut maximus pharetra diam, ac laoreet est dignissim eu nullam.",
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque semper vitae mi vel hendrerit. Suspendisse et feugiat mi. Donec quis sollicitudin quam, non porttitor nulla. Phasellus in luctus lorem, sed auctor enim. Suspendisse potenti. Ut maximus pharetra diam, ac laoreet est dignissim eu nullam."
    ]

    var myLayout: MessagingFlowLayout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refresher = UIRefreshControl()
        self.msgCollectionView!.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.redColor()
        self.refresher.addTarget(self, action: #selector(MessagingViewController.handleRefresh(_:)), forControlEvents: .ValueChanged)
        self.msgCollectionView!.addSubview(refresher)
        myLayout = MessagingFlowLayout()
        myLayout!.cellSizes = messages.map({
            (msg:Message)-> CGSize in
            // set default size to 1,1, so it doesn't look awful when resizing the first time
            return CGSize(width: 1, height: 1)
        })
        
        
        msgCollectionView.setCollectionViewLayout(myLayout!, animated: true)

        msgCollectionView!.dataSource = self
        msgCollectionView!.delegate = self
        //msgCollectionView!.registerClass(MessagingCollectionViewCell.self, forCellWithReuseIdentifier: "msgCell")
        msgCollectionView!.clearsContextBeforeDrawing = true
        msgCollectionView!.backgroundColor = UIColor.whiteColor()
        self.automaticallyAdjustsScrollViewInsets = false
       // self.msgCollectionView.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
       // 
        //self.view.addSubview(msgCollectionView!)
        //if let flowLayout = msgCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
        //    flowLayout.estimatedItemSize = CGSizeMake(1, 1)
        //}
        
        // Gives the size array an initial value since collectionView:layout:sizeForItemAtIndexPath
        // is called before collectionView:cellForItemAtIndexPath
        
        backgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
            UIApplication.sharedApplication().endBackgroundTask(self.backgroundTaskIdentifier!)
        })
        var timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(MessagingViewController.update), userInfo: nil, repeats: true)

        // // TODO: when should I scroll to bottom?
        // if(true) {
        //     let lastItemIndex = NSIndexPath(forItem: myAwesomeCells.count-1, inSection: 0)
        //     msgCollectionView.scrollToItemAtIndexPath(lastItemIndex, atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
        // }
        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.keyboardWasShown),
                                                         name: UIKeyboardDidShowNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillBeHidden), name: UIKeyboardDidHideNotification, object: nil)

    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottomConstraint.constant = keyboardFrame.size.height + 2
        })
    }
    func keyboardWillBeHidden(notification: NSNotification) {
        //let info = notification.userInfo!
        //let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottomConstraint.constant = 0
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        update(true)
    }
    
    
    func update(forceScrollToBottom:Bool) {
        print("Something cool")
        let delegate = ApiRequestDelegate()
        delegate.getMessagesForUserEmail(User.email!, since: 0) {
            (success, messages) in
            if(success){
                //if messages.count > self.messages.count {
                //let oldCount = self.messages.count
                //let newCount = messages.count
                self.messages = messages
                // self.sortEvents()
                // UIApplication.sharedApplication().cancelAllLocalNotifications()
                // self.createReminders()
                // //self.tableView.rowHeight = UITableViewAutomaticDimension
                // //self.tableView.estimatedRowHeight = 160.0
                if let layout = self.myLayout {
                    if(messages.count < layout.cellSizes.count) {
                        // why does it happen?
                      layout.cellSizes = []
                    }
                  for _ in layout.cellSizes.count ..< messages.count {
                      layout.cellSizes.append(CGSize(width: 1, height: 1))
                  }
                }
                self.msgCollectionView.reloadData()  // notify tableView to reload data
                print(String(format:"Number of messages loaded: %d",self.messages.count))
                // if(events.count>0) {
                //     self.formatTable()
                // }
                //}
                self.tryScrollToBottom(forceScrollToBottom)
                
                self.activityIndicatorView.stopAnimating()
                //dispatch_async(dispatch_get_main_queue(), {
                //    //self.msgCollectionView.setContentOffset(CGPointMake(0, CGFloat.max), animated: true)
                //})
            }
        }
    }
    
    func tryScrollToBottom(forceScrollToBottom:Bool) {
        let isScrolling = (self.msgCollectionView.dragging || self.msgCollectionView.decelerating)
        if !isScrolling {
          let oldLastRow = self.messages.count - 2
          let indexPath1 = NSIndexPath(forRow: oldLastRow, inSection: 0)
          let indexPath2 = NSIndexPath(forRow: oldLastRow+1, inSection: 0)
          //
          let oldLastFrame =
                self.msgCollectionView.collectionViewLayout.layoutAttributesForItemAtIndexPath(indexPath1)
          var toScroll = forceScrollToBottom
          if !toScroll {
            if let y = oldLastFrame?.frame.maxY {
              print(String(format:"update: old last row is %d:", oldLastRow), y, self.msgCollectionView.contentOffset.y, self.msgCollectionView.contentSize)
              toScroll = (y > self.msgCollectionView.contentOffset.y) && (y < self.msgCollectionView.contentOffset.y +
                  UIScreen.mainScreen().bounds.height)
            }
          }
          
              
          if toScroll {
                  dispatch_async(dispatch_get_main_queue(), {
                      self.msgCollectionView.scrollToItemAtIndexPath(indexPath2, atScrollPosition: .Bottom, animated: true)
                  })
          }
        }
    
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Now that the collection view has appeared, then all the cells have been initialized
        // with their appropiate content. The view should then be reloaded with the newly
        // calculated sizes as well.
        msgCollectionView.reloadData()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        msgCollectionView.reloadData()
        self.myLayout!.invalidateLayout()
        msgCollectionView.layoutIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        let delegate = ApiRequestDelegate()
        delegate.getMessagesForUserEmail(User.email!, since: 0) {
           (success, messages) in
            if(success){
                self.messages = messages
                //self.sortEvents()
                //UIApplication.sharedApplication().cancelAllLocalNotifications()
                //self.createReminders()
                ////self.tableView.rowHeight = UITableViewAutomaticDimension
                ////self.tableView.estimatedRowHeight = 160.0
                self.msgCollectionView.reloadData()  // notify tableView to reload data
                refreshControl.endRefreshing()
                print(String(format:"Number of events loaded: %d",self.messages.count))
                self.myLayout!.cellSizes = messages.map({ _ in return CGSize(width: 1, height: 1) })
                
                //if(messages.count>0) {
                //    self.formatTable()
                //}
            }
        }
    }
    
    @IBAction func buttonClicked(sender: AnyObject) {
        let content = msgInputBox.text
        activityIndicatorView.startAnimating()
        if content != "" {
            let delegate = ApiRequestDelegate()
            delegate.sendMessageToUser(User.email!, content: content) {
                (success) in
                if(success){
                    self.update(true)
                    // self.sortEvents()
                    // UIApplication.sharedApplication().cancelAllLocalNotifications()
                    // self.createReminders()
                    // //self.tableView.rowHeight = UITableViewAutomaticDimension
                    // //self.tableView.estimatedRowHeight = 160.0
                    self.msgCollectionView.reloadData()  // notify tableView to reload data
                    print(String(format:"Number of messages loaded: %d",self.messages.count))
                    //self.myLayout!.cellSizes = self.messages.map({ _ in return CGSize(width: 200, height: 100) })
                    // if(events.count>0) {
                    //     self.formatTable()
                    // }
                    self.msgInputBox.text = ""
                }
            }
        }
    }
    
    // 
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
        
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //NSLog("\(self), collectionView:numberOfItemsInSection")
        return messages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseCellID, forIndexPath: indexPath) as! MessagingCollectionViewCell
        
        //cell.msgLabel.text = "\(indexPath.section):\(indexPath.row) drunk fox running down the street holding icecream"
        cell.msgLabel.text = messages[indexPath.item].content
        //cell.msgLabel.sizeToFit()
        cell.msgLabel.preferredMaxLayoutWidth = 200
        let is_to_patient = self.messages[indexPath.row].is_to_patient
                            
        if is_to_patient { // message sent to patient left side
            cell.backgroundColor = UIColor.lightGrayColor()
            cell.msgLabel.textColor = UIColor.blackColor()
            cell.msgLabel.text = String(format: "admin[%d]: %@", indexPath.row, cell.msgLabel.text!)
        } else {
            cell.backgroundColor = self.view.tintColor
            cell.msgLabel.textColor = UIColor.whiteColor()
            cell.msgLabel.text = String(format: "me[%d]: %@", indexPath.row, cell.msgLabel.text!)
        }
        // Calculates the height
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        let cs = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        myLayout!.cellSizes[indexPath.item] = cs
        
        //NSLog("\(self), \(indexPath.item): \(cellSizes[indexPath.item])")
        //NSLog("getCELL: \(indexPath.item): \(cellSizes[indexPath.item])")
        
        // compute the position here
        //var xPos:CGFloat = 0.0
        //let viewSize = collectionView.frame.size
        //if !is_to_patient {
        //    //xPos = currentColumn*(itemWidth+self.minimumInteritemSpacing)+itemWidth*0.25
        //    //xPos = itemWidth*0.5
        //    xPos =  viewSize.width - cs.width - 10
        //} else {
        //   //xPos = currentColumn*(itemWidth+self.minimumInteritemSpacing)
        //    xPos = 10
        //}
        //myLayout!.xPosArray[indexPath.item] = xPos
        ////let yPos = currentRow*(itemHeight+self.minimumLineSpacing)+10
        //var yPos:CGFloat = 0.0
        //for i in 0 ..< indexPath.item {
        //    yPos = myLayout!.yPosArray[i] + myLayout!.cellSizes[i].height + 10
        //}
        //myLayout!.yPosArray[indexPath.item] = yPos
 
        
        // force redraw of the cell (otherwise cells that are visible only after
        // scrolling may not be draw properly)
        // TODO: only redraw when necessary (e.g. by checking the cell size 
        // currently drawn)
        collectionView.reloadItemsAtIndexPaths([indexPath])
        self.tryScrollToBottom(false)
        
        //cell.sizeToFit()
        //cell.imageView?.image = UIImage(named: "circle")
        return cell
    }
    
    //func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
    //    //cell.backgroundColor = UIColor.greenColor()
    //}
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            //2
            //let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
            //let availableWidth = view.frame.width - paddingSpace
            //let widthPerItem = availableWidth / itemsPerRow
            //
            //return CGSize(width: widthPerItem, height: widthPerItem)
            //return CGSize(width: 100, height: 50)
          NSLog("GETsize: \(indexPath.item): \(myLayout!.cellSizes[indexPath.item])")
            return myLayout!.cellSizes[indexPath.item]
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 1200)
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 0.0
   }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
