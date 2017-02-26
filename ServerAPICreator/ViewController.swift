//
//  ViewController.swift
//  ServerAPICreator
//
//  Created by admin on 2017/2/20.
//  Copyright © 2017年 admin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController ,NSTextFieldDelegate,NSTableViewDataSource,NSTableViewDelegate{

    var data:[ServerAPIInfo] = Array();

    var parameterdata:[APIParameterInfo] = Array();
    
    @IBOutlet weak var txtRetrytimes: NSTextField!
    @IBOutlet weak var txtTimeout: NSTextField!
    @IBOutlet weak var txtAPIName: NSTextField!
    @IBOutlet weak var cobBaseAPI: NSComboBox!
    @IBOutlet weak var txtReturnClass: NSTextField!
    @IBOutlet weak var cobAPIAccess: NSComboBox!
    @IBOutlet weak var txtAPIPath: NSTextField!
    @IBOutlet weak var txtAction: NSTextField!
    @IBOutlet weak var table: NSTableView!
    @IBOutlet weak var btnS1: NSButton!
    @IBOutlet weak var parameterTable: NSTableView!
    @IBOutlet weak var btnS2: NSButton!
    @IBOutlet weak var txtParameter: NSTextField!
    @IBOutlet weak var btnRequire: NSButton!
    @IBOutlet weak var txtDefault: NSTextField!
    @IBOutlet weak var txtDiscrib: NSTextField!
    @IBOutlet weak var txtError: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnAddClick(_ sender: Any) {
        let serverApi = ServerAPIInfo()
        serverApi.apiPath=txtAPIPath.stringValue
        serverApi.apiAccess=cobAPIAccess.stringValue
        serverApi.apiReturnClass=txtReturnClass.stringValue
        serverApi.apiHostType=cobBaseAPI.stringValue
        serverApi.apiName=txtAPIName.stringValue
        serverApi.apiS1 = btnS1.state==NSOnState
        serverApi.apiS2 = btnS2.state==NSOnState
        serverApi.apiRetryTimes=txtRetrytimes.stringValue
        serverApi.apiTimeOut=txtTimeout.stringValue
        serverApi.apiAction=txtAction.stringValue
        serverApi.apiParamters=parameterdata
        serverApi.apiError=txtError.stringValue
        data.append(serverApi)

        parameterdata.removeAll()
        table.reloadData()
        parameterTable.reloadData()
        
        txtAction.stringValue=""
        txtTimeout.stringValue=""
        txtRetrytimes.stringValue=""
        btnS2.state=NSOffState
        btnS1.state=NSOnState
        txtAPIName.stringValue=""
        cobBaseAPI.stringValue="api"
        txtReturnClass.stringValue=""
        cobAPIAccess.stringValue=""
        txtAPIPath.stringValue=""
        txtError.stringValue=""
        print("添加")

    }
    @IBAction func btnDeleteClick(_ sender: Any) {
        if data.count<table.selectedRow || table.selectedRow<0 {
            return
        }
        data.remove(at: table.selectedRow)
        table.reloadData()
        parameterTable.reloadData()
        print("删除")

    }
    @IBAction func btnAddParameterClick(_ sender: Any) {
        let apiParameter = APIParameterInfo()
        apiParameter.parameterName = txtParameter.stringValue
        apiParameter.parameterRequired = btnRequire.state==NSOnState
        apiParameter.parameterExtra = txtDiscrib.stringValue
        apiParameter.parameterDefault = txtDefault.stringValue
        parameterdata.append(apiParameter)
        parameterTable.reloadData()
        txtParameter.stringValue=""
        btnRequire.state=NSOffState
        txtDiscrib.stringValue=""
        txtDefault.stringValue=""
    }
    @IBAction func btnDelParameterClick(_ sender: Any) {
        if parameterdata.count<parameterTable.selectedRow || parameterTable.selectedRow<0 {
            return
        }
        parameterdata.remove(at: parameterTable.selectedRow)
        parameterTable.reloadData()
    }
    @IBAction func btnCreateClick(_ sender: Any) {
        
        let opanel = NSOpenPanel()
        opanel.canChooseFiles=false
        opanel.canChooseDirectories=true
        opanel.allowsMultipleSelection=false

        if opanel.runModal()==NSModalResponseOK {
            let outputPath=opanel.urls[0].path;
            var wikiString = ""
            
            
            for serverApi in data {
                var baseAPIString = ""
                
                if serverApi.apiHostType=="api" {
                    baseAPIString="BaseServerAPI"
                }
                else if serverApi.apiHostType=="shopapi"{
                    baseAPIString="BaseB2CServerAPI"
                }
                
                var hString=""
                if !serverApi.apiAction.isEmpty {
                    hString+="//"
                    hString+="\n"
                    hString+="//"
                    hString+=serverApi.apiAction
                    hString+="\n"
                    hString+="//"
                    hString+="\n"
                    hString+="\n"
                }
                hString=hString.appendingFormat("#import \"%@.h\"", baseAPIString)
                hString+="\n"
                hString+="\n"
                hString=hString.appendingFormat("@interface %@ : %@", serverApi.apiName,baseAPIString)
                hString+="\n"
                hString+="\n"
                hString+="@end"
                
                do {
                    try hString.write(toFile: outputPath.appendingFormat("/%@.h", serverApi.apiName), atomically: false, encoding: String.Encoding.utf8)
                }
                catch {
                    print("error")
                }
                
                print(hString)
                
                
                var mString = ""
                mString=mString.appendingFormat("#import \"%@.h\"", serverApi.apiName)
                mString+="\n"
                mString+="\n"
                mString=mString.appendingFormat("@implementation %@ ", serverApi.apiName)
                mString+="\n"
                mString+="\n"
                mString+="-(Class)returnClass{"
                mString+="\n"
                mString=mString.appendingFormat("   return NSClassFromString(@\"%@\");", serverApi.apiReturnClass)
                mString+="\n"
                mString+="}"
                mString+="\n"
                mString+="\n"
                mString+="-(NSString*)requestPath{"
                mString+="\n"
                mString=mString.appendingFormat("   return %@;", serverApi.apiPath)
                mString+="\n"
                mString+="}"
                mString+="\n"
                if !serverApi.apiAccess.isEmpty {
                    var accessString = ""
                    
                    switch serverApi.apiAccess {
                    case "PostJson":
                        accessString="APIAccessType_PostJSON"
                    case "Post":
                        accessString="APIAccessType_Post"
                    case "Get":
                        fallthrough
                    default:
                        accessString="APIAccessType_Get"
                    }
                    mString+="\n"
                    mString+="-(APIAccessType)accessType{"
                    mString+="\n"
                    mString=mString.appendingFormat("   return %@;", accessString)
                    mString+="\n"
                    mString+="}"
                    mString+="\n"
                }
                if !(serverApi.apiAccess=="PostJson"||(serverApi.apiS1 && !serverApi.apiS2)) {
                    mString+="\n"
                    mString+="-(BOOL)needS1{"
                    mString+="\n"
                    mString=mString.appendingFormat("   return %@;", (serverApi.apiS1 ? "YES" : "NO"))
                    mString+="\n"
                    mString+="}"
                    mString+="\n"
                    
                    mString+="\n"
                    mString+="-(BOOL)needS2{"
                    mString+="\n"
                    mString=mString.appendingFormat("   return %@;", (serverApi.apiS2 ? "YES" : "NO"))
                    mString+="\n"
                    mString+="}"
                    mString+="\n"
                }
                
                if !serverApi.apiRetryTimes.isEmpty {
                    mString+="\n"
                    mString+="-(NSInteger)retryTimes{"
                    mString+="\n"
                    mString=mString.appendingFormat("   return %@;", serverApi.apiRetryTimes)
                    mString+="\n"
                    mString+="}"
                    mString+="\n"
                }
                
                if !serverApi.apiTimeOut.isEmpty {
                    mString+="\n"
                    mString+="-(NSTimeInterval)timeOut{"
                    mString+="\n"
                    mString=mString.appendingFormat("   return %@;", serverApi.apiTimeOut)
                    mString+="\n"
                    mString+="}"
                    mString+="\n"
                }
                
                mString+="\n"
                mString+="@end"
                
                do {
                    try mString.write(toFile: outputPath.appendingFormat("/%@.m", serverApi.apiName), atomically: false, encoding: String.Encoding.utf8)
                }
                catch {
                    print("error")
                }
                
                print(mString)
                
                wikiString=wikiString.appendingFormat("###%@", serverApi.apiAction)
                wikiString+="\n"
                var tmpApiAccess = serverApi.apiAccess.uppercased()
                if tmpApiAccess.isEmpty {
                    if serverApi.apiHostType=="api" {
                        tmpApiAccess="Get"
                    }
                    if serverApi.apiHostType=="shopapi" {
                        tmpApiAccess="PostJson"
                    }
                }
                
                wikiString=wikiString.appendingFormat("* %@: `%@`", tmpApiAccess,serverApi.apiPath)
                wikiString+="\n"
                wikiString+="* 参数："
                wikiString+="\n"
                wikiString+="\n"
                wikiString+="\n     | name | required | default | extra |"
                wikiString+="\n     | ----- | ----- | ----- | ----- |"
                for parameter in serverApi.apiParamters {
                    wikiString=wikiString.appendingFormat("\n     | %@ | %@ | %@ | %@ |", parameter.parameterName,(parameter.parameterRequired ? "Y" : "N"),parameter.parameterDefault,parameter.parameterExtra)
                }
                var errorArr = Array<String>()
                if serverApi.apiError.contains(",") {
                    errorArr=serverApi.apiError.components(separatedBy: ",")
                }
                if serverApi.apiError.contains("，") {
                    errorArr=serverApi.apiError.components(separatedBy: "，")
                }
                wikiString+="\n* ERROR: "
                for errorString in errorArr {
                    if !errorString.contains("`") {
                        wikiString=wikiString.appendingFormat("`%@`,", errorString)
                    }
                    else{
                        wikiString=wikiString.appendingFormat("%@,", errorString)
                    }
                }
                if wikiString.hasSuffix(",") {
                    wikiString.remove(at: wikiString.index(before: wikiString.endIndex))
                }
                
                wikiString+="\n"
                wikiString=wikiString.appendingFormat("* RETURN: %@", serverApi.apiReturnClass)
                wikiString+="\n"
                wikiString+="\n"
                wikiString+="\n"
                
                
            }
            
            do {
                try wikiString.write(toFile: outputPath+"/wiki.md", atomically: false, encoding: String.Encoding.utf8)
            }
            catch {
                print("error")
            }

            print(wikiString)

            print("生成")

        }

        

    }
    override func controlTextDidChange(_ obj: Notification) {
        let control = obj.object as! NSControl
        if control == txtAPIPath {
            var tmptext = txtAPIPath.stringValue.replacingOccurrences(of: "api/", with: "")
            if let index=tmptext.range(of: "?")?.lowerBound{
                tmptext=tmptext.substring(to: index)
            }
            let tmpArr = tmptext.components(separatedBy: "/")
            tmptext = ""
            
            for subTxt in tmpArr {
                tmptext+=subTxt.capitalized
            }
            txtAPIName.stringValue=tmptext+"API"

        }
        if control == txtRetrytimes||control == txtTimeout {
            let formatter = NumberFormatter();
            formatter.numberStyle=NumberFormatter.Style.decimal;
            formatter.maximum=999
            formatter.minimum=0
            control.formatter=formatter
            
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView==table {
            return data.count
        }
        if tableView==parameterTable {
            return parameterdata.count
        }
        return 0
    }
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if tableView==table {
            return data[row]
        }
        if tableView==parameterTable {
            return parameterdata[row]
        }

        return nil
    }
    func tableViewSelectionDidChange(_ notification: Notification) {
        let control = notification.object as! NSTableView

        if control.selectedRow>=0 {
            if control == table {
                parameterdata = data[control.selectedRow].apiParamters
                parameterTable.reloadData()
            }
            else if control == parameterTable {
                
            }
        }
    }
    
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

