//
//  GameLevelConfig.swift
//  Curiosity
//
//  Created by Ryan Britt on 1/24/15.
//  Copyright (c) 2015 Ryan Britt. All rights reserved.
//

class GameLevelConfig {
    /**
    Configures the scene as a particular tutorial scene. All the tutorial scenes have a similar background and only 
    differ based on the part of gameplay that is being demonstrated.
    
    - parameter scene:     The scene to configure
    - parameter tutNumber: What tutorial number to configure this scene for.
    */
    class func configureTutorialForScene(_ scene:CuriosityScene, TutorialNumber tutNumber:Int)
    {
        //Initializes a parallax background that will move with the character.
        let parallaxImageNames = NSArray(objects: "hills", "blueDayBackground")
        let size = UIImage(named:"blueDayBackground")!.size
        
        //Initialize scene properties
        scene.parallaxBackground = PBParallaxScrolling(backgrounds:parallaxImageNames as [AnyObject], size:size, direction:kPBParallaxBackgroundDirectionRight, fastestSpeed:0.3, andSpeedDecrease:0.2)
		
		scene.character = Character.defaultCharacter()
		replacePlaceholderNode(scene.childNode(withName: "//CHARACTER"), withNode:scene.character!.sprite)
		
		switch tutNumber
        {
        case 1: //Tilt Tutorial
            scene.maxJumps = 0
            scene.name = "Tilt To move"
            
        case 2: //Jump Tutorial
            scene.maxJumps = 1
            scene.name = "Tap to jump, tap harder to jump higher"
            
        case 3://Double Jump Tutorial
            scene.name = "Tap twice to double jump"
            break //maxJumps is default set to 2
            
        case 4://Effect Tutorial
            scene.name = "Move to the Curiosity"
            //Create green orb curiosity and set effect
            let greenOrb = CuriositySpriteNode.orbItemWithColor(UIColor.green)
            
            greenOrb.storedEffect = {
                // Pan to and Raise Finish Level
                let finishNode = scene.childNode(withName: "//Finish") as? SKSpriteNode
                if let validFinish:SKSpriteNode = finishNode
                {
                    if let camera = scene.camera
                    {
                        scene.panCameraToLocation(CGPoint(x: validFinish.position.x, y: camera.position.y), forDuration: 1, andThenWait: 1)
                    }
                    let raiseFinish = SKAction.move(by: CGVector(dx: 0, dy: validFinish.size.height), duration: 1)
                    finishNode?.run(SKAction.sequence([SKAction.wait(forDuration: 1),raiseFinish]))
                }
                greenOrb.removeAllActions()
            }
            
            //Replace placeholder with temp item
            replacePlaceholderNode(scene.childNode(withName: "//GreenOrb1"), withNode:greenOrb)
            
        default:
            break
        }
    }
    
    class func configureLevel1ForScene(_ scene:CuriosityScene)
    {
        //Initializes a parallax background that will move with the character.
        let parallaxImageNames = NSArray(objects: "hills", "blueDayBackground")
        let size = UIImage(named:"blueDayBackground")!.size
        
        scene.parallaxBackground = PBParallaxScrolling(backgrounds:parallaxImageNames as [AnyObject], size:size, direction:kPBParallaxBackgroundDirectionRight, fastestSpeed:0.3, andSpeedDecrease:0.2)
		
        scene.character = Character.defaultCharacter()
        replacePlaceholderNode(scene.childNode(withName: "//CHARACTER"), withNode:scene.character!.sprite)
		
        let greenOrb = CuriositySpriteNode.orbItemWithColor(UIColor.green)
        greenOrb.storedEffect = {
			
            // Pan to and Raise Rock
            let rockNode = scene.childNode(withName: "//hiddenRock") as? SKSpriteNode
            if let validRock:SKSpriteNode = rockNode {
                if let camera = scene.camera {
                    scene.panCameraToLocation(CGPoint(x: validRock.position.x, y: camera.position.y), forDuration: 1, andThenWait: 1)
                }
                let raiseRock = SKAction.move(by: CGVector(dx: 0, dy: validRock.size.height), duration: 1)
                rockNode?.run(SKAction.sequence([SKAction.wait(forDuration: 1),raiseRock]))
            }
            
            
            // Raise Finish Node so the level can be completed
            let finishNode = scene.childNode(withName: "//Finish") as? SKSpriteNode
            
            if let validFinish = finishNode{
                let action = SKAction.move(by: CGVector(dx: 0, dy: validFinish.size.height), duration: 0)
                finishNode?.run(action)
            }
            greenOrb.removeAllActions()
        }
        
