//
//  QASignupVC.swift
//  Quizacation
//
//  Created by CedarWaters  on 3/10/16.
//  Copyright © 2016 CedarWaters . All rights reserved.
//

import UIKit
import Alamofire
import EZLoadingActivity

class QASignupVC: UIViewController {
    
    @IBOutlet weak var _scrollView: UIScrollView!
    @IBOutlet weak var _schoolCodeTF: UITextField!
    @IBOutlet weak var _usernameTF: UITextField!
    @IBOutlet weak var _studentIDTF: UITextField!
    @IBOutlet weak var _passwordTF: UITextField!
    @IBOutlet weak var _passwordConfirmTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(QASignupVC.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(QASignupVC.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.width, _scrollView.frame.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField.tag != 5 {
            if let nextTF = _scrollView.viewWithTag(textField.tag + 1) as? UITextField {
                nextTF.becomeFirstResponder()
            }
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
        
        if _schoolCodeTF.text == "" ||
           _studentIDTF.text == "" ||
           _usernameTF.text == "" ||
           _passwordTF.text == "" {
            Common.showAlert("All fields are required to register. Please try again", curVC: self, okHanlder: nil)
            return
        }
        if _passwordTF.text != _passwordConfirmTF.text {
            Common.showAlert("Password doesn't match.", curVC: self, okHanlder: nil)
            return
        }
        
        let params = [
            "schoolcode" : _schoolCodeTF.text!,
            "studentid": _studentIDTF.text!,
            "studentname" : _usernameTF.text!,
            "password" : _passwordTF.text!,
            "tokenid" : Common.Data.deviceToken,
            "os": "ios"]
        let urlStr = Common.ApiRegisterUrl
        
        EZLoadingActivity.show("Signing up...", disableUI: true)
        
        request(.POST, urlStr, parameters: params)
            .responseJSON { (response) -> Void in
            
                print("Response JSON: \(response.result.value)")
                if let respDict = response.result.value as? NSDictionary {
                    let status = respDict.valueForKey("status") as! NSInteger
                    if status == 0 {
                        let message = respDict.valueForKey("message") as! String
                        Common.showAlert(message, curVC: self, okHanlder: nil)
                    } else {
                        self.pushToLoginScreen()
                        EZLoadingActivity.hide(success: true, animated: true)
                    }
                }
                EZLoadingActivity.hide()
        }
    }
    
    func pushToLoginScreen () {
        
        let dispatchTime: dispatch_time_t = dispatch_time (DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue()) { () -> Void in
            if let loginVc = self.storyboard?.instantiateViewControllerWithIdentifier("QALoginVC") {
                self.navigationController?.pushViewController(loginVc, animated: true)
            }
        }
    }
}
