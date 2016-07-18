//
//  QAHomeVC.swift
//  Quizacation
//
//  Created by CedarWaters  on 3/11/16.
//  Copyright © 2016 CedarWaters . All rights reserved.
//

import UIKit
import EZLoadingActivity
import Alamofire

class QAHomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var welcomeLb: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var _curGames: [[String:AnyObject]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        welcomeLb.text = "Welcome \(Common.Data.userName)"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        Common.Data.reset()
        self.loadCurrentGameList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Events
    
    @IBAction func onNewGameBtn_Pressed(sender: AnyObject) {
        
        if let tabC = self.tabBarController as? QATabBarController {
            if _curGames.count >= 5 {
                Common.showAlert("Please finish a game on your current list or forfeit to start another", curVC: self, okHanlder: nil)
            } else if tabC.getHeartCnt() == 0 {
                Common.showAlert("You don't have any lives to start a new game. Please try back later", curVC: self, okHanlder: nil)
            } else {
                performSegueWithIdentifier("SegueToChoiceScreen", sender: nil)
            }
        }
    }
    
    @IBAction func onCellCloseBtn_Pressed(sender: AnyObject) {
        
        let tag = sender.tag - 100
        let game = _curGames[tag]
        let params = ["uid" : Common.Data.userId,
                      "bid" : Common.Data.blogId,
                      "gid" : game["gid"]!]
        EZLoadingActivity.show("Deleting...", disableUI: true)
        let urlStr = Common.ApiDelete
        request(.POST, urlStr, parameters: params)
            .responseJSON { (response) in
                
                print("Delete Game :\n\(response.result.value)")
                if let respDict = response.result.value as? [String:AnyObject] {
                    let status = respDict["status"] as! Int
                    if status == 0 {
                        let message = respDict["message"] as! String
                        Common.showAlert(message, curVC: self, okHanlder: nil)
                    } else {
                        self._curGames.removeAtIndex(tag)
                        self.tableView.reloadData()
                        EZLoadingActivity.hide(success: true, animated: true)
                    }
                }
                EZLoadingActivity.hide()
        }
    }
    
    // MARK: Public
    
    func loadCurrentGameList() {
    
        let params = ["uid" : Common.Data.userId,
                      "bid" : Common.Data.blogId,
                      "request_type" : "1"]
        EZLoadingActivity.show("Loading...", disableUI: true)
        let urlStr = Common.ApiGameListUrl
        request(.POST, urlStr, parameters: params)
            .responseJSON { (response) in
                
                print("Cur Game List :\n\(response.result.value)")
                if let respDict = response.result.value as? [String:AnyObject] {
                    let status = respDict["status"] as! Int
                    if status == 0 {
                        let message = respDict["message"] as! String
                        Common.showAlert(message, curVC: self, okHanlder: nil)
                    } else {
                        self._curGames = respDict["data"] as! [[String:AnyObject]]
                        self.tableView.reloadData()
                        EZLoadingActivity.hide(success: true, animated: true)
                    }
                }
                EZLoadingActivity.hide()
        }
    }
    
    // MARK: Private
    
    func loadH2HState(gId: String) {
        
        let params = ["uid" : Common.Data.userId,
                      "bid" : Common.Data.blogId,
                      "gid" : gId,
                      "request_type" : "4"]
        EZLoadingActivity.show("Loading...", disableUI: true)
        let urlStr = Common.ApiH2HUrl
        request(.POST, urlStr, parameters: params)
            .responseJSON { (response) in
                
                print("H2H Game State :\n\(response.result.value)")
                if let respDict = response.result.value as? [String:AnyObject] {
                    let status = respDict["status"] as! Int
                    if status == 0 {
                        let message = respDict["message"] as! String
                        Common.showAlert(message, curVC: self, okHanlder: nil)
                    } else {
                        self.moveToH2HSpinScreen(respDict["data"] as! [String:AnyObject])
                    }
                }
                EZLoadingActivity.hide()
        }
    }
    
    func moveToH2HSpinScreen(data: [String:AnyObject]) {
        
        let spinVc = self.storyboard?.instantiateViewControllerWithIdentifier("QAHToHSpinVC") as! QAHToHSpinVC
        spinVc._data = data
        self.navigationController?.pushViewController(spinVc, animated: true)
    }
    
    func moveToQuestionsScreen() {
        
        let questVc = self.storyboard?.instantiateViewControllerWithIdentifier("QAQuestionVC") as! QAQuestionVC
        self.navigationController?.pushViewController(questVc, animated: true)
    }
    
    // MARK: UITableView Delegate & Datasource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return min(_curGames.count, 5)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("HomeTVCell")
        
        let nameLb = cell?.viewWithTag(10) as! UILabel
        let gameIv = cell?.viewWithTag(11) as! UIImageView
        let stateLb = cell?.viewWithTag(12) as! UILabel
        for i in 100...104 {
            if let closeBtn = cell?.viewWithTag(i) {
                closeBtn.tag = indexPath.row + 100
                break
            }
        }
        let game = _curGames[indexPath.row]
        if game["gtype"] as! String == "pc" {
            nameLb.text = "Points Challenge"
            stateLb.text = "WAITING"
            gameIv.image = UIImage(named: "PCSymbol")
        } else if game["gtype"] as! String == "hh" {
            nameLb.text = game["opponent"] as? String
            let isPending = String(game["pending"]!) == "1"
            if game["turn"] as! String == Common.Data.userId {
                stateLb.text = isPending ? "INVITATION" : "YOUR TURN"
                gameIv.image = UIImage(named: "HTHYourTurn")
            } else {
                stateLb.text = isPending ? "WAITING" : "THEIR TURN"
                gameIv.image = UIImage(named: "HTHTheirTurn")
            }
        } else {
            nameLb.text = "Special Quiz"
            gameIv.image = nil
            stateLb.text = "Useless"
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        return tableView.frame.size.height / 5
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let game = _curGames[indexPath.row]
        let gType = game["gtype"] as! String
        if gType == "pc" {
            Common.Data.gameId = game["gid"] as! String
            if game["finished"] as! String == "yes" {
                let resultVc = self.storyboard?.instantiateViewControllerWithIdentifier("QAPCResultVC") as! QAPCResultVC
                self.navigationController?.pushViewController(resultVc, animated: true)
            } else {
                moveToQuestionsScreen()
            }
        } else if gType == "hh"{
            if game["turn"] as! String == Common.Data.userId {
                if String(game["pending"]!) == "1"  {
                    Common.Data.gameId = game["gid"] as! String
                    Common.Data.hthOpptName = game["opponent"] as! String
                    self.performSegueWithIdentifier("SegueToInviteVC", sender: nil)
                } else if let miniGid = game["mini_gid"] as? String {
                    Common.Data.gameId = game["gid"] as! String
                    Common.Data.miniGameId = miniGid
                    Common.Data.gameType = GameType.HHMiniGame
                    moveToQuestionsScreen()
                } else {
                    loadH2HState(game["gid"] as! String)
                }
            }
        }
    }
}
