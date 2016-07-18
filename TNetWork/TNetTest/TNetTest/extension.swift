//
//  extension.swift
//  TNetTest
//
//  Created by 张新华 on 16/7/13.
//  Copyright © 2016年 张新华. All rights reserved.
//

import NSLogger

func LogSocket(format: String!, args: CVarArgType...) {
    LogMessage_va("socket", 3, format, getVaList(args))
}

func LogHttp(format: String!, args: CVarArgType...) {
    LogMessage_va("Http", 3, format, getVaList(args))
}

func LogMessage(domain: String!, level: Int32, format: String!, args: CVarArgType...) {
    LogMessage_va(domain, level, format, getVaList(args))
}

func LogMessageF(filename: UnsafePointer<Int8>, lineNumber: Int32, functionName: UnsafePointer<Int8>, domain: String!, level: Int32, format: String!, args: CVarArgType...) {
    LogMessageF_va(filename, lineNumber, functionName, domain, level, format, getVaList(args))
}

func LogMessageTo(logger:COpaquePointer ,domain: String!, level: Int32, format: String!, args: CVarArgType...) {
    LogMessageTo_va(logger, domain, level, format, getVaList(args))
}


func LogMessageToF(logger: COpaquePointer, filename: UnsafePointer<Int8>, lineNumber: Int32, functionName: UnsafePointer<Int8>, domain: String!, level: Int32, format: String!, args: CVarArgType...) {
    LogMessageToF_va(logger, filename, lineNumber, functionName, domain, level, format, getVaList(args))
}
