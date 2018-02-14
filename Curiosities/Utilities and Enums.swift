//
//  Enums.swift
//  Curiosity
//
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

//MARK: enums

/**
Enum describing levels in the game.
The raw value equates to the name of the .sks file that is used for the level.
*/
enum GameLevel:String
{
    case Level1 = "Level 1", Level2 = "Level 2", Tut1 = "Tutorial1",
Tut2 = "Tutorial2", Tut3 = "Tutorial3", Tut4 = "Tutorial4"
    //An array of ordered levels for use in determining the next level to advance to.
    static let orderedLevels = [Tut1, Tut2, Tut3, Tut4, Level1, Level2]
}

/**
Physics categories used for this game.
*/
enum PhysicsCategory:UInt32
{
    case none = 0
    case character = 1
    case item = 2
    case environment = 3
    case all = 4294967295
}

//MARK: Structs

/**
*  A struct designed for tracking what CuriosityGameLevel the character is on, and the max Level they have unlocked.
*/
struct LevelTracker
{
    //MARK: Type Level
    static var highestUnlockedLevel:GameLevel {
        get{
            if let userDefault = UserDefaults.standard.string(forKey: "highestUnlockedLevel") {
                guard let level = GameLevel(rawValue: userDefault) else {
                    return .Tut1
                }
                return level;
            }
            return .Tut1
            
        } set (newValue){
            UserDefaults.standard.setValue(newValue.rawValue, forKey: "highestUnlockedLevel")
        }
    }
    
    /**
    Unlocks an arbitrary level in the game. This is implemented in such a way that once a level is unlocked, so are any levels below it.
    
    - parameter nextLevel: The next Level to unlock.
    */
    static func unlockLevel(_ nextLevel:GameLevel)
    {
        let highestLvl = GameLevel.orderedLevels.index(of: highestUnlockedLevel)
        let nextLvl = GameLevel.orderedLevels.index(of: nextLevel)

        if(nextLvl > highestLvl)
        {
            highestUnlockedLevel = nextLevel
        }
    }
    
    static func levelIsUnlocked(_ level:GameLevel) -> Bool
    {
        let highestLvl = GameLevel.orderedLevels.index(of: highestUnlockedLevel)
        let lvl = GameLevel.orderedLevels.index(of: level)
        
        return lvl <= highestLvl
    }
    
    //MARK: Instance level
    var currentLevel = GameLevel.Tut1
    
    /**
    Changes the current level to any of the currently unlocked levels.
    
    - parameter level: Level to make the current level

    - returns: A Bool describing whether or not the level was changed.
    */
    mutating func goToLevel(_ level:GameLevel) -> Bool
    {
        var isSuccessful = true
        
        if LevelTracker.levelIsUnlocked(level)
        {
            currentLevel = level
        }
        else
        {
            isSuccessful = false
        }
        
        return isSuccessful
    }
    
    /**
    Advances the current level following the appropriate order of Curiosity Game Levels. If the level is locked, it becomes unlocked.
    
    - returns: A Bool describing whether or not the next level was reached. False can be caused by either the level already being at the max level or an error occuring and the current level not being able to be found.
    */
    mutating func nextLevel() -> Bool
    {
        var isSuccessful = true
        let currentLvl = GameLevel.orderedLevels.index(of: currentLevel)
        if let lvlIndex = currentLvl
        {
            let nextLvlIndex = lvlIndex + 1
            if(nextLvlIndex < GameLevel.orderedLevels.count)
            {
                let nextLevel = GameLevel.orderedLevels[nextLvlIndex]
                if !(LevelTracker.levelIsUnlocked(nextLevel))
                {
                    LevelTracker.unlockLevel(nextLevel)
                }
                
                currentLevel = nextLevel
                
            }
            else // level is already at the max level
            { isSuccessful = false }

        }
        else // Something went wrong and nil was returned
        { isSuccessful = false }

       return isSuccessful

    }
}

//MARK: Helper Functions

/**
Determines the distance between two CGPoints

- parameter pointOne: The first CGPoint
- parameter pointTwo: The second CGPoint

- returns: A Float value that represents the distance between the two CGPoints.
*/
func distanceBetweenPointOne(_ pointOne:CGPoint, andPointTwo pointTwo:CGPoint) -> Float
{
    var distance:Float = 0
    
    distance = sqrtf(powf(Float(pointTwo.x) - Float(pointOne.x), 2) +
         powf(Float(pointTwo.y) - Float(pointOne.y), 2))
    
    return distance
}

//subtraction for CGPoint. Useful when CGPoint is being used as a vector stand in.
public func - (left:CGPoint, right:CGPoint) -> CGPoint
{
	return CGPoint(x: left.x - right.x, y: left.y - right.y)
}




