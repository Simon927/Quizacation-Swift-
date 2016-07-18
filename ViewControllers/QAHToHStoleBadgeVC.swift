//
//  QAHToHStoleBadgeVC.swift
//  Quizacation
//
//  Created by CedarWaters  on 4/4/16.
//  Copyright © 2016 CedarWaters . All rights reserved.
//

import UIKit

class QAHToHStoleBadgeVC: UIViewController {

    // MARK: - Outlets & Variables -
    
    @IBOutlet weak var _nameLB: UILabel!
    @IBOutlet weak var _subjectsView: UIView!
    @IBOutlet weak var _opptNameLB: UILabel!
    @IBOutlet weak var _opptSubjectsView: UIView!
    @IBOutlet weak var _stoleBtn: UIButton!
    
    internal var _spinVc: QAHToHSpinVC!
    
    let _subjectsNames = ["science", "elective", "english", "history", "math", "sports", "art"]
    var _selectedOpptSubj: String!
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setStoleBtnState(false)
        setSubjectsState()
        setNames()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Events -
    
    @IBAction func onSubjectBtn_Pressed(sender: AnyObject) {
        
        let btn = sender as! UIButton
        let subjName = _subjectsNames[btn.tag - 20]
        if _spinVc._pendingSubjects.contains(subjName) {
            Common.Data.hthWonStoleState = "0"
            Common.Data.gameType = GameType.HeadToHead
            moveToQuestionVC(subjName)
        }
    }
    
    @IBAction func onOpptSubjectBtn_Pressed(sender: AnyObject) {
        
        let btn = sender as! UIButton
        let subjName = _subjectsNames[btn.tag - 20]
        let hasSubject = !_spinVc._pendingOpptSubjects.contains(subjName)
        _selectedOpptSubj = hasSubject ? subjName : ""
        setStoleBtnState(hasSubject)
    }
    
    @IBAction func onStoleBtn_Pressed(sender: AnyObject) {
        
        Common.Data.hthWonStoleState = "1"
        _spinVc._pendingOpptSubjects.append(_selectedOpptSubj)
        Common.Data.gameType = GameType.HHMiniGame
        moveToQuestionVC(_selectedOpptSubj)
    }
    
    // MARK: - Private -
    
    func setSubjectsState() {
        
        for i in 10...16 {
            let subjName = _subjectsNames[i - 10]
            let chkIv = _subjectsView.viewWithTag(i) as! UIImageView
            let opptChkIv = _opptSubjectsView.viewWithTag(i) as! UIImageView
            chkIv.hidden = _spinVc._pendingSubjects.contains(subjName)
            opptChkIv.hidden = _spinVc._pendingOpptSubjects.contains(subjName)
        }
    }
    
    func setNames() {
        
        if let name = _spinVc._data!["username"] as? String {
            _nameLB.text = name
        }
        if let opptName = _spinVc._data!["opponent_username"] as? String {
            _opptNameLB.text = opptName
        }
    }
    
    func setStoleBtnState(isEnabled: Bool) {
    
        _stoleBtn.enabled = isEnabled
        _stoleBtn.backgroundColor = isEnabled ? QAGreenColor : UIColor.lightGrayColor()
    }
    
    func moveToQuestionVC(subjName: String) {
        
        Common.Data.hthSubjName = subjName
        Common.Data.hthPrevSubjName = _spinVc._prevSelectedSubjName
        Common.Data.gameId = _spinVc._gameId
        _spinVc._prevSelectedSubjName = subjName
        if let idx = _spinVc._pendingSubjects.indexOf(subjName) {
            _spinVc._pendingSubjects.removeAtIndex(idx)
        }
        self.performSegueWithIdentifier("SegueToQuestionVC", sender: nil)
    }
}
