//
//  Amf3Socket.swift
//  TVideo
//
//  Created by 张新华 on 16/5/31.
//  Copyright © 2016年 张新华. All rights reserved.
//

import Foundation
import BBSZLib

public class Amf3SocketManager: TSocketGCDServer {

	// 消息处理函数
	public var messageHandle: ((mesage: NSObject) -> Void)?;

	var isStartHeat: Bool = false;
	// Using NSLock
	let critLock: NSLock? = nil;

	public func regMessageHandle(handle: (mesage: NSObject) -> Void) {
		self.messageHandle = handle;
	}

	let hertMessage = S_msg_heart_9999(_cmd: 9999);

	public func setStartHeart(tag: Bool)
	{
		isStartHeat = tag;
	}

	/**
	 解析消息头
	 - parameter data: <#data description#>
	 */
	override public func readMsgHead(data: NSMutableData) -> Int {
        
		return super.readMsgHead(<#T##data: NSMutableData##NSMutableData#>) ;
	}

	// 解析消息体
	override public func readMsgBody(data: NSMutableData) -> Bool {
		var objNSData: NSData?
		do {
			objNSData = try data.getBytesByLength(curMsgBodyLength).bbs_dataByInflating();
		} catch {
			print("bbs_dataByInflating error");
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

			if self.messageHandle != nil && obj != nil
			{
				self.messageHandle!(mesage: obj!);
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
		self.sendAmd3Message(msgData as! S_msg_base);
	}

	func sendAmd3Message(message: S_msg_base) {
		// critLock.lock()
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
		// critLock.unlock();
	}

	/**
	 心跳包消息
	 - author: taven
	 - date: 16-07-13 13:07:32
	 */
	@objc override public func sendHeartMsg() -> Void {
		// 向服p务器发送固定可是的消息，来检测长连接
		if (isStartHeat)
		{
			sendMessage(hertMessage);
		}
	}

}