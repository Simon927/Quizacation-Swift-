//
//  QAFinishedGamesVC.swift
//  Quizacation
//
//  Created by CedarWaters  on 3/16/16.
//  Copyright © 2016 CedarWaters . All rights reserved.
//

import UIKit
import Alamofire
import EZLoadingActivity

class QAFinishedGamesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var _finishedGames: [[String:AnyObject]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadFinishedGameList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadFinishedGameList() {
        
        let params = ["uid" : Common.Data.userId,
                      "bid" : Common.Data.blogId,
                      "request_type" : "2"]
        EZLoadingActivity.show("Loading...", disableUI: true)
        let urlStr = Common.ApiGameListUrl
        request(.POST, urlStr, parameters: params)
            .responseJSON { (response) in
                
                print("Finished Games List :\n\(response.result.value)")
                if let respDict = response.result.value as? [String:AnyObject] {
                    let status = respDict["status"] as! Int
                    if status == 0 {
                        let message = respDict["message"] as! String
                        Common.showAlert(message, curVC: self, okHanlder: nil)
                    } else {
                        self._finishedGames = respDict["data"] as! [[String:AnyObject]]
                        self.tableView.reloadData()
                        EZLoadingActivity.hide(success: true, animated: true)
                    }
                }
                EZLoadingActivity.hide()
        }
    }
    
    // MARK: - UITableView Delegate & Datasource -
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self._finishedGames.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FinishedGamesTVCell")
        let nameLb = cell?.viewWithTag(10) as! UILabel
        let stateLb = cell?.viewWithTag(11) as! UILabel
        let game = _finishedGames[indexPath.row];
        let gType = game["gtype"] as! String
        if gType == "pc" {
            nameLb.text = "Points Challenge"
            stateLb.text = game["user_rank"] as? String
        } else if gType == "hh" {
            nameLb.text = game["opponent"] as? String
            stateLb.text = game["results"] as? String
        } else if gType == "sq" {
            nameLb.text = game["quiz_name"] as? String
            stateLb.text = "DONE"
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 45
    }
}
