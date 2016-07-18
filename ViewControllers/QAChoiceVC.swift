//
//  QAChoiceVC.swift
//  Quizacation
//
//  Created by CedarWaters  on 4/12/16.
//  Copyright © 2016 CedarWaters . All rights reserved.
//

import UIKit

class QAChoiceVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    // MARK: - Events -
    
    @IBAction func onPCBtn_Pressed(sender: AnyObject) {                
        
        performSegueWithIdentifier("SegueToQuestionVC", sender: nil)
    }
}
