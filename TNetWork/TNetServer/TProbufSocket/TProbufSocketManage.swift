//
//  googleProbufSocket.swift
//  TNetServer
//
//  Created by 张新华 on 16/7/14.
//  Copyright © 2016年 张新华. All rights reserved.
//

import ProtocolBuffers

public class TProbufSocketManage: TSocketGCDServer {

	var lastMsg: MsgProbufBase? = nil;

	/**
	 读取消息头  子类必须ovrride
	 - author: taven
	 - date: 16-07-14 08:07:46
	 */
	override public func readMsgHead(data: NSMutableData) -> Int {
		lastMsg = MsgProbufBase();
        lastMsg?.msgId =  data.getInt32(_isByteBigEndian);
		let bodyLength = data.getInt32(_isByteBigEndian);
		return bodyLength ;
	}

	/**
	 读取消息body  子类必须ovrride
	 - author: taven
	 - date: 16-07-14 08:07:46
	 */
	override public func readMsgBody(data: NSMutableData) -> Bool {
        if(self.onMsgDicHandle != nil)
        {
          lastMsg?.dataMessage = self.onMsgDicHandle!(msgKey:lastMsg!.msgId) as? GeneratedMessageBuilder;
        }

        do{
            try   lastMsg?.dataMessage?.mergeFromData(data);
        }
        catch let err as NSError{
            TLog("mergeFromData err=%@", args: err.localizedDescription);
        }
        if(lastMsg != nil && lastMsg?.dataMessage != nil)
        {
            if(self.onMsgResultHandle != nil)
            {
                self.onMsgResultHandle!(mesage:lastMsg!);
            }
        }
		return true;
	}

	/**
	 发送心跳包
	 - author: taven
	 */
	override public func sendHeartMsg() -> Void {
        super.sendHeartMsg();
	}
    
	/**
	 发送正常消息
	 - author: taven
	 */
	override public func sendMessage(msgData: AnyObject?) -> Void {
        do {
            let messageBuild = msgData as! MsgProbufBase;
            TLog("send:--msgId=%d-->\n%@", args: messageBuild.msgId,messageBuild.dataMessage!.debugDescription);
            let socketData = NSMutableData();
            let amfData = try  messageBuild.dataMessage!.build().data();
            //writer header -- msgId
            socketData.appendInt(messageBuild.msgId, isBigEndian: _isByteBigEndian);
            //writer header ---bodySize
            socketData.appendInt( amfData.length, isBigEndian: _isByteBigEndian);
            //writer bodydata
            socketData.appendData(amfData);
            self.socket?.writeData(socketData, withTimeout: 1, tag: 1);
        }
        catch {
            TLog("message send error!");
        }

	}
}
