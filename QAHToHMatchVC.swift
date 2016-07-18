//
//  QAHToHMatchVC.swift
//  Quizacation
//
//  Created by CedarWaters  on 3/16/16.
//  Copyright © 2016 CedarWaters . All rights reserved.
//

import UIKit
import Alamofire
import EZLoadingActivity

class QAHToHMatchVC: UIViewController {

    @IBOutlet weak var opptUsernameTF: UITextField!
    
    var challengersAry: NSArray = NSArray ()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Events
    
    @IBAction func onChallengeBtn_Pressed(sender: AnyObject) {
        
        if opptUsernameTF.text!.isEmpty {
            Common.showAlert("Please input opposite user name to match.", curVC: self, okHanlder: nil)
            return
        }
        opptUsernameTF.resignFirstResponder()
        
        let params = ["uid": Common.Data.userId,
                      "bid": Common.Data.blogId,
                      "invite": opptUsernameTF.text!,
                      "request_type": "2"]
        EZLoadingActivity.show("Challenging...", disableUI: true)
        request(.POST, Common.ApiH2HUrl, parameters: params)
            .responseJSON { (response) in
                
                if let respDict = response.result.value as? [String:AnyObject] {
                    print("Challenging:\n\(respDict)")
                    let status = respDict["status"] as! Int
                    let message = respDict["message"] as! String
                    if status == 0 {
                        Common.showAlert(message, curVC: self, okHanlder: nil)
                    } else {
                        (self.tabBarController as! QATabBarController).decreaseHeart()
                        Common.showAlert(message, curVC: self, okHanlder: {
                            self.navigationController?.popToRootViewControllerAnimated(true)
                        })
                    }
                } else {
                    Common.showAlert("Server Error", curVC: self, okHanlder: nil)
                }
                EZLoadingActivity.hide()
        }
    }
    
    @IBAction func onRandomChallengeBtn_Pressed(sender: AnyObject) {
        
        (self.tabBarController as! QATabBarController).decreaseHeart()
        
        let params = ["uid": Common.Data.userId,
                      "bid": Common.Data.blogId,
                      "request_type": "1"]
        EZLoadingActivity.show("Matching...", disableUI: true)
        request(.POST, Common.ApiH2HUrl, parameters: params)
            .responseJSON { (response) in
                
                if let respDict = response.result.value as? [String:AnyObject] {
                    print("Succeed in matching:\n\(respDict)")
                    let status = respDict["status"] as! Int
                    if status == 0 {
                        let message = respDict["message"] as! String
                        EZLoadingActivity.hide()
                        Common.showAlert(message, curVC: self, okHanlder: {
                            self.navigationController?.popToRootViewControllerAnimated(true)
                        })
                    } else {
                        EZLoadingActivity.hide(success: true, animated: true)
                        self.moveToSpinScreen(respDict["data"] as! [String:AnyObject])
                    }
                } else {
                    Common.showAlert("Server Error", curVC: self, okHanlder: nil)
                    EZLoadingActivity.hide()
                }
        }
    }
    
    @IBAction func onReturnKey_Pressed(sender: AnyObject) {
        
        self.opptUsernameTF.resignFirstResponder()
    }
    
    // MARK: - Private -
    
    func moveToSpinScreen(data: [String:AnyObject]) {
        
        self .performSegueWithIdentifier("SegueToHTHSpinScreen", sender: data)
    }
    
    // MARK: - Segue -
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "SegueToHTHSpinScreen" {
            let spinVc = segue.destinationViewController as! QAHToHSpinVC
            spinVc._data = sender as? [String:AnyObject]
        }
    }
}
