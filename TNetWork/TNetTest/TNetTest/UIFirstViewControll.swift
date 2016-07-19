//
//  UIViewControll.swift
//  TNetTest
//
//  Created by 张新华 on 16/7/13.
//  Copyright © 2016年 张新华. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
import CryptoSwift
import SwiftWebSocket
import TWebScoket;
import TSockeIO

class UIFirstViewControll: UIViewController {
     var isNDataBigEnida:Bool { return NSHostByteOrder() == NS_BigEndian}
    var lostHost:String="192.168.1.102";
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        print("isNDataBigEnida==\(isNDataBigEnida)");
        //regTLogHandle(socketlog) ;
      
    }
    
    override func viewDidAppear(animated: Bool){
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func socketlog(log:String) -> Void {
        LogSocket("%@",args: log);
    }
    
    /**
     test ProbufSocket
     
     - author: taven
     - date: 16-07-17 01:07:43
     
     - parameter sender: <#sender description#>
     */
    @IBAction func testProtoBuf(sender: AnyObject) {
        ProbufTSocketManager.sharedInstance.startConnectSocket(lostHost, mport:8800);
        
    }
    
    @IBAction func testAmf3Socket(sender: AnyObject) {
       TAmf3SocketManager.sharedInstance.startConnectSocket((DataCenterModel.sharedInstance.roomData?.socketIp)!, mport: (DataCenterModel.sharedInstance.roomData?.port)!);
    }
    
    
    @IBAction func testWebSocket(sender: AnyObject) {
        let tsockt = TWebSocket();
        
        tsockt.onOpen("ws://\(lostHost):8001") {
            let msg = "taven \(NSDate().description)"
            tsockt.onSendMessage(msg);
        }
        
        tsockt.onMsgReustHandle = {data in
            print("data===\(data)");
        }
        //利用ws？更灵活 注册闭包函数
        tsockt.ws?.event.pong = {
            data in
            print("vent.pong====\(data)");
            
        }
    }
    
    @IBAction func testSocketIO(sender: AnyObject) {
        let tsockeIO = TScoketIOCliend();
        tsockeIO.onOpen("ws://\(lostHost):3000") {
                tsockeIO.onEmit("login", "taven");
        }
        tsockeIO.socketIO?.on("loginSuccess", callback: { (data: [AnyObject], SocketAckEmitter) in
            tsockeIO.onEmit("postMsg","suceed");
        })
        
        tsockeIO.socketIO?.on("nickExisted", callback: { (data: [AnyObject], SocketAckEmitter) in
       
        })
    }
    

   }