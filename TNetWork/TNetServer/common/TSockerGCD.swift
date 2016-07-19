// Created by 张新华 on 16/5/30.
//  Copyright © 2016年 张新华. All rights reserved.
//

import Foundation
import CocoaAsyncSocket.GCDAsyncSocket


class TGCDSocker: GCDAsyncSocket {

	static var socket: GCDAsyncSocket? = nil;

	static func shareSocket() -> GCDAsyncSocket
	{
		if socket == nil
		{
			socket = GCDAsyncSocket();
		}
		return socket!;
	}
}

public class TSocketGCDServer: NSObject,netSocketProtol {

	public var buffMutableData: NSMutableData?=nil;
    
	public var heartNSTimer: NSTimer? = nil;
    /// 是否使用大端模式
    public var _isByteBigEndian:Bool = true;
    //心跳包
    public var  heartMessage:AnyObject? = nil;
	// 心跳间隔
	var heartTimeDim: Double = 0;
    
	var socket: TGCDSocker? = nil;
	var _host: String = "";
	var _port: Int = 0;
	var _timeOut: NSTimeInterval = NSTimeInterval(0);
	// 消息头长度 默认2个字节byte
	var msgHeadSize = 2;
	var curMsgBodyLength = 0;

    
    //
    public var onConnectSucHandle:connectSucessHandle?;
    
    public var onCloseHandle:connectSucessHandle?;

    public var onWillColseHandle:((data:AnyObject)->Void)?;
    
    // 消息结果处理函数
    public var  onMsgResultHandle: messageResultHandleBlock? = nil;
    
    // 消息字典处理函数
    public  var onMsgDicHandle: messageDictionaryBlock? = nil
    
    
    public var onTLogHandle:SockeLogBlock?=nil;
    
    /**
     msgheadLength
     - author: taven
     - date: 16-07-14 09:07:34
     - parameter hearTime:      心跳包函数调用间隔 单位秒  <=0 则不开启心跳检测
     - parameter msgheadLength: 消息头长度 必须指定大小 headSize
     －isByteBigEndian 是否服务器cpu架构目标用大端模式
     */
    public init(heartTime: Double, msgHeadSize: Int ,isByteBigEndian:Bool) {
        super.init();
        buffMutableData = NSMutableData();
        socket = TGCDSocker(delegate: self, delegateQueue: dispatch_get_global_queue(0, 0));
        self.updataSocketParams(heartTime,msgheadLength:msgHeadSize,isByteBigEndian:isByteBigEndian);
	}

	deinit {
		heartNSTimer?.invalidate();
	}
    
    
    /**
     日志打印
     - author: taven
     - date: 16-07-18 15:07:20
     
     - parameter cont: <#cont description#>
     - parameter args: <#args description#>
     */
    func TLog(cont: String, args: CVarArgType...) -> Void {
        if ((onTLogHandle) != nil)
        {
            let log = NSString(format: cont, arguments: getVaList(args));
            onTLogHandle!(log: log as String);
        }else{
           // NSLogv(cont,  getVaList(args));
        }
    }
    


    /**
     设置心跳间隔
     - parameter hearTime:      <#hearTime description#>
     - parameter msgheadLength: <#msgheadLength description#>
     */
    public func updataSocketParams(hearTime: Double, msgheadLength: Int,isByteBigEndian:Bool=true) {
        msgHeadSize = msgheadLength;
        heartTimeDim = hearTime;
        _isByteBigEndian = isByteBigEndian;
    }

