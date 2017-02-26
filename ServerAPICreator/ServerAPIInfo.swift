//
//  ServerAPIInfo.swift
//  ServerAPICreator
//
//  Created by Zhao Yiqi on 2017/2/23.
//  Copyright © 2017年 admin. All rights reserved.
//

import Foundation

class ServerAPIInfo: NSObject {
    var apiPath = ""
    var apiAccess = ""
    var apiReturnClass = ""
    var apiHostType = ""
    var apiName = ""
    var apiS1 = false
    var apiS2 = false
    var apiRetryTimes = ""
    var apiTimeOut = ""
    var apiAction = ""
    var apiParamters = Array<APIParameterInfo>()
    var apiError = ""
    
}

class APIParameterInfo: NSObject {
    var parameterName = ""
    var parameterRequired = false
    var parameterDefault = ""
    var parameterExtra = ""
}
