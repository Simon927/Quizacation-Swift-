//
//  QATabBarController.swift
//  Quizacation
//
//  Created by CedarWaters  on 3/15/16.
//  Copyright © 2016 CedarWaters . All rights reserved.
//

import UIKit

class QATabBarController: UITabBarController {

    @IBOutlet var _tabView: UIView!
    @IBOutlet weak var _heartCntLB: UILabel!
    @IBOutlet weak var _totalPtsLB: UILabel!
    var _startedDates: [NSTimeInterval] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _tabView.frame = self.tabBar.frame;
        _tabView.frame.origin = CGPointZero;
        self.tabBar.addSubview(_tabView)
        _heartCntLB.layer.masksToBounds = true;
        _heartCntLB.layer.cornerRadius = _heartCntLB.frame.width / 2
        _totalPtsLB.text = "\(Common.Data.totalPts)"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
     
        loadHearts()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Events
    
    @IBAction func onHomeTabBtn_Pressed(sender: AnyObject) {
        
        self.selectedIndex = 0
        if let navC = self.viewControllers![0] as? UINavigationController {
            if navC.visibleViewController!.isKindOfClass(QAHomeVC) {
                (navC.visibleViewController as! QAHomeVC).loadCurrentGameList()
            } else {
                navC.popToRootViewControllerAnimated(true)
            }
        }
    }
    
    @IBAction func onProfileTabBtn_Pressed(sender: AnyObject) {
        
        self.selectedIndex = 1
    }
    
    // MARK: Public
    
    internal func logout() {
        
        Common.Data.resetAll()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    internal func increaseTotal(pts: Int) {
        
        Common.Data.totalPts += pts
        _totalPtsLB.text = "\(Common.Data.totalPts)"
    }
    
    internal func decreaseHeart() {
        
        _startedDates.append(NSDate().timeIntervalSince1970)
        updateHeartsCnt()
        startSelector(3600)
    }
    
    internal func getHeartCnt() -> Int {
        
        return 5 - _startedDates.count
    }
    
    // MARK: Private
    
    private func loadHearts() {
        
        _startedDates.removeAll()
        for stime in Common.Data.timestamps {
            let timestamp = NSTimeInterval(stime)!
            let diff = NSDate().timeIntervalSince1970 - timestamp
            if diff < 3600 {
                _startedDates.append(timestamp)
                startSelector(3600 - diff)
            }
        }
        updateHeartsCnt()
    }
    
    private func startSelector(delay: NSTimeInterval) {
        
        performSelector(#selector(QATabBarController.increaseHeart),
                        withObject: nil,
                        afterDelay: delay)
    }
    
    func increaseHeart() {
        
        _startedDates.removeFirst()
        updateHeartsCnt()
    }
    
    func updateHeartsCnt() {
        
        _heartCntLB.text = "\(getHeartCnt())"
    }
    
    /*
    private func loadHeartsFromDefaults() {
        
        _startedDates.removeAll()
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.synchronize()
        for i in 1...5 {
            if let date = defaults.objectForKey("StartedDate\(i)") as? NSDate {
                let diff = -date.timeIntervalSinceNow
                if diff < 3600 {
                    //                    _startedDates.append(date)
                    startSelector(3600 - diff)
                }
            }
        }
        saveHearts()
    }
    
    private func saveHearts() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        for i in 0...4 {
            if i < _startedDates.count {
                defaults.setObject(_startedDates[i], forKey: "StartedDate\(i + 1)")
            } else {
                defaults.setObject(nil, forKey: "StartedDate\(i + 1)")
            }
        }
        defaults.synchronize()
        _heartCntLB.text = "\(getHeartCnt())"
    } */
}
