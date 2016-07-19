//
//  Amf3Socket.swift
//  TVideo
//
//  Created by 张新华 on 16/5/31.
//  Copyright © 2016年 张新华. All rights reserved.
//

import Foundation
import TAmf3Socket
import SwiftyJSON
import TAmf3Socket
import NSLogger

class MyAm33Soket: Amf3SocketManager {
    
    
}


class TAmf3SocketManager {

    internal static let sharedInstance = TAmf3SocketManager();

    //消息处理函数
    var socket:Amf3SocketManager?;
  
    private  init() {
        socket = Amf3SocketManager(heartTime: 10, msgHeadSize:2,isByteBigEndian: true);
        socket!.onMsgResultHandle=handleMessage;
        socket!.onTLogHandle=socketlog;
    }
    deinit
    {
        //NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    func socketlog(log:String) -> Void {
        LogSocket("%@",args: log);
    }
    //开启socket 连接
    func startConnectSocket(host:String,mport:Int,timeOut:NSTimeInterval=0)->Void
    {
        socket!.onConnectSocket(host, port: mport, timeOut: timeOut){
            [weak self] in
            self!.sendMessage(S_msg_base(_cmd: 10000));
            self!.socket!.heartMessage = s_msg_heart_9999();
        }
    }
    
    //关闭socket 连接
    func closeSocket()->Void
    {
        socket!.closeSocket();
    }
    


    func sendMessage(message:S_msg_base) -> Void {
        
        socket!.sendMessage(message);
    }


    /**
     socket 消息处理中心
     - author: taven
     - date: 16-06-28 13:06:49
     - parameter message: <#message description#>
     */
    func handleMessage(message: AnyObject) -> Void {
        let json = JSON(message);
        let cmd = json["cmd"].int!;
      let dataCenterM: DataCenterModel = DataCenterModel.sharedInstance;
        LogSocket("reve:<--cmd=%d---%@",args: cmd,json.description);
        switch cmd {
        case MSG_10000://登陆验证
            dataCenterM.roomData!.aeskey = json["limit"].string!;
            let r_msg = r_msg_10000(_data: (dataCenterM.roomData!.key + String(dataCenterM.roomData!.roomId) + "jugg123"), _aesKey: dataCenterM.roomData!.aeskey);
            let s_msge = s_msg_10001(cmd: MSG_10001, _roomId: dataCenterM.roomData!.roomId, _pass: dataCenterM.roomData!.pass, _roomLimit: r_msg.getAesk(), _isPublish: dataCenterM.roomData!.isPublish, _publishUrl: dataCenterM.roomData!.publishUrl, _sid: dataCenterM.roomData!.sid, _key: dataCenterM.roomData!.key);
            sendMessage(s_msge);
        case MSG_10002://进入房间
            let s_8002 = s_msg_noBody(_cmd: MSG_80002);
            sendMessage(s_8002);
            break
        case MSG_80002://获取到播放列表
            
            break;
        case MSG_20001:
            break;
        case MSG_500: //break
            //  var info = json["msg"].string
            break;
        case MSG_11002:
            break
            
        case MSG_30001: break
            
            
        default:
            break
            //print("222");
        }
        
    }

}