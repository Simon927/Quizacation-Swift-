//
//  QAHToHSpinVC.swift
//  Quizacation
//
//  Created by CedarWaters  on 3/19/16.
//  Copyright © 2016 CedarWaters . All rights reserved.
//

import UIKit

class QAHToHSpinVC: UIViewController {

    // MARK: - Outlets & Variables -
    
    internal var _data: [String:AnyObject]? // id, subjects, subjects_opponent
    
    var _gameId: String = ""
    var _pendingSubjects: [String] = []
    var _pendingOpptSubjects: [String] = []
    let PI: Double = 3.141592
    let _spinSubjectsNames2 = ["crown", "math", "art", "elective", "english", "history", "sports", "science"]
    let _spinSubjectsNames = ["crown", "science", "sports", "history", "english", "elective", "art", "math"]
    var _curCrownCount: Int = 0
    var _prevSelectedSubjName: String = ""
    var _originTransform: CGAffineTransform!
    var _isSpinning = false
    
    @IBOutlet weak var _crownIv: UIImageView!
    @IBOutlet weak var _nameLB: UILabel!
    @IBOutlet weak var _opptNameLB: UILabel!
    @IBOutlet weak var _subjectsView: UIView!
    @IBOutlet weak var _opptSubjectsView: UIView!
    @IBOutlet weak var _wheelIv: UIImageView!
    
    // Mark: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let data = _data {
            _gameId = data["id"] as! String
            _curCrownCount = data["partial_crowns"] as! Int
            _pendingSubjects = data["subjects"] as! [String]
            _pendingOpptSubjects = data["subjects_opponent"] as! [String]
            setNames()
        }
        setSubjectsState()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if Common.Data.answerStates == "1" && Common.Data.hthWonStoleState.isEmpty {
            _curCrownCount += 1
        }
        if Common.Data.hthIsEnd {
            _curCrownCount = 0
        }
        setSubjectsState()
        Common.Data.reset()
        
        if _originTransform == nil {
            _originTransform = self._wheelIv.transform
        }
        self._wheelIv.transform = _originTransform
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if _curCrownCount == 3 {
            Common.Data.hthIsEnd = true
            self.moveToStoleScreen()
        }
        if _pendingSubjects.isEmpty {
            Common.showAlert("Congratulation! You've won the game.", curVC: self, okHanlder: { 
                self.navigationController?.popToRootViewControllerAnimated(true)
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Events -
    
    @IBAction func onSpinButton_Pressed(sender: AnyObject) {

        if _isSpinning {
            return
        }
        _isSpinning = true
        srand(UInt32(NSDate().timeIntervalSinceReferenceDate))
        let stopCnt: Int = 40 + Int((rand() % 8))
        rotateAvatar(0.01, count: 1, stopCount: stopCnt)
    }
    
    // MARK: - Private -
    
    func rotateAvatar (delay: Double, count: Int, stopCount: Int) {
        
        var dly = delay
        var cnt = count
        UIView.animateWithDuration(dly, animations: { () -> Void in
            self._wheelIv.transform = CGAffineTransformRotate(self._wheelIv.transform, CGFloat(45/180*self.PI))
        }) { (completed) -> Void in
            if cnt == stopCount {
                let selectedSubj = self._spinSubjectsNames[cnt % 8]
                self.performSelector(#selector(QAHToHSpinVC.moveToQuestionScreen(_:)), withObject: selectedSubj, afterDelay: 0.5)
                return
            }
            if cnt % 8 == 0 {
                dly += 0.01
            }
            cnt += 1
            self.rotateAvatar(dly, count: cnt, stopCount: stopCount)
        }
    }
    
    func setSubjectsState() {
        
        let subjectsNames = ["science", "elective", "english", "history", "math", "sports", "art"]
        for i in 10...16 {
            let subjName = subjectsNames[i - 10]
            let chkIv = _subjectsView.viewWithTag(i) as! UIImageView
            let opptChkIv = _opptSubjectsView.viewWithTag(i) as! UIImageView
            chkIv.hidden = _pendingSubjects.contains(subjName)
            opptChkIv.hidden = _pendingOpptSubjects.contains(subjName)
        }
        setCrownState(0)
    }
    
    func setCrownState(incCount: Int) {
        
        _curCrownCount += incCount
        _crownIv.image = UIImage(named: "hthCrown\(_curCrownCount + 1)")
    }
    
    func setNames() {
        
        if let name = _data!["username"] as? String {
            _nameLB.text = name
        }
        if let opptName = _data!["opponent_username"] as? String {
            _opptNameLB.text = opptName
        }
    }
    
    func moveToQuestionScreen(selectedSubj: String) {
        
        _isSpinning = false
        if selectedSubj == "crown" {
            self.moveToStoleScreen()
        } else {
            Common.Data.hthSubjName = selectedSubj
            Common.Data.hthPrevSubjName = _prevSelectedSubjName
            Common.Data.gameType = GameType.HeadToHead
            Common.Data.gameId = _gameId
            _prevSelectedSubjName = selectedSubj
            self.performSegueWithIdentifier("SegueToQuestionVC", sender: nil)
        }
    }
    
    func moveToStoleScreen() {
        
        self.performSegueWithIdentifier("SegueToStoleBadgeVC", sender: nil)
    }
    
    // MARK: - Segue -
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "SegueToStoleBadgeVC" {
            let stoleVc = segue.destinationViewController as! QAHToHStoleBadgeVC
            stoleVc._spinVc = self
        }
    }
}
