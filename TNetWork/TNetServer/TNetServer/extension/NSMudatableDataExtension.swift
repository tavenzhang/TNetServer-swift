//
//  NSMudatableDataExtension.swift
//  TVideo
//
//  Created by 张新华 on 16/5/31.
//  Copyright © 2016年 张新华. All rights reserved.

import Foundation

//对于需要在网络传输中传输负数的情况需要先把负数的Int转换为无符号的整数UInt.在计算机中,负数的表示方法是采用补码的形式.在swift中,可以使用UInt32(bitPattern:Int32)以及Int32(bitPattern:UInt32)方法来相互的转换.比如,-5转换为无符号的补码形式为:fffffffb
public extension NSMutableData {
    //整型
    public func appendInt(value:Int){
        var networkOrderVal = UInt32(value).bigEndian;
        self.appendBytes(&networkOrderVal, length: sizeof(UInt32))
    }
    
    public func appendLong(value:Int) {
        var networkOrderVal = UInt64(value).bigEndian;
        self.appendBytes(&networkOrderVal, length: sizeof(UInt64))
    }
    
    public func getShort(range:NSRange = NSRange(location:0,length:sizeof(UInt16))) -> Int {
        var val: UInt16 = 0
        self.getBytes(&val, range: range);
        self.replaceBytesInRange(range, withBytes: nil, length: 0)
        return Int(Int32(bitPattern:UInt32(val.bigEndian)));
    }
    
    
    public func getInt(range:NSRange = NSRange(location:0,length:sizeof(UInt32))) -> Int {
        var val: UInt32 = 0
        self.getBytes(&val, range: range)
                self.replaceBytesInRange(range, withBytes: nil, length: 0)
        return Int(Int32(bitPattern:val.bigEndian))
    }
    
    public func getLong(range:NSRange = NSRange(location:0,length:sizeof(UInt64))) -> Int {
        var val: UInt64 = 0
        self.getBytes(&val, range: range)
        self.replaceBytesInRange(range, withBytes: nil, length: 0)
        return Int(Int64(bitPattern:val.bigEndian))
    }
    
    //浮点型
    public func appendFloat(value:Float) {
        var networkOrderVal = CFConvertFloat32HostToSwapped(Float32(value))
        self.appendBytes(&networkOrderVal, length: sizeof(Float32))
    }
    
    public func appendDouble(value:Double) {
        var networkOrderVal = CFConvertFloat64HostToSwapped(Float64(value))
        self.appendBytes(&networkOrderVal, length: sizeof(Float64))
    }
    
    
    public func getFloat(range:NSRange = NSRange(location:0,length:sizeof(Float32))) -> Float {
        
        var val: CFSwappedFloat32 = CFSwappedFloat32(v: 0)
        self.getBytes(&val, range: range)
        let result = CFConvertFloat32SwappedToHost(val)
        self.replaceBytesInRange(range, withBytes: nil, length: 0)
        return result
    }
    
    public func getDouble(range:NSRange = NSRange(location:0,length:sizeof(Float64))) -> Double {
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
    
    public func getBool(range:NSRange = NSRange(location:0,length:sizeof(Bool))) -> Bool {
        var val:Bool = false
        self.getBytes(&val, range: range)
        self.replaceBytesInRange(range, withBytes: nil, length: 0)
        return val
    }
    
    
    // MARK: String
    public func appendString(val:String,encoding:NSStringEncoding = NSUTF8StringEncoding){
        
        //获取到字节的长度,使用某一种编码
        let pLength : Int = val.lengthOfBytesUsingEncoding(encoding)
        
        //放入字符串的长度
        self.appendInt(pLength)
        
        //把字符串按照某种编码转化为字节数组
        let data = val.dataUsingEncoding(encoding)
        
        //放入NSData中
        self.appendData(data!)
    }
    
    enum AppException: ErrorType {
        case Empty
        case FormatCastStringException
    }
    
    public func getString(location:Int = 0,encoding:NSStringEncoding = NSUTF8StringEncoding) throws -> (String,Int){
        
        //先获取到长度
        let len = self.getInt(NSRange(location:location,length:sizeof(UInt32)))
    
        //找到子字节数组
        let subData = self.subdataWithRange(NSRange(location: location+sizeof(UInt32), length: len))
        
        //直接使用String的构造函数,采用某种编码格式获取字符串
        let string = String(data: subData, encoding: encoding)
        
        //如果凑不起字符串,就表示数据不正确,那么就抛出异常
        guard let _string = string else {
            throw AppException.FormatCastStringException;
        }
        let newRange = NSRange(location: location, length: len+sizeof(UInt32));
        self.replaceBytesInRange(newRange, withBytes: nil, length: 0)
        //返回结果
        return (_string,len+sizeof(UInt32))
    }
    
     //截取字节数组
    public func getBytesByLength(len:Int,location:Int = 0)->NSData
    {
       
        let nsRange=NSRange(location: location, length: len);
        let subData = self.subdataWithRange(nsRange);
        self.replaceBytesInRange(nsRange, withBytes: nil, length: 0);
        return subData;
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