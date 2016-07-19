//
//  RMessages.swift
//  TVideo
//
//  Created by 张新华 on 16/6/1.
//  Copyright © 2016年 张新华. All rights reserved.
//

import Foundation

func getKeysArray(anyClass:AnyClass)->[String]
{
    var count: UInt32 = 0
    var keyArr=[String]();
    let properties = class_copyPropertyList(anyClass, &count)
    for i in 0..<count {
        let property = properties[Int(i)]
        // 属性名称
        let cname = property_getName(property)
        let name = String.fromCString(cname)!
        keyArr.append(name);
    }
    free(properties)
    return keyArr;
}


public class R_msg_base:NSObject {
    
   public var cmd:Int=0;
    
}


public class S_msg_base:NSObject {
    
   public  var cmd:Int=0;
   public init(_cmd:Int) {
        cmd = _cmd;
    }
    
 public  func toDictionary() ->  NSDictionary {
        // 拷贝属性列表 用于转化成 dictionary
        var keyArr = getKeysArray(self.classForCoder);
        if keyArr.indexOf("cmd") == nil
        {
            keyArr.append("cmd");
        }
        return self.dictionaryWithValuesForKeys(keyArr);
    }
}

