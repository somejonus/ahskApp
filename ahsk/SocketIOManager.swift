//
//  SocketIOManager.swift
//  SocketChat
//
//  Created by Jonas Ehrenstein on 19.05.16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    
    
    override init() {
        super.init()
    }
    
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://146.185.137.157:8080")!)
    
    func establishConnection() {
        socket.connect()
        print("CONNECTED")
    }
    
    
    func closeConnectionWithNickname(nickname: String) {
        
        socket.emit("exitUser", nickname)

            print("USER DISCONNECTED = \(nickname)")
    }
    
    func connectToServerWithNickname(nickname: String) {
        
        socket.emit("connectUser", nickname) //nickname
        
            print("USER CONNECTED = \(nickname)")
        
        listenForOtherMessages()
    }
    
    func exitChatWithNickname(nickname: String, completionHandler: () -> Void) {
        socket.emit("exitUser", nickname)
        completionHandler()
    }
    
    func sendMessage(message: String, withNickname nickname: String) {
        socket.emit("chatMessage", nickname, message)
    }
    
    func getChatMessage(completionHandler: (messageInfo: [String: AnyObject]) -> Void) {
        socket.on("newChatMessage") { (dataArray, socketAck) -> Void in
            var messageDictionary = [String: AnyObject]()
            messageDictionary["nickname"] = dataArray[0] as! String
            messageDictionary["message"] = dataArray[1] as! String
            messageDictionary["date"] = dataArray[2] as! String
            
            completionHandler(messageInfo: messageDictionary)
        }
    }
    
    private func listenForOtherMessages() {
        socket.on("userConnectUpdate") { (dataArray, socketAck) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("userWasConnectedNotification", object: dataArray[0] as! [String: AnyObject])
        }
        
        /*socket.on("userExitUpdate") { (dataArray, socketAck) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("userWasDisconnectedNotification", object: dataArray[0] as! String)
        }*/
        
        socket.on("userTypingUpdate") { (dataArray, socketAck) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("userTypingNotification", object: dataArray[0] as? [String: AnyObject])
        }
    }
    
    func sendStartTypingMessage(nickname: String) {
        socket.emit("startType", nickname)
    }
    
    func sendStopTypingMessage(nickname: String) {
        socket.emit("stopType", nickname)
    }
    
}