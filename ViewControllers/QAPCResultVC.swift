//
//  QAPCResultVC.swift
//  Quizacation
//
//  Created by CedarWaters  on 3/14/16.
//  Copyright © 2016 CedarWaters . All rights reserved.
//

import UIKit
import Alamofire
import EZLoadingActivity
import Foundation

class QAPCResultVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var resultAry = Array<AnyObject>();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let borderColor: CGColorRef = UIColor (colorLiteralRed: 193/255, green: 39/255, blue: 44/255, alpha: 1).CGColor
        self.tableView.layer.borderColor = borderColor
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        submitAndLoadResults()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func submitAndLoadResults () {
        
        var params = [
            "uid" : Common.Data.userId,
            "bid" : Common.Data.blogId,
            "gid" : Common.Data.gameId
        ]
        if Common.Data.startTime == nil {
           params["request_type"] = "4"
        } else {
            params["request_type"] = "3"
            params["qids"] = Common.Data.questionIds
            params["qresults"] = Common.Data.answerStates
            let passedTimeInMS: Int = Int(NSDate().timeIntervalSinceDate(Common.Data.startTime) * 1000)
            params["gtime"] = "\(passedTimeInMS)"
        }
        let urlStr = Common.ApiPointChallengeUrl
        
        EZLoadingActivity.show("Loading...", disableUI: true)
        request(.POST, urlStr, parameters: params)
            .responseJSON { (response) -> Void in
                
                print("Response JSON: \(response.result.value)")
                if let respDict = response.result.value as? Dictionary<String, AnyObject> {
                    let status = respDict["status"] as! Int
                    if status == 0 {
                        let message = respDict["message"] as! String
                        Common.showAlert(message, curVC: self, okHanlder: nil)
                    } else {
                        self.resultAry = respDict["data"] as! Array<AnyObject>
                        EZLoadingActivity.hide(success: true, animated: true)
                    }
                    self.tableView.reloadData()
                }
                EZLoadingActivity.hide()
        }
    }
    
    // TableView Delegate & Datasource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultAry.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PCResultTVCell")
        
        let dict = self.resultAry[indexPath.row] as! Dictionary<String, AnyObject>
        let nameLb = cell?.viewWithTag(11) as! UILabel
        let pointLb = cell?.viewWithTag(12) as! UILabel
        let timeLb = cell?.viewWithTag(13) as! UILabel
        
        nameLb.text = dict["username"] as? String
        pointLb.text = dict["points"] as? String
        let time = dict["time"] as! String
        if !time.isEmpty {
            let timeInSec = Int(round((dict["time"] as! NSString).doubleValue / 1000))
            timeLb.text = String (format: "%02d:%02d", Int(timeInSec / 60), Int(timeInSec % 60))
        } else {
            timeLb.text = ""
        }

        return cell!;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 50;
    }
}
