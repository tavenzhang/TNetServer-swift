//
//  TWebScoket.swift
//  TNetServer
//
//  Created by 张新华 on 16/7/17.
//  Copyright © 2016年 张新华. All rights reserved.
//

import SwiftWebSocket

public class TWebSocket:netWebSocketProtol{

    public  var ws:WebSocket?;
    
    public  var onMsgReustHandle:messageResultHandleBlock?;

    public var onConnectSucHadnle:connectSucessHandle?;
    
    public var onTLogHandle:SockeLogBlock?=nil;
    
    var urlParam:AnyObject?;

    
    public init()
    {
        
    }
    
    deinit
    {
        onMsgReustHandle=nil;
        onConnectSucHadnle=nil;
        ws=nil;
    }
    
    
    func TLog(cont: String, args: CVarArgType...) -> Void {
        if ((onTLogHandle) != nil)
        {
            let log = NSString(format: cont, arguments: getVaList(args));
            onTLogHandle!(log: log as String);
        }else{
            NSLogv(cont,  getVaList(args));
        }
    }
  
    
    public  func onOpen(para:AnyObject,sucessHandle:connectSucessHandle?)->Void{
        urlParam = para;
        if(sucessHandle != nil)
        {
                 onConnectSucHadnle = sucessHandle;
        }
        if  let resq=para as? NSURLRequest
        {
            ws = WebSocket(request: resq);
            ws!.delegate = self;
        }
        else if let url=para as? String
        {
            ws = WebSocket(url)
            ws!.delegate = self;
        }
    }
    
    public func onMessageReceive(data:AnyObject)->Void{
        if(onMsgReustHandle != nil)
        {
            onMsgReustHandle!(mesage: data);
        }
    }
    
    
    public  func onSendMessage(msgData: AnyObject?)->Void{
        TLog("send --------> \(msgData)");
        ws!.send(msg)
    }
}

extension TWebSocket:WebSocketDelegate{
    
    @objc public func webSocketOpen()
    {
        TLog("open websocker success  url==\(urlParam)");
        if(onConnectSucHadnle != nil)
        {
            onConnectSucHadnle!();
        }
    }
    /// A function to be called when the WebSocket connection's readyState changes to .Closed.
    @objc public func webSocketClose(code: Int, reason: String, wasClean: Bool)
    {
        TLog("webScoketCLose code =%d,resion=%@, waseClean=\(wasClean)", args: code,reason);
    }
    /// A function to be called when an error occurs.
    @objc public func webSocketError(error: NSError)
    {
        TLog("open url==\(urlParam)  websocker error=\(error.localizedDescription)");
    }
    
    /// A function to be called when a message (string) is received from the server.
     @objc public func webSocketMessageText(text: String)
    {
        TLog("rec <-------- text=\(text)");
    }
    /// A function to be called when a message (binary) is received from the server.
     @objc public func webSocketMessageData(data: NSData){
        TLog("rec <--------  NSData len=\(data.length)");
    }
    
    /// A function to be called when a pong is received from the server.
     @objc public func webSocketPong()
    {
        TLog("onMessageReceive onMessagPong");        
    }
    /// A function to be called when the WebSocket process has ended; this event is guarenteed to be called once and can be used as an alternative to the "close" or "error" events.
     @objc public  func webSocketEnd(code: Int, reason: String, wasClean: Bool, error: NSError?)
    {
        TLog("webSocketEnd url==\(urlParam)  code=\(code)  reason=\(reason)  wasClean=\(wasClean) error=\(error) ");
    }
}
