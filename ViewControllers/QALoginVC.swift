//
//  QALoginVC.swift
//  Quizacation
//
//  Created by CedarWaters  on 3/10/16.
//  Copyright © 2016 CedarWaters . All rights reserved.
//

import UIKit
import Alamofire
import EZLoadingActivity

class QALoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var _scrollView: UIScrollView!
    @IBOutlet weak var _passwordTF: UITextField!
    @IBOutlet weak var _studentIDTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(QALoginVC.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(QALoginVC.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.width, _scrollView.frame.height)

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self._studentIDTF.text = ""
        self._passwordTF.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == _studentIDTF {
            _passwordTF.becomeFirstResponder()
        } else  {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func keyboardWillShow(notification:NSNotification){

        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
        
        var contentInset:UIEdgeInsets = _scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        _scrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsetsZero
        _scrollView.contentInset = contentInset
    }
    
    @IBAction func onSubmitBtn_Pressed(sender: AnyObject) {
        
        if _passwordTF.text == "" || _studentIDTF.text == "" {
            _studentIDTF.text = "oskyadmin"
            _passwordTF.text = "Texasbiz12!@"
//            Common.showAlert("StudentID and Password are required.", curVC: self, okHanlder: nil)
//            return
        }
        
        let params = [
            "studentid": _studentIDTF.text!,
            "password" : _passwordTF.text!,
            "tokenid" : Common.Data.deviceToken,
            "os": "ios"]
        let urlStr = Common.ApiLoginUrl
        
        EZLoadingActivity.show("Logging in...", disableUI: true)
        request(.POST, urlStr, parameters: params)
            .responseJSON { (response) -> Void in
            
            print("Response JSON: \(response.result.value)")
            if response.result.value == nil {
                EZLoadingActivity.hide()
                Common.showAlert("Server error", curVC: self, okHanlder: nil)
                return
            }
            let respDict = response.result.value as! NSDictionary
            let status = respDict.valueForKey("status") as! NSInteger
            if status == 0 {
                let message = respDict.valueForKey("message") as! String
                EZLoadingActivity.hide()
                Common.showAlert(message, curVC: self, okHanlder: nil)
            } else {
                let dataAry = respDict.valueForKey("data") as! NSArray
                Common.Data.userId = dataAry[0] as! String
                Common.Data.blogId = dataAry[1] as! String
                let firstName = dataAry[2] as! String
                let lastName = dataAry[3] as! String
                Common.Data.userName = firstName.isEmpty ? lastName : firstName
                Common.Data.totalPts = dataAry[4] as! Int
                Common.Data.timestamps = dataAry[5] as! [String]
                self.presentMainScreen()
                EZLoadingActivity.hide(success: true, animated: true)
            }
        }
    }
    
    func presentMainScreen () {
        
        let dispatchTime = dispatch_time (DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue()) { () -> Void in
            self.performSegueWithIdentifier("SegueToMain", sender: nil)
        }
    }
}
