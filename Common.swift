//
//  Common.swift
//  Quizacation
//
//  Created by CedarWaters  on 3/11/16.
//  Copyright © 2016 CedarWaters . All rights reserved.
//

import Foundation
import UIKit

class Common {
    
    static var Data: GameData = GameData ()

    static let ApiUrl: String = "http://quizacation.com/wp-api/"
    static let ApiProfileUrl: String = Common.ApiUrl + "api_profile.php"
    static let ApiLoginUrl: String = Common.ApiUrl + "login.php"
    static let ApiRegisterUrl: String = Common.ApiUrl + "register.php"
    static let ApiPointChallengeUrl: String = Common.ApiUrl + "api_points_challenge.php"
    static let ApiSpecialQuizUrl: String = Common.ApiUrl + "api_specialquiz.php"
    static let ApiGameListUrl: String = Common.ApiUrl + "api_gamelist.php"
    static let ApiH2HUrl: String = Common.ApiUrl + "api_head2head.php"
    static let ApiDelete: String = Common.ApiUrl + "api_delete_game.php"
    static let ApiLogout: String = Common.ApiUrl + "api_logout.php"
    
    static func showAlert (message: String, curVC: UIViewController, okHanlder: (() -> Void)?) {
        
        let alertController = UIAlertController (title: "Quizacation", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) in
            if okHanlder != nil {
                okHanlder!()
            }
        }))
        curVC.presentViewController(alertController, animated: true, completion: nil)
    }
    
    static func getHourOfDate(date: NSDate) -> Int {
    
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Hour, .Minute], fromDate: date)
        return comp.hour
    }
    
    static func getSecondsToNextHour(date: NSDate) -> Int {
        
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Minute, .Second], fromDate: date)
        let seconds = (60 - comp.second) + 60 * (60 - comp.minute - 1)
        return seconds
    }
}

func QAColor(red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
    return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1)
}

let QAGreenColor: UIColor = QAColor(116, 192, 70)
let QASubjColorDict: [String: UIColor] = [
    "science":  QAColor(104, 164, 213),
    "sports":   QAColor(158, 158, 158),
    "history":  QAColor(213, 153, 104),
    "english":  QAColor(227, 212, 148),
    "elective": QAColor(153, 113, 202),
    "art":      QAColor(163, 202, 113),
    "math":     QAColor(248, 116, 116)
]
