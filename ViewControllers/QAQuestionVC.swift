//
//  QAQuestionVC.swift
//  Quizacation
//
//  Created by CedarWaters  on 3/15/16.
//  Copyright © 2016 CedarWaters . All rights reserved.
//

import UIKit
import Alamofire
import EZLoadingActivity

class QAQuestionVC: UIViewController {
    
    // MARK: - Outlets & Variables -
    
    @IBOutlet weak var backgroundIv: UIImageView!
    @IBOutlet weak var _subjectIv: UIImageView!
    @IBOutlet weak var _subjectLb: UILabel!
    @IBOutlet weak var _timeLb: UILabel!
    @IBOutlet weak var questionLB: UILabel!
    internal var questionIdx: Int = -1
    var gameType = GameType.PointChallenge
    var timer: NSTimer!
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.gameType = Common.Data.gameType
        if self.gameType == GameType.SpecialQuiz {
            backgroundIv.image = UIImage(named: "SpecialQuizBg")
            questionLB.textColor = UIColor.whiteColor()
        } else if isHHGame() && !Common.Data.hthSubjName.isEmpty {
//            backgroundIv.hidden = true
//            setBackgroundColor(Common.Data.hthSubjName)
        }
        if UIDevice.currentDevice().model.containsString("iPad") {
            questionLB.font = UIFont(name: questionLB.font.fontName, size: 16)
            for i in 11...14 {
                let btn = self.view.viewWithTag(i) as! UIButton
                btn.titleLabel!.font = UIFont(name: btn.titleLabel!.font!.fontName, size: 16)
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if questionIdx < 0 {
            Common.Data.startTime = NSDate()
            self.loadQuestions()
        }
        self.fillContents(questionIdx)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Events -
    
    func onTimer() {
        
        let time = setTimeValue(false)
        if isHHGame() {
            if time == 5 {
                _timeLb.textColor = UIColor.redColor()
            } else if time == 0 {
                onAnswerBtn_Pressed(nil)
            }
        }
    }
    
    @IBAction func onAnswerBtn_Pressed(sender: AnyObject?) {
        
        stopTimer()
        let dict = Common.Data.questions[questionIdx] as! [String: AnyObject]
        let correctNum = dict["correctNum"] as! Int
        var earnedPt = 0
        if sender != nil {
            let btn = sender as! UIButton
            if (correctNum != btn.tag - 11) {
                Common.Data.answerStates += "0,"
                btn.backgroundColor = UIColor (colorLiteralRed: 193 / 255, green: 39 / 255, blue: 45 / 255, alpha: 1)
                btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            } else {
                earnedPt = 1
                Common.Data.answerStates += "1,"
            }
        } else {
            Common.Data.answerStates += "0,"
        }
        let point = dict["questPoints"] as! String
        if point != "" {
            Common.Data.questPoints += point + ","
            if earnedPt == 1 {
                earnedPt = Int(point)!
            }
        }
        Common.Data.earnedPoints += earnedPt
        let correctBtn = self.view.viewWithTag(correctNum + 11) as! UIButton
        correctBtn.backgroundColor = UIColor (colorLiteralRed: 0, green: 166 / 255, blue: 81 / 255, alpha: 1)
        correctBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        self.presentNextQuestionVC()
    }
    
    // MARK: - Private -
    
    func fillContents (idx: Int) {
        
        if (idx < 0 || Common.Data.questions.count == 0) {
            self.questionLB.text = ""
            self._timeLb.text = ""
            setSubject("")
            for i in 11...14 {
                let btn = self.view.viewWithTag(i) as! UIButton
                btn.backgroundColor = UIColor.whiteColor()
                btn.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
                btn.setTitle("", forState: UIControlState.Normal)
                btn.hidden = true
            }
        } else {
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(QAQuestionVC.onTimer), userInfo: nil, repeats: true)
            let dict = Common.Data.questions[idx] as! [String: AnyObject]
            Common.Data.questionIds += "\(dict["questionID"] as! String),"
            self.questionLB.text = dict["question"] as? String
            let subj = dict["subject"] as! String
            setSubject(subj.capitalizedString)
//            setBackgroundColor(subj)
            setTimeValue(true)
            let answers = dict["answers"] as! NSArray
            for i in 11...14 {
                let btn = self.view.viewWithTag(i) as! UIButton
                btn.backgroundColor = UIColor.whiteColor()
                btn.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
                btn.setTitle(answers.objectAtIndex(i-11) as? String, forState: UIControlState.Normal)
                btn.hidden = false
            }
        }
    }
    
    func setTimeValue(isInit: Bool) -> Int {
        
        var value = 0
        if isInit {
            value = isHHGame() ? 30 : 0
        } else {
            value = Int(_timeLb.text!)!
            value += isHHGame() ? -1 : 1
        }
        _timeLb.text = "\(value)"
        return value
    }
    
    func isHHGame() -> Bool {
        return (self.gameType == GameType.HeadToHead) ||
            (self.gameType == GameType.HHMiniGame)
    }
    
    func setBackgroundColor(subj: String) {
        
        self.view.backgroundColor = QASubjColorDict[subj];
        if questionIdx > 0 {
            self.backgroundIv.hidden = true
        }
        UIView.animateWithDuration(0.5, animations: {
                self.backgroundIv.alpha = 0
            }) { (completed) in
                self.backgroundIv.hidden = true
        }
    }
    
    func setSubject(subj: String) {
        
        _subjectLb.text = subj.uppercaseString
        _subjectIv.image = subj.isEmpty ? nil : UIImage(named: "hth" + subj.capitalizedString)
    }
    
    func stopTimer() {
        
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
    func loadQuestions () {
        
        var params = [
            "uid": Common.Data.userId,
            "bid": Common.Data.blogId]
        
        var urlStr = ""
        if self.gameType == .None {
            return
        } else if self.gameType == .PointChallenge {
            params["request_type"] = "1"
            params["gid"] = Common.Data.gameId
            urlStr = Common.ApiPointChallengeUrl
        } else if self.gameType == .SpecialQuiz {
            params["request_type"] = "2"
            params["quizid"] = Common.Data.sqQuizId
            urlStr = Common.ApiSpecialQuizUrl
        } else if self.gameType == .HeadToHead {
            params["gid"] = Common.Data.gameId
            params["request_type"] = "5"
            params["subject"] = Common.Data.hthSubjName
            urlStr = Common.ApiH2HUrl
            if !Common.Data.hthPrevSubjName.isEmpty {
                params["add_point"] = "1"
                params["add_point_subject"] = Common.Data.hthPrevSubjName
            }
        } else if self.gameType == .HHMiniGame {
            params["gid"] = Common.Data.gameId
            if Common.Data.hthSubjName.isEmpty {
                params["mini_gid"] = Common.Data.miniGameId
                params["request_type"] = "13"
            } else {
                params["subject"] = Common.Data.hthSubjName
                params["request_type"] = "11"
            }
            urlStr = Common.ApiH2HUrl
        }
        EZLoadingActivity.show("Loading...", disableUI: true)
        request(.POST, urlStr, parameters: params)
            .responseJSON { (response) -> Void in
                print("Questions Response: \(response.result.value)")
                if let respDict = response.result.value as? [String: AnyObject] {
                    let status = respDict["status"] as! Int
                    if status == 0 {
                        let message = respDict["message"] as! String
                        Common.showAlert(message, curVC: self, okHanlder: {
                            self.navigationController?.popViewControllerAnimated(true)
                        })
                    } else {
                        var questions = []
                        if self.gameType == GameType.SpecialQuiz {
                            questions = respDict["data"] as! [[String:AnyObject]]
                        } else {
                            let data = respDict["data"] as! [String: AnyObject]
                            questions = data["questions"] as! [[String: AnyObject]]
                            if self.gameType == GameType.PointChallenge && Common.Data.gameId == "" {
                                (self.tabBarController as! QATabBarController).decreaseHeart()
                                Common.Data.gameId = String(data["id"]!)
                            } else if self.gameType == GameType.HHMiniGame {
                                Common.Data.miniGameId = String(data["mini_id"]!)
                            }
                        }
                        srand(UInt32(NSDate().timeIntervalSinceReferenceDate))
                        for question in questions {
                            let correctNum = Int(rand() % 4)
                            let questionStr = question["title"] as! String
                            let questionID = question["qID"] as! String
                            let subject = (question["subject"] as! String).lowercaseString
                            var questPoints = ""
                            if let points = question["points"] as? String {
                                questPoints = points
                            }
                            var answers = Array<String>()
                            let serverAnswers = question["answers"] as! Array<String>
                            for i in 1...3 {
                                answers.append(serverAnswers[i])
                            }
                            answers.insert(serverAnswers[0], atIndex: correctNum)
                            let questionDict = [
                                "question": questionStr,
                                "correctNum": correctNum,
                                "answers": answers,
                                "questionID": questionID,
                                "questPoints": questPoints,
                                "subject": subject
                            ]
                            Common.Data.questions.append(questionDict)
                        }
                        EZLoadingActivity.hide(success: true, animated: true)
                    }
                    self.questionIdx = 0
                    self.fillContents(0)
                }
                EZLoadingActivity.hide()
        }
    }
    
    func presentNextQuestionVC () {
        
        self.view.userInteractionEnabled = false
        
        let dispatchTime: dispatch_time_t = dispatch_time (DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue()) { () -> Void in
            if self.questionIdx + 1 == Common.Data.questions.count {
                Common.Data.questionIds = String(Common.Data.questionIds.characters.dropLast())
                Common.Data.answerStates = String(Common.Data.answerStates.characters.dropLast())
                Common.Data.questPoints = String(Common.Data.questPoints.characters.dropLast())
                if let tabC = self.tabBarController as? QATabBarController {
                    tabC.increaseTotal(Common.Data.earnedPoints)
                }
                if self.gameType == .PointChallenge {
                    self.performSegueWithIdentifier("SegueToPCResultVC", sender: nil)
                } else if self.gameType == .SpecialQuiz {
                    self.processSpecialQuiz()
                } else if self.gameType == .HeadToHead {
                    self.processH2HResult()
                } else if self.gameType == .HHMiniGame {
                    self.processHHMiniGame()
                }
            } else {
                let nextVc = self.storyboard?.instantiateViewControllerWithIdentifier ("QAQuestionVC") as! QAQuestionVC
                nextVc.questionIdx = self.questionIdx + 1
                self.navigationController?.pushViewController(nextVc, animated: true)
            }
        }
    }
    
    func processHHMiniGame() {
        
        let passedTimeInMS: Int = Int(NSDate().timeIntervalSinceDate(Common.Data.startTime) * 1000)
        let params = ["uid" : Common.Data.userId,
                      "bid" : Common.Data.blogId,
                      "gid" : Common.Data.gameId,
                      "mini_gid" : Common.Data.miniGameId,
                      "time": "\(passedTimeInMS)",
                      "correct_answers" : "\(Common.Data.earnedPoints)",
                      "request_type" : "12"]
        EZLoadingActivity.show("Updating...", disableUI: true)
        request(.POST, Common.ApiH2HUrl, parameters: params)
            .responseJSON { (response) in
                
                EZLoadingActivity.hide()
                print("MiniGame Result :\n\(response.result.value)")
                if let respDict = response.result.value as? [String:AnyObject] {
                    let status = respDict["status"] as! Int
                    let message = respDict["message"] as! String
                    if status == 0 {
                        Common.showAlert(message, curVC: self, okHanlder: nil)
                    } else if status == 1 {
                        Common.showAlert(message, curVC: self, okHanlder: {
                            self.navigationController?.popToRootViewControllerAnimated(true)
                        })
                    } else if status == 2 {
                        Common.showAlert(message, curVC: self, okHanlder: {
                            self.loadH2HState(Common.Data.gameId)
                        })
                    }
                }
        }
    }
    
    func loadH2HState(gId: String) {
        
        let params = ["uid" : Common.Data.userId,
                      "bid" : Common.Data.blogId,
                      "gid" : gId,
                      "request_type" : "4"]
        EZLoadingActivity.show("Loading...", disableUI: true)
        request(.POST, Common.ApiH2HUrl, parameters: params)
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
    
    func processH2HResult() {
        
        if Common.Data.answerStates == "0" {
            let params = ["uid" : Common.Data.userId,
                          "bid" : Common.Data.blogId,
                          "gid" : Common.Data.gameId,
                          "subject": Common.Data.hthSubjName,
                          "request_type" : "7"]
            EZLoadingActivity.show("Updating...", disableUI: true)
            let urlStr = Common.ApiH2HUrl
            request(.POST, urlStr, parameters: params)
                .responseJSON { (response) in
                    
                    print("H2H Turn Change :\n\(response.result.value)")
                    let respDict = response.result.value as! [String:AnyObject]
                    let status = respDict["status"] as! Int
                    EZLoadingActivity.hide()
                    if status == 0 {
                        let message = respDict["message"] as! String
                        Common.showAlert(message, curVC: self, okHanlder: nil)
                    } else {
                        Common.showAlert("It's now your opponents turn", curVC: self, okHanlder: {
                            self.navigationController?.popToRootViewControllerAnimated(true)
                        })
                    }
            }
        } else {
            if Common.Data.hthWonStoleState == "" {
                addPoints()
            } else {
                earnBadge()
            }
        }
    }
    
    func addPoints() {
        
        let params = ["uid" : Common.Data.userId,
                      "bid" : Common.Data.blogId,
                      "gid" : Common.Data.gameId,
                      "add_point_subject" : Common.Data.hthSubjName,
                      "request_type" : "9"]
        EZLoadingActivity.show("Submitting...", disableUI: true)
        request(.POST, Common.ApiH2HUrl, parameters: params)
            .responseJSON { (response) in
                print("H2H Add Points :\n\(response.result.value)")
                let respDict = response.result.value as! [String:AnyObject]
                let status = respDict["status"] as! Int
                EZLoadingActivity.hide()
                if status == 0 {
                    let message = respDict["message"] as! String
                    Common.showAlert(message, curVC: self, okHanlder: nil)
                } else {
                    self.navigationController?.popViewControllerAnimated(true)
                }
        }
    }
    
    func earnBadge() {
        
        let params = ["uid" : Common.Data.userId,
                      "bid" : Common.Data.blogId,
                      "gid" : Common.Data.gameId,
                      "subject" : Common.Data.hthSubjName,
                      "stole" : Common.Data.hthWonStoleState,
                      "request_type" : "6"]
        EZLoadingActivity.show("Earning badge...", disableUI: true)
        let urlStr = Common.ApiH2HUrl
        request(.POST, urlStr, parameters: params)
            .responseJSON { (response) in
                print("H2H Earn Badge :\n\(response.result.value)")
                let respDict = response.result.value as! [String:AnyObject]
                let status = respDict["status"] as! Int
                EZLoadingActivity.hide()
                if status == 0 {
                    let message = respDict["message"] as! String
                    Common.showAlert(message, curVC: self, okHanlder: nil)
                } else {
                    Common.showAlert("Great! You've earned a badge.", curVC: self, okHanlder: {
                        var spinVc: UIViewController? = nil
                        for vc in self.navigationController!.viewControllers {
                            if vc.isKindOfClass(QAHToHSpinVC) {
                                spinVc = vc
                                break
                            }
                        }
                        self.navigationController?.popToViewController(spinVc!,
                            animated: true)
                    })
                }
        }
    }
    
    func processSpecialQuiz() {
        
        let params = [
            "uid": Common.Data.userId,
            "bid" : Common.Data.blogId,
            "request_type" : "3",
            "quizid": Common.Data.sqQuizId,
            "qids": Common.Data.questionIds,
            "qresults": Common.Data.answerStates,
            "qpoints": Common.Data.questPoints]
        let urlStr = Common.ApiSpecialQuizUrl
        
        EZLoadingActivity.show("Submitting...", disableUI: true)
        request(.POST, urlStr, parameters: params)
            .responseJSON { (response) -> Void in
                
                print("Response JSON: \(response.result.value)")
                if let respDict = response.result.value as? [String:AnyObject] {
                    let status = respDict["status"] as! Int
                    if status == 0 {
                        let message = respDict["message"] as! String
                        Common.showAlert(message, curVC: self, okHanlder: nil)
                    } else {
                        let finishedGamesVc = self.storyboard?.instantiateViewControllerWithIdentifier("QAFinishedGamesVC")
                        self.navigationController?.pushViewController(finishedGamesVc!, animated: true)
                    }
                }
                EZLoadingActivity.hide()
        }
    }
}
