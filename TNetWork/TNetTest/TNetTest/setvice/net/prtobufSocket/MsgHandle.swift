//
//  MsgDictionary.swift
//  TNetTest
//
//  Created by 张新华 on 16/7/15.
//  Copyright © 2016年 张新华. All rights reserved.
//

import Foundation
import TProbufSocket
import ProtocolBuffers

class PrtobufMsgDiconary {
    
    static var msgDico=[Int:AnyClass]();
    
    
    class func regInitMessageDiction(){
        
       msgDico[1]=Person.self;
       msgDico[2]=Person.self;
       msgDico[3]=Person.self;
       msgDico[4]=Person.self;
       msgDico[5]=Person.self;
    }
    
    class func regMessageByMsgId(msgId:Int,cls:AnyClass){
        msgDico[msgId]=cls;
        return
    }

    class func unRegMessageByMsgId(msgId:Int){
        if(msgDico[msgId] != nil){
            msgDico.removeValueForKey(msgId);
        }
    }
    
    class func getMessageByMsgId(msgId:Int) -> AnyObject
    {
        if(msgDico[msgId] != nil){
            let classType = msgDico[msgId] as! GeneratedMessage.Type ;
            let message=classType.init();
            let msg = message ;
            return msg.classBuilder()
            
        }
    
        return NSNull();
    }
}

