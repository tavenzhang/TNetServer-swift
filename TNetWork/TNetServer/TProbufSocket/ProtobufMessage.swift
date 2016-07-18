//
//  ProtobufMessage.swift
//  TNetServer
//
//  Created by 张新华 on 16/7/14.
//  Copyright © 2016年 张新华. All rights reserved.
//

import Foundation
import ProtocolBuffers

public class MsgProbufBase {
    
 
  public   var msgId:Int = 0;
    
  public  var dataMessage:GeneratedMessageBuilder?;
    
  public convenience init(mid:Int,data:GeneratedMessageBuilder){
        self.init();
        msgId = mid;
        dataMessage = data;

    }

    
}