    //开启socket 连接
    public func onConnectSocket(host: String, port: Int, timeOut: NSTimeInterval = 0, connectH:connectSucessHandle?) -> Void
	{
		_host = host;
		_port = port;
		_timeOut = timeOut;
        if(connectH != nil)
        {
            self.onConnectSucHandle = connectH;
        }
		if socket!.isConnected == false
		{
			do {
				if timeOut > 0 {
					try socket!.connectToHost(host, onPort: UInt16(port), withTimeout: timeOut)

				}
				else {
					try socket!.connectToHost(host, onPort: UInt16(port));
				}
                if self.heartTimeDim > 0 {
                    if(self.heartNSTimer == nil)
                    {
                        heartNSTimer = NSTimer.init(timeInterval: self.heartTimeDim, target: self, selector: #selector(TSocketGCDServer.checkSendHeart), userInfo: nil, repeats: true);
                        NSRunLoop.currentRunLoop().addTimer(self.heartNSTimer!, forMode: NSRunLoopCommonModes)
                        heartNSTimer?.fire();
                    }
                    else{
                        self.heartNSTimer?.invalidate();
                        heartNSTimer = NSTimer.init(timeInterval: self.heartTimeDim, target: self, selector: #selector(TSocketGCDServer.checkSendHeart), userInfo: nil, repeats: true);
                        NSRunLoop.currentRunLoop().addTimer(self.heartNSTimer!, forMode: NSRunLoopCommonModes)
                        heartNSTimer?.fire();
                    }
                }
                else{
                    self.heartNSTimer?.invalidate();
                }
			} catch let erro as NSError {
				TLog("startConnectSocket connect went wrong =%@!", args: erro.localizedDescription);
                heartNSTimer?.invalidate();
			}
		}
		else {
			closeSocket();
			onConnectSocket(host, port: port, timeOut: _timeOut,connectH: self.onConnectSucHandle);
		}
		TLog("startConnectSocket host=%@  port=%d", args: host, port);
	}
    /**
     判断当前是否开启了 心跳
     - author: taven
     - date: 16-07-14 09:07:20
     */
    public func isEnableHeart()->Bool{
        return socket!.isConnected && self.heartTimeDim>0;
    }

	 public func closeSocket()
	{
		TLog("host closeSocket")
		if socket!.isConnected
		{
			socket!.disconnect();
		}
	}
    //判断一下是否已经正常连接好
    func checkSendHeart() -> Void {
        if(socket!.isConnected)
        {
            self.sendHeartMsg();
        }
    }

	// reconncect socket
	public func reConnect() -> Void {
        onConnectSocket(_host, port: _port, timeOut: _timeOut,connectH:self.onConnectSucHandle);
	}

	public func setHeartAndHead(heartTime: Double, msgLen: Int)
	{
		heartTimeDim = heartTime;
		msgHeadSize = msgLen;
	}
    /**
     读取消息头 子类必须ovrride
     - author: taven
     - date: 16-07-14 08:07:46
     */
	public func readMsgHead(data: NSMutableData) -> Int {
  
        return 0 ;
	}

    /**
     读取消息body  子类必须ovrride
     - author: taven
     - date: 16-07-14 08:07:46
     */
	public func readMsgBody(data: NSMutableData) -> Bool {
		return false;
	}

    /**
     发送心跳包
     - author: taven
     - date: 16-07-14 08:07:3
     */
	public func sendHeartMsg() -> Void {
        if(heartMessage != nil)
        {
            sendMessage(heartMessage!);
        }
	}
    /**
     发送正常消息
     - author: taven
     - date: 16-07-14 08:07:58
     - parameter msgData: <#msgData description#>
     */
	public func sendMessage(msgData: AnyObject?) -> Void {

	}
}

extension TSocketGCDServer: GCDAsyncSocketDelegate {

	 public func socketDidCloseReadStream(sock: GCDAsyncSocket) {
        
		TLog("socketDidCloseReadStream")
	}

	 public func socketDidDisconnect(sock: GCDAsyncSocket, withError err: NSError?) {

        if(err != nil)
        {
                TLog("socketDidDisconnect --err=%@!",args: err!.localizedDescription)
        }
        else{
            TLog("socketDidDisconnect");
        }
        
        if(onCloseHandle != nil)
        {
            onCloseHandle!();
        }
        
	}
	 public func socket(sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16)
	{
		TLog("host=%@-port=%d  connect Successful!", args: host, port);
		self.socket?.readDataWithTimeout(NSTimeInterval(-1), buffer: buffMutableData, bufferOffset: UInt (buffMutableData!.length), tag: 9);
        if(onConnectSucHandle != nil)
        {
            onConnectSucHandle!();
        }
	}
    
	// 可以通过sock.userData 来区分是由于什么原因断线
	 public func socketDidDisconnect(sock: GCDAsyncSocket!) {
        if(onWillColseHandle != nil)
        {
            onWillColseHandle!(data: sock.userData!);
        }
	}
    
	// socket 即将断开
	 public func socket(sock: GCDAsyncSocket!, willDisconnectWithError err: NSError!) {
		// wifi 断开 即将断开时触发
        TLog("willDisconnectWithErro --err=%@!",args: err.localizedDescription);
	}

	// socket 发送数据成功后
	 public func socket(sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
		TLog("发送成功 tag--%d", args: tag);
	}
    
	// socket  接受到数据后 这里是处理数据的关键
	 public func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Int) {
		TLog("收到数据data=%d curAmfMsgLen==%d－－buffMutableData＝%d", args: data.length,curMsgBodyLength,buffMutableData!.length);
		while (buffMutableData!.length >= self.msgHeadSize)
		{

			if curMsgBodyLength <= 0 {
				curMsgBodyLength = readMsgHead(buffMutableData!);
			}
			if (buffMutableData!.length < curMsgBodyLength)
			{
				break;
			}
           let data = buffMutableData!.getBytesByLength(curMsgBodyLength);
			readMsgBody(data);
            curMsgBodyLength = 0;
		}
        //TLog("处理后 curAmfMsgLen==%d －－－－－buffMutableData＝%d", args:curMsgBodyLength,buffMutableData!.length);
		self.socket?.readDataWithTimeout(NSTimeInterval(-1), buffer: buffMutableData, bufferOffset: UInt (buffMutableData!.length), tag: 9);
	}

}
