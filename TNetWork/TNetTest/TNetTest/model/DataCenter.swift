//
//  DataProxy.swift
//  TVideo
//
//  Created by 张新华 on 16/6/1.
//  Copyright © 2016年 张新华. All rights reserved.
//

import Foundation
import SwiftyJSON

class BaseDeSerialsModel:NSObject{
    init(json:NSDictionary) {
        super.init();
        let modelTool = DictModelManager.sharedManager
        modelTool.objectWithDictionary(json, cls: self.classForCoder);
    }
  override  init() {
        super.init();
    }
    
    static func objectsWithArray(array:NSArray,cls:AnyClass)->NSArray?
    {
        let modelTool = DictModelManager.sharedManager
        let arr = modelTool.objectsWithArray(array, cls:cls);
        return arr
    }
    
}
//数据管理中心
class DataCenterModel {
    
    internal static let sharedInstance = DataCenterModel()
    private init() {
        roomData = RoomData();
    }
    
    //主页数据；
    var homeData: HomeData?;
    //房间内数据
    var roomData:RoomData?;
    
    
}