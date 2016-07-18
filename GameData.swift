//
//  GameData.swift
//  Quizacation
//
//  Created by CedarWaters  on 3/11/16.
//  Copyright © 2016 CedarWaters . All rights reserved.
//

import Foundation

enum GameType {
    case PointChallenge
    case SpecialQuiz
    case HeadToHead
    case HHMiniGame
}

class GameData {

    var deviceToken: String = ""
    var userId: String = ""
    var blogId: String = ""
    var userName: String = ""
    var totalPts: Int = 0
    var timestamps: [String] = []
    
    var questions: [AnyObject] = []
    var gameId: String = ""
    var miniGameId: String = ""
    var sqQuizId: String = ""
    var hthSubjName: String = ""
    var hthPrevSubjName: String = ""
    var hthWonStoleState: String = ""
    var hthOpptName: String = ""
    var hthIsEnd: Bool = false
    var earnedPoints: Int = 0
    var startTime: NSDate!
    var questionIds: String = ""
    var answerStates: String = ""
    var questPoints: String = ""
    var gameType = GameType.PointChallenge
    
    init () {
        
    }
    
    func reset() {
        
        questions.removeAll()
        gameId = ""
        miniGameId = ""
        sqQuizId = ""
        hthSubjName = ""
        hthPrevSubjName = ""
        hthWonStoleState = ""
        hthOpptName = ""
        hthIsEnd = false
        earnedPoints = 0
        startTime = nil
        questionIds = ""
        answerStates = ""
        questPoints = ""
        gameType = .PointChallenge
    }
    
    func resetAll() {
        
        userId = ""
        blogId = ""
        userName = ""
        totalPts = 0
        timestamps.removeAll()        
        reset()
    }
}