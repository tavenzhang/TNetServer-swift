
// Created by 张新华 on 16/5/30.
//  Copyright © 2016年 张新华. All rights reserved.

 protocol netSocketProtol {
    
    func readMsgHead(data: NSMutableData) -> Int;
    
    func readMsgBody(data: NSMutableData) -> Bool;
    
    func sendHeartMsg() -> Void;
    
    func sendMessage(msgData: AnyObject?) -> Void;

}

 protocol netWebSocketProtol {
    
    func onOpen(para: AnyObject,sucessHandle:connectSucessHandle?) -> Void;
    
    func onMessageReceive(data: AnyObject) -> Void;
    
    func onSendMessage(msgData: AnyObject?) -> Void;
}

public typealias connectSucessHandle = () -> Void

public typealias SockeLogBlock = (log: String) -> Void

public typealias messageDictionaryBlock = (msgKey:AnyObject) -> AnyObject

public typealias messageResultHandleBlock = (mesage: AnyObject) -> Void




