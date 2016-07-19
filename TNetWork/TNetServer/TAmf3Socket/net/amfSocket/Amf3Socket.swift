//
//  Amf3Socket.swift
//  TVideo
//
//  Created by 张新华 on 16/5/31.
//  Copyright © 2016年 张新华. All rights reserved.
//

import BBSZLib

public class Amf3SocketManager: TSocketGCDServer {


	/**
	 解析消息头
	 - parameter data: <#data description#>
	 */
	override public func readMsgHead(data: NSMutableData) -> Int {
        let len = data.getShort(_isByteBigEndian)
		return len ;
	}

	// 解析消息体
	override public func readMsgBody(data: NSMutableData) -> Bool {
		var objNSData: NSData?
		do {
			objNSData = try data.getBytesByLength(curMsgBodyLength).bbs_dataByInflating();
		} catch {
			TLog("bbs_dataByInflating error");
			return false;
		}
		var amf3Unarchiver: AMFUnarchiver?;
		if (objNSData!.length > 0)
		{

			amf3Unarchiver = AMFUnarchiver(forReadingWithData: objNSData, encoding: kAMF3Encoding);
			var obj: NSObject?;
			if (amf3Unarchiver != nil)
			{
				obj = amf3Unarchiver!.decodeObject();
			}

			if self.onMsgResultHandle != nil && obj != nil
			{
				self.onMsgResultHandle!(mesage: obj!);
			}
		}
		return true;
	}

	/**
	 发送消息
	 - author: taven
	 - date: 16-07-13 14:07:48
	 */
	override public func sendMessage(msgData: AnyObject?) -> Void {
        
        let message = msgData as! S_msg_base;
        do {
            let amf3 = AMF3Archiver()
            let dic = message.toDictionary()
            TLog("send:--->%@", args: dic);
            amf3.encodeObject(dic);
            let amfData = try amf3.archiverData().bbs_dataByDeflating() as! NSMutableData;
            amfData.appendString("\r\n");
            self.socket?.writeData(amfData, withTimeout: 1, tag: 1);
        }
        catch {
            TLog("message send error!");
        }
	}


	/**
	 心跳包消息
	 - author: taven
	 - date: 16-07-13 13:07:32
	 */
	 override public func sendHeartMsg() -> Void {
        
        super.sendHeartMsg();
        
	}


}