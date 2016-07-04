//
//  ahnswerController.swift
//  ahsk
//
//  Created by Jonas Ehrenstein on 20.05.16.
//  Copyright © 2016 ehrenstain. All rights reserved.
//

import UIKit

class AhnswerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tblChat: UITableView!
    
    @IBOutlet weak var lblNewsBanner: UILabel!
    
    @IBOutlet weak var TypeLabel: UILabel! //shows when ahsk is ahnswered
    
    var nickname:String = NSUserDefaults.standardUserDefaults().valueForKey("ApplicationIdentifier")! as! String
    
    var chatMessages = [[String: AnyObject]]()
    
    var bannerLabelTimer: NSTimer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AhnswerViewController.handleUserTypingNotification(_:)), name: "userTypingNotification", object: nil)
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AhnswerViewController.handleKeyboardDidShowNotification(_:)), name: UIKeyboardDidShowNotification, object: nil)
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AhnswerViewController.handleKeyboardDidHideNotification(_:)), name: UIKeyboardDidHideNotification, object: nil)
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureTableView()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        SocketIOManager.sharedInstance.getChatMessage { (messageInfo) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.chatMessages.append(messageInfo)
                self.tblChat.reloadData()
                //                self.scrollToBottom()
            })
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    // MARK: IBAction Methods

    
    
    // MARK: Custom Methods
    
    func configureTableView() {
        tblChat.delegate = self
        tblChat.dataSource = self
        tblChat.registerNib(UINib(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: "idCellChat")
        tblChat.estimatedRowHeight = 90.0
        tblChat.rowHeight = UITableViewAutomaticDimension
        tblChat.tableFooterView = UIView(frame: CGRectZero)
    }
    
    
    
   /* func handleKeyboardDidShowNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                conBottomEditor.constant = keyboardFrame.size.height
                view.layoutIfNeeded()
            }
        }
    }
    
    
    func handleKeyboardDidHideNotification(notification: NSNotification) {
        conBottomEditor.constant = 0
        view.layoutIfNeeded()
    } */
    
    
    func scrollToBottom() {
        let delay = 0.1 * Double(NSEC_PER_SEC)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay)), dispatch_get_main_queue()) { () -> Void in
            if self.chatMessages.count > 0 {
                let lastRowIndexPath = NSIndexPath(forRow: self.chatMessages.count - 1, inSection: 0)
                self.tblChat.scrollToRowAtIndexPath(lastRowIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            }
        }
    }
    
    // MARK: UITableView Delegate and Datasource Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idCellChat", forIndexPath: indexPath) as! ChatCell
        
        let currentChatMessage = chatMessages[indexPath.row]
        var senderNickname:String
        let message = currentChatMessage["message"] as! String
        let messageDate = currentChatMessage["date"] as! String
        
        if currentChatMessage["nickname"] as! String == nickname {
            
            senderNickname = "you"
            
        } else {
            
            senderNickname = "someone"
            
        }
        
        cell.lblChatMessage.textAlignment = NSTextAlignment.Right
        cell.lblMessageDetails.textAlignment = NSTextAlignment.Right
            
        //cell.lblChatMessage.textColor = lblNewsBanner.backgroundColor
        
        cell.lblChatMessage.text = message
        cell.lblMessageDetails.text = "ahsked by \(senderNickname) @ \(messageDate)"
        
        cell.lblChatMessage.textColor = UIColor.darkGrayColor()
        
        return cell
    }
    
    
    // MARK: UITextViewDelegate Methods
    
    //Check if User is typing
    func handleUserTypingNotification(notification: NSNotification) {
        if let typingUsersDictionary = notification.object as? [String: AnyObject] {
            var names = ""
            var totalTypingUsers = 0
            for (typingUser, _) in typingUsersDictionary {
                if typingUser != nickname {
                    names = (names == "") ? typingUser : "\(names), \(typingUser)"
                    totalTypingUsers += 1
                }
            }
            
            if totalTypingUsers > 0 {
                
                //TypeLabel.hidden = false
            }
            else {
                //TypeLabel.hidden = true
            }
        }
        
    }

    
    // MARK: UIGestureRecognizerDelegate Methods
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
