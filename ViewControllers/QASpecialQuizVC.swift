//
//  QASpecialQuizVC.swift
//  Quizacation
//
//  Created by CedarWaters  on 3/15/16.
//  Copyright © 2016 CedarWaters . All rights reserved.
//

import UIKit
import Alamofire
import EZLoadingActivity

class QASpecialQuizVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var _quizAry: [[String:String]] = []
    var _colorAry: [UIColor] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _colorAry.append(UIColor(colorLiteralRed: 0, green: 166/255, blue: 81/255, alpha: 1))
        _colorAry.append(UIColor(colorLiteralRed: 1, green: 122/255, blue: 0, alpha: 1))
        _colorAry.append(UIColor(colorLiteralRed: 193/255, green: 39/255, blue: 45/255, alpha: 1))
        _colorAry.append(UIColor(colorLiteralRed: 1, green: 172/255, blue: 0, alpha: 1))
        _colorAry.append(UIColor(colorLiteralRed: 116/255, green: 192/255, blue: 70/255, alpha: 1))
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadSpecialQuiz()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadSpecialQuiz () {
        
        let params = [
            "uid": Common.Data.userId,
            "bid" : Common.Data.blogId,
            "request_type" : "1"]
        let urlStr = Common.ApiSpecialQuizUrl
        
        EZLoadingActivity.show("Loading...", disableUI: true)
        request(.POST, urlStr, parameters: params)
            .responseJSON { (response) -> Void in
                
                print("Response JSON: \(response.result.value)")
                if let respDict = response.result.value as? [String:AnyObject] {
                    let status = respDict["status"] as! Int
                    if status == 0 {
                        let message = respDict["message"] as! String
                        Common.showAlert(message, curVC: self, okHanlder: nil)
                    } else {
                        self._quizAry = respDict["data"] as! [[String:String]]
                        self.tableView .reloadData()
                        EZLoadingActivity.hide(success: true, animated: true)
                    }
                }
                EZLoadingActivity.hide()
        }
    }
    
    // UITableView Delegate & Datasource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return _quizAry.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SpecialQuizTVCell")
        
        let valueAry = _quizAry[indexPath.row]
        let quizName = valueAry["name"]
        let authorName = valueAry["author"]
        
        let nameBtn = cell?.viewWithTag(11) as! UIButton
        let authorLb = cell?.viewWithTag(12) as! UILabel
        
        nameBtn.setTitle(quizName, forState: UIControlState.Normal)
        authorLb.text = authorName
        
        let rndValue = random() % 5
        nameBtn.backgroundColor = _colorAry[rndValue]
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 80
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        (self.tabBarController as! QATabBarController).decreaseHeart()
        
        let valueAry = _quizAry[indexPath.row]
        let quizId = valueAry["id"]!
        Common.Data.sqQuizId = quizId
        Common.Data.gameType = GameType.SpecialQuiz
        
        self.performSegueWithIdentifier("SegueToQuestionVC", sender: nil)
    }
}
