//
//  GoogleProBufSocket.swift
//  TNetServer
//
//  Created by 张新华 on 16/7/14.
//  Copyright © 2016年 张新华. All rights reserved.
//

import Foundation
public class ProBufSocketManage: TSocketGCDServer {
    /**
     读取消息头
     - author: taven
     - date: 16-07-14 08:07:46
     */
   override public func readMsgHead(data: NSMutableData) -> Int {
        
        return 0;
    }
    
    /**
     读取消息body
     - author: taven
     - date: 16-07-14 08:07:46
     */
   override public func readMsgBody(data: NSMutableData) -> Bool {
        return false;
    }
    
    /**
     发送心跳包
     - author: taven
     - date: 16-07-14 08:07:3
     */
    override public func sendHeartMsg() -> Void {
        
    }
    /**
     发送正常消息
     - author: taven
     - date: 16-07-14 08:07:58
     - parameter msgData: <#msgData description#>
     */
    override public func sendMessage(msgData: AnyObject?) -> Void {
        
    }
}