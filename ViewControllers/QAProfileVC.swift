//
//  QAProfileVC.swift
//  Quizacation
//
//  Created by CedarWaters  on 3/11/16.
//  Copyright © 2016 CedarWaters . All rights reserved.
//

import UIKit
import Alamofire
import EZLoadingActivity

class QAProfileVC: UIViewController {

    @IBOutlet weak var _hthWinsCountLB: UILabel!
    @IBOutlet weak var _hthLossesCountLB: UILabel!
    @IBOutlet weak var _medalGoldCountLB: UILabel!
    @IBOutlet weak var _medalSilverCountLB: UILabel!
    @IBOutlet weak var _medalBronzeCountLB: UILabel!
    @IBOutlet weak var _statsView: UIView!
    
    var _subjectsStats = [Array<Int>](count: 7, repeatedValue: Array<Int>())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let borderColor: CGColorRef = UIColor (colorLiteralRed: 193/255, green: 39/255, blue: 44/255, alpha: 1).CGColor
        _hthWinsCountLB.superview!.superview!.layer.borderColor = borderColor
        _statsView.layer.borderColor = borderColor
        
        for i in 1...5 {
            let countLB = _hthWinsCountLB.superview?.viewWithTag(i + 10) as! UILabel
            countLB.layer.cornerRadius = countLB.frame.size.width / 2
        }
        self.clearAllFields()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadProfileInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Button Events
    
    @IBAction func onLogoutBtn_Pressed(sender: AnyObject) {
        
        EZLoadingActivity.show("Logging out...", disableUI: true)
        request(.POST, Common.ApiLogout, parameters: nil)
            .responseJSON { (response) -> Void in
                
                print("Response JSON: \(response.result.value)")
                if let respDict = response.result.value as? [String: AnyObject] {
                    let status = respDict["status"] as! Int
                    if status == 0 {
                        let message = respDict["message"] as! String
                        Common.showAlert(message, curVC: self, okHanlder: nil)
                    } else {
                        EZLoadingActivity.hide(success: true, animated: true)
                        let dispatchTime: dispatch_time_t = dispatch_time (DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
                        dispatch_after(dispatchTime, dispatch_get_main_queue()) { () -> Void in
                            (self.tabBarController as! QATabBarController).logout()
                        }
                    }
                }
                EZLoadingActivity.hide()
        }
    }
    
    // MARK: Private
    
    func loadProfileInfo () {
    
        let params = [
            "uid": Common.Data.userId,
            "bid": Common.Data.blogId]
        
        let urlStr = Common.ApiProfileUrl
        
        EZLoadingActivity.show("Loading...", disableUI: true)
        request(.POST, urlStr, parameters: params)
            .responseJSON { (response) -> Void in
                
                print("Response JSON: \(response.result.value)")
                if let respDict = response.result.value as? [String: AnyObject] {
                    let status = respDict["status"] as! Int
                    if status == 0 {
                        let message = respDict["message"] as! String
                        Common.showAlert(message, curVC: self, okHanlder: nil)
                    } else {
                        let data = respDict["data"] as! [String: AnyObject]
                        self.fillAllFields(data)
                        EZLoadingActivity.hide(success: true, animated: true)
                    }
                }
                EZLoadingActivity.hide()
        }
    }
    
    func fillAllFields (data: [String: AnyObject]) {
        
        if let hthDict = data["head2head"] as? [String: Int] {
            _hthWinsCountLB.text = "\(hthDict["wins"]!)"
            _hthLossesCountLB.text = "\(hthDict["loses"]!)"
        }
        if let medalsDict = data["medals"] as? [String: AnyObject] {
            _medalGoldCountLB.text = String(medalsDict["gold"]!)
            _medalSilverCountLB.text = String(medalsDict["silver"]!)
            _medalBronzeCountLB.text = String(medalsDict["bronze"]!)
        }
        self.showCountLabels(true)
        if let subjectsDict = data["subjects"] as? [String: AnyObject] {
            let subjectsIdx: [String: Int] = ["science": 0,
                                              "elective": 1,
                                              "english": 2,
                                              "history": 3,
                                              "math": 4,
                                              "sports": 5,
                                              "art": 6]
            for key in subjectsDict.keys {
                let idx = subjectsIdx[key]
                let valuesDict = subjectsDict[key] as! [String: AnyObject]
                let percent = Int(round(valuesDict["percentage"] as! Float))
                let total = Int(String(valuesDict["total"]!))!
                _subjectsStats[idx!].removeAll()
                _subjectsStats[idx!].append(percent)
                _subjectsStats[idx!].append(total)
            }
        }
        for i in 0...6 {
            let view = _statsView.viewWithTag(i + 11)!
            for j in 0...1 {
                let percentSymbol = j == 0 ? "%" : ""
                if let lb = view.viewWithTag(j + 1) as? UILabel {
                    lb.text = "\(_subjectsStats[i][j])\(percentSymbol)"
                }
            }
        }
    }
    
    func clearAllFields () {
        
        self.showCountLabels(false)
        for i in 0...6 {
            let view = _statsView.viewWithTag(i + 11)!
            for j in 0...1 {
                if let lb = view.viewWithTag(j + 1) as? UILabel {
                    lb.text = ""
                }
            }
        }
    }
    
    func showCountLabels (isShow: Bool) {
        
        let superView = _hthWinsCountLB.superview!
        for i in 1...5 {
            let view = superView.viewWithTag(i + 10)
            view!.hidden = !isShow
        }
    }
}
