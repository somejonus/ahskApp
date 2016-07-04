//
//  ahskController.swift
//  ahsk
//
//  Created by Jonas Ehrenstein on 11.05.16.
//  Copyright © 2016 ehrenstain. All rights reserved.
//

import UIKit

// MARK: Extensions

// Set UIButton Color as BackgroundImage
extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), color.CGColor)
        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, forState: forState)
    }}

// Request UIColor as red: xxx, green: xxx, blue: xxx,
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1 )
    }
}


class AhskViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, SWRevealViewControllerDelegate {
    
    @IBOutlet weak var cLabel: UILabel! //textcount Label
    
    @IBOutlet weak var ahskField: UITextField! //question Field
    
    @IBOutlet weak var ahskButton: UIButton! //sends question
    
    //question Field is being edited
    @IBAction func ahskEdit(sender: UITextField) {
        
        let quest:Character = "?" // Character to append
        
        if sender.text!.characters.count == 1 {
            
            if sender.text! != "?" {
            
                self.ahskField.text!.append(quest)
            
                // only if there is a currently selected range
                if let selectedRange = sender.selectedTextRange {
            
                // and only if the new position is valid
                if let newPosition = sender.positionFromPosition(selectedRange.start, inDirection: UITextLayoutDirection.Left, offset: 1) {
                    
                // set the new position
                sender.selectedTextRange = sender.textRangeFromPosition(newPosition, toPosition: newPosition)
                    }
                }
                
            } else {
                
                sender.text = "" //Clear TextField
                
                cLabel.text = "25" //Reset textcount Label
                
                ahskButton.userInteractionEnabled = false //Disabling the button
                ahskButton.enabled = false
                
            }
        }
    }
    
    var users = [[String: AnyObject]]() //USERS???
    let nickname:String = NSUserDefaults.standardUserDefaults().valueForKey("ApplicationIdentifier")! as! String
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        ahskField.delegate = self
        ahskField.becomeFirstResponder()
        
        SocketIOManager.sharedInstance.sendStartTypingMessage(nickname)
        
        ahskButton.setBackgroundColor(UIColor(red: 55, green: 0, blue: 255), forState: UIControlState.Normal)
        ahskButton.setBackgroundColor(UIColor(red: 20, green: 20, blue: 20, alpha: 0.03), forState: UIControlState.Disabled)
        ahskButton.setTitleColor(UIColor(red: 255, green: 255, blue: 255, alpha: 0.05), forState: UIControlState.Disabled)

        ahskButton.layer.cornerRadius = 5
        ahskButton.enabled = false
        
        // Do any additional setup after loading the view, typically from a nib.
        
        self.revealViewController().delegate = self;
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(AhskViewController.dismissKeyboard))
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        swipeGestureRecognizer.delegate = self
        view.addGestureRecognizer(swipeGestureRecognizer)
        
        if self.revealViewController() != nil {
            ahskButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        let str = NSAttributedString(string: "What's your question?", attributes: [NSForegroundColorAttributeName:UIColor.grayColor()])
        ahskField.attributedPlaceholder = str
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "goToAhnswer" {
                let ahnswerController : AhnswerViewController = segue.destinationViewController as! AhnswerViewController
                ahnswerController.nickname = nickname
            }
        }
    }
    
    
    // MARK: IBAction Methods
    
    
    @IBAction func ahskButton(sender: AnyObject) {
        
        if ahskField.text!.characters.count > 0 {
            SocketIOManager.sharedInstance.sendMessage(ahskField.text!, withNickname: nickname)
            
            ahskField.text! = ""
            ahskField.resignFirstResponder()
 
            ahskButton.userInteractionEnabled = false //Disabling the button
            ahskButton.enabled = false
            
            cLabel.text = "25"
            
        }
    }

    
    // MARK: Custom Methods
    
    
    // Dismiss Kaybord
    func dismissKeyboard() {
        if ahskField.isFirstResponder() {
            ahskField.resignFirstResponder()
            
            SocketIOManager.sharedInstance.sendStopTypingMessage(nickname)
        }
    }
    
    // MARK: UITextFieldDelegate Methods
    
    //question Field controlling Button
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let text = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        let newLength = text.characters.count
        
        if newLength <= 25 {
            cLabel.text = String(25 - newLength)
            if text.isEmpty { //Checking if the input field is empty
                
                cLabel.text = "25"
                
                ahskButton.userInteractionEnabled = false //Disabling the button
                ahskButton.enabled = false
                
            } else {

                ahskButton.userInteractionEnabled = true //Enabling the button
                ahskButton.enabled = true
                
            }
            return true;
        } else {
            return false;
        }
    }
    
    func typeStat() {
        if self.ahskField.isFirstResponder() {
            
            SocketIOManager.sharedInstance.sendStartTypingMessage(self.nickname)
            
        } else {
            
             SocketIOManager.sharedInstance.sendStopTypingMessage(self.nickname)
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
       
    }
    
    // MARK: UIGestureRecognizerDelegate Methods
    
    //reveald ViewController controls question Fields firstResponder status
    func revealController(revealController: SWRevealViewController!, willMoveToPosition position: FrontViewPosition) {
        
        if (position == FrontViewPosition.Left) {
            
             self.ahskField.userInteractionEnabled = true
            self.ahskField.becomeFirstResponder();
            typeStat()
            
        } else {
            
            self.ahskField.resignFirstResponder();
            self.ahskField.userInteractionEnabled = false
            typeStat()
            
        }
    }
    
    //Call gestureRecognizer
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}


    
    