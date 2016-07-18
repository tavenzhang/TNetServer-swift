//
//  NSMudatableDataExtension.swift
//  TVideo
//
//  Created by 张新华 on 16/5/31.
//  Copyright © 2016年 张新华. All rights reserved.

import Foundation

//对于需要在网络传输中传输负数的情况需要先把负数的Int转换为无符号的整数UInt.在计算机中,负数的表示方法是采用补码的形式.在swift中,可以使用UInt32(bitPattern:Int32)以及Int32(bitPattern:UInt32)方法来相互的转换.比如,-5转换为无符号的补码形式为:fffffffb
public extension NSMutableData {
    public var isNativeBigEndian:Bool { return NSHostByteOrder() == NS_BigEndian}

    //整型
    public func appendShort(value:Int,isBigEndian:Bool=true){
        let networkOrderVal = UInt16(value);
        var data = isBigEndian ? networkOrderVal.bigEndian : networkOrderVal.littleEndian;
        self.appendBytes(&data, length: sizeof(UInt16));
    }
    
    public func appendInt(value:Int,isBigEndian:Bool=true){
        let networkOrderVal = UInt32(value)
        var data = isBigEndian ? networkOrderVal.bigEndian : networkOrderVal.littleEndian;
        self.appendBytes(&data, length: sizeof(UInt32));
    }
    
    public func appendUInt64(value:Int,isBigEndian:Bool=true) {
        let networkOrderVal = UInt64(value)
        var data = isBigEndian ? networkOrderVal.bigEndian : networkOrderVal.littleEndian;
        self.appendBytes(&data, length: sizeof(UInt64));
    }
 
    public func getShort(isBigEndian:Bool=true) -> Int {
        let range:NSRange = NSRange(location:0,length:sizeof(UInt16))
        var val: UInt16 = 0
        self.getBytes(&val, range: range);
        self.replaceBytesInRange(range, withBytes: nil, length: 0)
        return  isBigEndian ? Int(val.bigEndian):Int(val.littleEndian);
    }
    
    public func getInt32(isBigEndian:Bool=true) -> Int {
        var val: Int32 = 0
        let range = NSRange(location:0,length:sizeof(Int32));
        self.getBytes(&val, range: range)
        self.replaceBytesInRange(range, withBytes: nil, length: 0)
        return isBigEndian ? Int(val.bigEndian):Int(val.littleEndian);
    }
    
    
    public func getUInt32(isBigEndian:Bool=true) -> Int {
        var val: UInt32 = 0
        let range = NSRange(location:0,length:sizeof(UInt32));
        self.getBytes(&val, range: range)
        self.replaceBytesInRange(range, withBytes: nil, length: 0)
        return isBigEndian ? Int(val.bigEndian):Int(val.littleEndian);
    }
    
    public func getUInt64(isBigEndian:Bool=true) -> UInt64 {
        let range:NSRange = NSRange(location:0,length:sizeof(UInt64))
        var val: UInt64 = 0
        self.getBytes(&val, range: range)
        self.replaceBytesInRange(range, withBytes: nil, length: 0)
        return isBigEndian ? val.bigEndian : val.littleEndian
    }
    
    //浮点型 fload 4 字节
    public func appendFloat(value:Float,isBigEndian:Bool=true) {
        
        if((isBigEndian && (!isNativeBigEndian)) || (!isBigEndian && isNativeBigEndian))
        {
            var networkOrderVal = CFConvertFloat32HostToSwapped(Float32(value))
            self.appendBytes(&networkOrderVal, length: sizeof(Float32));
        }
        else{
            var data = value;
            self.appendBytes(&data, length: sizeof(Float32))
        }
      
    }
      //浮点型 double 8 字节
    public func appendDouble(value:Double,isBigEndian:Bool=true) {
        if((isBigEndian && (!isNativeBigEndian)) || (!isBigEndian && isNativeBigEndian))
        {
            var networkOrderVal = CFConvertFloat64HostToSwapped(Float64(value))
            self.appendBytes(&networkOrderVal, length: sizeof(Float64));
        }
        else{
            var data = value;
            self.appendBytes(&data, length: sizeof(Float64))
        }
    }
    
    
    public func getFloat() -> Float {
        let range:NSRange = NSRange(location:0,length:sizeof(Float32))
        var val: CFSwappedFloat32 = CFSwappedFloat32(v: 0)
        self.getBytes(&val, range: range)
        let result = CFConvertFloat32SwappedToHost(val)
        self.replaceBytesInRange(range, withBytes: nil, length: 0)
        return result;
    }
    
    public func getDouble() -> Double {
        let  range:NSRange = NSRange(location:0,length:sizeof(Float64))
        var val: CFSwappedFloat64 = CFSwappedFloat64(v: 0)
        self.getBytes(&val, range: range)
        let result = CFConvertFloat64SwappedToHost(val)
        self.replaceBytesInRange(range, withBytes: nil, length: 0)
        return result
    }
    
    
    
    // MARK: Bool
    public func appendBool(val:Bool){
        var data = val;
        self.appendBytes(&data, length: sizeof(Bool))
    }
    
    public func getBool() -> Bool {
        let  range:NSRange = NSRange(location:0,length:sizeof(Bool))
        var val:Bool = false
        self.getBytes(&val, range: range)
        self.replaceBytesInRange(range, withBytes: nil, length: 0)
        return val
    }
    
    
    // MARK: String
    public func appendString(val:String, isBigEndian:Bool=true,encoding:NSStringEncoding = NSUTF8StringEncoding){
        //获取到字节的长度,使用某一种编码
        let pLength : Int = val.lengthOfBytesUsingEncoding(encoding)
        
        //放入字符串的长度
        self.appendInt(pLength,isBigEndian: isBigEndian)
        
        //把字符串按照某种编码转化为字节数组
        let data = val.dataUsingEncoding(encoding)
        
        //放入NSData中
        self.appendData(data!);
    }
    
    enum AppException: ErrorType {
        case Empty
        case FormatCastStringException
    }
    
    
    public func getString(isBigEndian:Bool=true,encoding:NSStringEncoding = NSUTF8StringEncoding) throws -> String{
        
        //先获取到长度
        let len = self.getInt32(isBigEndian);
        
        let range = NSRange(location: 0, length: len)
        //找到子字节数组
        let subData = self.subdataWithRange(range);
        
        //直接使用String的构造函数,采用某种编码格式获取字符串
        let resutString = String(data: subData, encoding: encoding)
        
        //如果凑不起字符串,就表示数据不正确,那么就抛出异常
        guard resutString != nil else {
            throw AppException.FormatCastStringException;
        }
        self.replaceBytesInRange(range, withBytes: nil, length: 0)
        //返回结果
        return resutString!;
    }
    
     //截取字节数组
    public func getBytesByLength(len:Int,location:Int = 0)->NSMutableData
    {
       
        let nsRange=NSRange(location: location, length: len);
        let subData = self.subdataWithRange(nsRange);
        self.replaceBytesInRange(nsRange, withBytes: nil, length: 0);
        let nsMuData = NSMutableData(data: subData)
        return nsMuData;
    }
}


extension String {
    
    var parseJSONString: AnyObject? {
        
        let data = self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        if let jsonData = data {
            // Will return an object or nil if JSON decoding fails
            return try! NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers)
        } else {
            // Lossless conversion of the string was not possible
            return nil
        }
    }
}