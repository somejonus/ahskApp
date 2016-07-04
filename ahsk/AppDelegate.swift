//
//  AppDelegate.swift
//  ahsk
//
//  Created by Jonas Ehrenstein on 11.05.16.
//  Copyright © 2016 ehrenstain. All rights reserved.
//

import UIKit

extension NSData {
    func hexString() -> String {
        // "Array" of all bytes:
        let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer(self.bytes), count:self.length)
        // Array of hex strings, one for each byte:
        let hexBytes = bytes.map { String(format: "%02hhx", $0) }
        // Concatenate all hex strings:
        return (hexBytes).joinWithSeparator("")
    }
    
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var nickname:String = ""
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Override point for customization after application launch.
        
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
        let pushNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        let stored = KeychainWrapper.stringForKey("UUID")
        
        if stored != nil {
            
            print("retrieved UUID from keychain: \(stored!)")
            
        } else {
            
            let UUID = NSUUID().UUIDString
            
            userDefaults.setObject(UUID, forKey: "ApplicationIdentifier")
            userDefaults.synchronize()
            
            print("generated UUID: \(UUID)")
            
            let ret = KeychainWrapper.setString(UUID, forKey: "UUID")
            
            print("setkeychain: \(ret)")
        }
        
        let nickname:String = KeychainWrapper.stringForKey("UUID")!
        
        SocketIOManager.sharedInstance.establishConnection()
        
        SocketIOManager.sharedInstance.sendStartTypingMessage(nickname)
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        SocketIOManager.sharedInstance.closeConnectionWithNickname(NSUserDefaults.standardUserDefaults().valueForKey("ApplicationIdentifier")! as! String)
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        SocketIOManager.sharedInstance.connectToServerWithNickname(NSUserDefaults.standardUserDefaults().valueForKey("ApplicationIdentifier")! as! String)
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        SocketIOManager.sharedInstance.closeConnectionWithNickname(NSUserDefaults.standardUserDefaults().valueForKey("ApplicationIdentifier")! as! String)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        

        let session = NSURLSession.sharedSession()
        let userId:String = KeychainWrapper.stringForKey("UUID")!
        let tk = deviceToken.hexString()
        let postBody = NSString(format: "user=%@&token=%@", userId, tk)
        let endBody = NSURL(string: "http://146.185.137.157/ahskapp/addToken.php")
        let request = NSMutableURLRequest(URL: endBody!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        request.HTTPMethod = "POST";
        request.HTTPBody = postBody.dataUsingEncoding(NSUTF8StringEncoding)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let dataTask = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            
            if data != nil {
                
                print("data: \(response)")
                print("deviceToken \(tk) send for user \(userId)")
                
            } else {
                
                print("failed: \(error!.localizedDescription)")
                
            }
            
        }//closure
        
        dataTask.resume()
        
        
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print(userInfo)
    }
    
}