        replacePlaceholderNode(scene.childNode(withName: "//GreenOrb1"), withNode:greenOrb)
        scene.name = "Level 1"
        
    }

    
    class func configureLevel2ForScene(_ scene:CuriosityScene)
    {
        //Initializes a parallax background that will move with the character.
        let parallaxImageNames = NSArray(objects: "hills", "blueDayBackground")
        let size = UIImage(named:"blueDayBackground")!.size
        
        scene.parallaxBackground = PBParallaxScrolling(backgrounds:parallaxImageNames as [AnyObject], size:size, direction:kPBParallaxBackgroundDirectionRight, fastestSpeed:0.3, andSpeedDecrease:0.2)
        
        scene.character = Character.defaultCharacter()
        replacePlaceholderNode(scene.childNode(withName: "//CHARACTER"), withNode:scene.character!.sprite)
		
        scene.name = "Level 2"
        
        let greenOrb = CuriositySpriteNode.orbItemWithColor(UIColor.green)
        let blackOrb = CuriositySpriteNode.orbItemWithColor(UIColor.black)
        
        
        greenOrb.storedEffect = {
            if let hiddenRock = scene.childNode(withName: "//HiddenRock") as? SKSpriteNode {
                let raiseRock = SKAction.move(by: CGVector(dx: 0, dy: hiddenRock.size.height), duration: 1)
                hiddenRock.run(SKAction.sequence([raiseRock]))
            }
        }
        
        blackOrb.storedEffect = {
            scene.character?.sprite.physicsBody?.mass *= 10
            scene.character?.jumpConstant *= 10
            scene.character?.torqueConstant /= 5
            
            scene.character?.sprite.run(SKAction.scale(by: 2, duration: 1));
            scene.panCameraToLocation((scene.character?.sprite.position)!, forDuration: 0.5, andThenWait: 0.5 )
        }
        replacePlaceholderNode(scene.childNode(withName: "//GreenOrb1"), withNode: greenOrb)
        replacePlaceholderNode(scene.childNode(withName: "//BlackOrb"), withNode: blackOrb)
    }
    
    
    /**
    Replaces an optional placeholder node in a scene with a valid, non-nil node. If the placeholder is nil, this method does nothing.
    
    - parameter node1: An optional placeholder node that is found in a .sks serialized file. It may or may not be nil.
    - parameter node2: The node to replace the placeholder with.
    
    - returns: Bool stating whether the replacement was successful or not.
    */
    fileprivate class func replacePlaceholderNode(_ node1:SKNode?, withNode node2:SKNode) -> Bool
    {
        var successful = false
        
        if let placeholder = node1
        {
            if let parent = placeholder.parent
            {
                node2.position = placeholder.position
                parent.addChild(node2)
                placeholder.removeFromParent()
                successful = true
            }
        }
        return successful
    }
    
    fileprivate class func panToAndRaiseSpriteNode(_ node:SKSpriteNode, inScene scene:CuriosityScene,withCamera camera:SKCameraNode, andWaitFor wait:TimeInterval) {
        
        scene.panCameraToLocation(CGPoint(x: node.position.x, y: camera.position.y), forDuration: 1, andThenWait: wait)
        let raiseNode = SKAction.move(by: CGVector(dx: 0, dy: node.size.height), duration: 1)
        node.run(SKAction.sequence([SKAction.wait(forDuration: 1),raiseNode]))
    }
    
    fileprivate class func scalesSKSpriteNodebyXPercent(_ xPercent:Int, andYPercent yPercent:Int, forDuration duration:TimeInterval) -> SKAction {
        
        let xScalar = CGFloat(xPercent) / 100.00
        let yScalar = CGFloat(yPercent) / 100.00
        
        return SKAction.scaleX(by: xScalar, y:yScalar, duration: duration)
    }
    
    fileprivate class func scaleTreeTrunk(_ trunk:SKSpriteNode, toYPercent percent:Int, andMoveTop top:SKSpriteNode){
        let newHeight = trunk.size.height * (CGFloat(percent) / 100.00)
        let moveDown = SKAction.moveBy(x: 0, y: -newHeight, duration: 1)

        let positionYDifference = trunk.position.y + (newHeight/2)
        let newYPosition = trunk.position.y - positionYDifference
        let scaleTreeTrunk = scalesSKSpriteNodebyXPercent(100, andYPercent: percent, forDuration: 1)
        let moveTrunkUp = SKAction.moveTo(y: newYPosition, duration: 1)
        let combination = SKAction.group([scaleTreeTrunk, moveTrunkUp])
        
        
  
        trunk.run(combination)
        top.run(moveDown)
    }


}
