//
//  TSockerIO.swift
//  TNetServer
//
//  Created by 张新华 on 16/7/17.
//  Copyright © 2016年 张新华. All rights reserved.
//

import Foundation
import SocketIOClientSwift

public class TScoketIOCliend {
    
    public var socketIO: SocketIOClient?

    
    public var onConnectSucHadnle:connectSucessHandle?;
    
    public var onTLogHandle:SockeLogBlock?=nil;
    
    
    public init(){
        
    }
    
    /**
     日志打印
     - author: taven
     - date: 16-07-18 15:07:20
     */
    func TLog(cont: String, args: CVarArgType...) -> Void {
        if ((onTLogHandle) != nil)
        {
            let log = NSString(format: cont, arguments: getVaList(args));
            onTLogHandle!(log: log as String);
        }else{
            NSLogv(cont,  getVaList(args));
        }
    }
    
    
    public func onOpen(url:String, options: Set<SocketIOClientOption> = [],connectHandle:connectSucessHandle?)
    {
        if(connectHandle != nil)
        {
            onConnectSucHadnle = connectHandle;
        }
        
        if(socketIO != nil)
        {
            socketIO!.disconnect();
        }
        if(options.count <= 0)
        {
            socketIO=SocketIOClient(socketURL:NSURL(string: url)!,options: [.ForceWebsockets(true)]);
        }
        else{
             socketIO=SocketIOClient(socketURL:NSURL(string: url)!,options:options);
        }
      
        socketIO?.connect();
        
        socketIO!.on("connect") { (data: [AnyObject], ack:SocketAckEmitter) in
            if(self.onConnectSucHadnle != nil)
            {
                self.onConnectSucHadnle!();
            }
        }
        socketIO?.onAny({
            [weak self](evt:SocketAnyEvent) in
            self?.TLog("rec <---------- evt=\"\(evt.event)\"   data=\(evt.items!)");
        })
    }

    public func onEmit(event: String,_ items:AnyObject...){
        onEmitwithItems(event, items: items);
    }
    
    public func onEmitwithItems(event: String,items:[AnyObject]){
        TLog("send ------->  \(items.description)");
        socketIO?.emit(event, withItems: items);
        
    }
    
    


  


}