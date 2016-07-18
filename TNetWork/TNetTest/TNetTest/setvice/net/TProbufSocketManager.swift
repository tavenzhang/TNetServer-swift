//
//  ProtobufSockerManger.swift
//  TNetTest
//
//  Created by 张新华 on 16/7/15.
//  Copyright © 2016年 张新华. All rights reserved.
//
import Foundation
import TProbufSocket

class ProbufTSocketManager {
    
    internal static let sharedInstance = ProbufTSocketManager()
    //消息处理函数
    var socket:TProbufSocketManage?;
    
    private  init() {
        socket =  TProbufSocketManage(heartTime: 10, msgHeadSize: 8,isByteBigEndian: false);
        socket!.onMsgResultHandle = onMsgResHandle;
        socket!.onMsgDicHandle=PrtobufMsgDiconary.getMessageByMsgId;
        PrtobufMsgDiconary.regInitMessageDiction();
        socket!.onTLogHandle=socketlog;
    }
    deinit
    {

    }
    
    func socketlog(log:String) -> Void {
        LogSocket("%@",args: log);
    }
    //开启socket 连接
    func startConnectSocket(host:String,mport:Int,timeOut:NSTimeInterval=0)->Void
    {
     
        socket!.onConnectSocket(host, port: mport, timeOut: timeOut){
            [weak self] in
              // 成功连接后开始发送第一个消息 10000消息
            let msg =  Person.Builder();
            msg.id = 222;
            msg.name = "taven";
            self?.sendMessage(MsgProbufBase(mid: 1, data: msg));
        };
    }
    
    //关闭socket 连接
    func closeSocket()->Void
    {
        socket!.closeSocket();
    }
    
    func sendMessage(message:MsgProbufBase) -> Void {
        
        socket!.sendMessage(message);
    }
    
    
    func onMsgResHandle(message: AnyObject) -> Void
    {
        let meeasg = message as! MsgProbufBase;
        LogSocket("receive--->msgId=%d, body==%@", args: meeasg.msgId,meeasg.dataMessage.debugDescription);
        switch(meeasg.msgId){
        case 5:
            let msgPerson = meeasg.dataMessage as! Person.Builder;
            LogSocket("receive--->msgId=%d, body==%@", args: msgPerson.id,msgPerson.name);
            break;
        default:
            break;
        }
        
    }
    
}
