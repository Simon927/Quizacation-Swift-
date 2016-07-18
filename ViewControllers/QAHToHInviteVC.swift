//
//  QAHToHInviteVC.swift
//  Quizacation
//
//  Created by CedarWaters  on 4/13/16.
//  Copyright © 2016 CedarWaters . All rights reserved.
//

import UIKit
import Alamofire
import EZLoadingActivity

class QAHToHInviteVC: UIViewController {

    @IBOutlet weak var _nameLB: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _nameLB.text = Common.Data.hthOpptName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Events
    
    @IBAction func onAcceptBtn_Pressed(sender: AnyObject) {
        
        let params = ["uid": Common.Data.userId,
                      "bid": Common.Data.blogId,
                      "gid": Common.Data.gameId,
                      "request_type": "3"]
        EZLoadingActivity.show("Accepting...", disableUI: true)
        request(.POST, Common.ApiH2HUrl, parameters: params)
            .responseJSON { (response) in
                
                if let respDict = response.result.value as? [String:AnyObject] {
                    print("Accept Invitation:\n\(respDict)")
                    let status = respDict["status"] as! Int
                    if status == 0 {
                        let message = respDict["message"] as! String
                        Common.showAlert(message, curVC: self, okHanlder: nil)
                    } else {
                        self.moveToSpinScreen(respDict["data"] as! [String:AnyObject])
                    }
                } else {
                    Common.showAlert("Server Error", curVC: self, okHanlder: nil)
                }
                EZLoadingActivity.hide()
        }
    }
    
    @IBAction func onDeclineBtn_Pressed(sender: AnyObject) {
        
        let params = ["uid": Common.Data.userId,
                      "bid": Common.Data.blogId,
                      "gid": Common.Data.gameId,
                      "request_type": "8"]
        EZLoadingActivity.show("Declining...", disableUI: true)
        request(.POST, Common.ApiH2HUrl, parameters: params)
            .responseJSON { (response) in
                
                if let respDict = response.result.value as? [String:AnyObject] {
                    print("Decline Invitation:\n\(respDict)")
                    let status = respDict["status"] as! Int
                    if status == 0 {
                        let message = respDict["message"] as! String
                        Common.showAlert(message, curVC: self, okHanlder: nil)
                    } else {
                        Common.showAlert("Successfully declined", curVC: self, okHanlder: {
                            self.navigationController?.popToRootViewControllerAnimated(true)
                        })
                    }
                } else {
                    Common.showAlert("Server Error", curVC: self, okHanlder: nil)
                }
                EZLoadingActivity.hide()
        }
    }
    
    // MARK: Private
    
    func moveToSpinScreen(data: [String:AnyObject]) {
        
        let spinVc = self.storyboard?.instantiateViewControllerWithIdentifier("QAHToHSpinVC") as! QAHToHSpinVC
        spinVc._data = data
        self.navigationController?.pushViewController(spinVc, animated: true)
    }
}
