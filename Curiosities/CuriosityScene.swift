//
//  GameScene.swift
//  Curiosity
//

import SpriteKit
import CoreMotion
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


class CuriosityScene: SKScene
{
	
	//MARK: Private instance variables
	//Defaults
	fileprivate let motionManager = CMMotionManager();
	fileprivate let queue = OperationQueue();
	fileprivate let framerate = 60.0 //Minimum Frames planned to deliver per second.
	fileprivate var cameraSpeed:Float = 0
	fileprivate var jumpCount = 0
	fileprivate var tempCharacterLocation = CGPoint(x: 0, y: 0)
	fileprivate var isCameraTracking = true
	fileprivate var cameraOrigin = CGPoint(x: 0, y: 0)

	//MARK: Public instance variables
	weak var gameViewControllerDelegate:GameViewController?
	
	var orientation:UIInterfaceOrientation = .landscapeLeft
	var parallaxBackground:PBParallaxScrolling? // A set of parallax backgrounds to be used as a backdrop for the action
	var farOutBackground:PBParallaxScrolling? // A background designed to be farther out than the other parallel backgrounds
	var maxJumps = 2
	var character:Character? // The character that is currently presented in the scene
	

	
	// listens to when the set method is called and sets the physics world property of the scene appropriatly
	var scenePaused:Bool = false {
		willSet(pausedValue){
			if pausedValue == true
			{ physicsWorld.speed = 0 }
            else{ physicsWorld.speed = 1 }
			
		}
	}
	
	//MARK: View Lifecycle Methods
	/**
	Initial entry point for the scene.
	
	:param: view <#view description#>
	*/
	override func didMove(to view: SKView)
	{
		//Starts the accelerometer updating to hand the acceleration X and Y to the character.
		if(!motionManager.isAccelerometerActive)
		{
			motionManager.accelerometerUpdateInterval = (1/self.framerate)
			if orientation == .landscapeLeft {
				motionManager.startAccelerometerUpdates(to: queue, withHandler: {(acData, error) -> Void in
					self.character?.accelerationX = acData!.acceleration.y
					self.character?.accelerationY = acData!.acceleration.x
				})
			}
				
			else {
				motionManager.startAccelerometerUpdates(to: queue, withHandler: {(acData, error) -> Void in
					self.character?.accelerationX = -acData!.acceleration.y
					self.character?.accelerationY = -acData!.acceleration.x
				})
			}
		}
		
		
		//Add the parallax backgrounds
		if let parallax = parallaxBackground
		{ addChild(parallax) }
		
		if let farOut = farOutBackground
		{ addChild(farOut) }
		
		if let camera = camera {
			cameraOrigin = camera.position
			parallaxBackground?.position.x = camera.position.x
			farOutBackground?.position.x = camera.position.x
		}
		
		self.physicsWorld.contactDelegate = self
		
		// Create label to describe the scene.
		let myLabel = SKLabelNode(fontNamed:"Helvetica")
		
		if let sceneName = name {
			myLabel.text = sceneName
		}
		
        myLabel.fontSize = 40
		myLabel.alpha = 0
		myLabel.position =  camera!.position
		
		// Animate the label
		let fade = SKAction.sequence([SKAction.run({self.scenePaused = true}), SKAction.fadeIn(withDuration: 0.5), SKAction.wait(forDuration: 1), SKAction.fadeOut(withDuration: 0.5), SKAction.run({self.scenePaused = false})])
        
        //hack to get around scene instructions playing to0 fast. Refactor.
        if(!scenePaused) {
            myLabel.run(fade)
            self.addChild(myLabel)
            
        }
		
		
	}
    
    
	
	/*
	Spritekit lifecycle method called every time a frame updates. For this scene, a sanity check is called to make sure the game isn't paused
	then moves the character, adjusts the direction of the parallax backgrounds, adjusts the position of the parallax backgrounds to match that of the camera.
	*/
	override func update(_ currentTime: TimeInterval)
	{
		/* Called before each frame is rendered */
		if !scenePaused {
			if let characterSKNode = character {
				characterSKNode.move()
				
			}
		}
	}
	
	
	override func didFinishUpdate() {
		if !scenePaused {
			if isCameraTracking {
				trackCameraToCharacter()
			}
			//the background position depends on the position of the camera, so it must always be updated after the camera.
			updateBackground()
		}
	}
	
	override func willMove(from view: SKView)
	{
        
        let priority = DispatchQueue.GlobalQueuePriority.default
        DispatchQueue.global(priority: priority).async {
           
            
            self.character = nil
            self.farOutBackground = nil
            self.parallaxBackground = nil
            self.gameViewControllerDelegate = nil
            self.camera = nil
            
            self.enumerateChildNodes(withName: "//*", using: { (node:SKNode! , stop:UnsafeMutablePointer<ObjCBool>) -> Void in
                node.removeAllChildren()
                node.removeAllActions()
                node.removeFromParent()
            })
            
            self.motionManager.stopAccelerometerUpdates()
            self.motionManager.stopDeviceMotionUpdates()

        }
    }
	
	//MARK: Accessory Methods
	
	/**
	Delegate method called from a UIGestureRecognizer to call the character jump method as long as it doesn't exceed the set maxJumps
	*/
    func jump(_ force:CGFloat?) {
		if(jumpCount < maxJumps) {
			jumpCount += 1
            let imputedForce = force > 0 ? force : 1
			character?.jump(imputedForce!)
		}
	}
	
	
	/**
	Determines the background speed factor based on the character's current speed.
	
	- returns: A factor to be be used in computing the background's effective speed.
	*/
	func determineBackgroundSpeedFactor() -> Float {
		var factor:Float = 0.0
		let speedDivisionFactor:Float = 100.0 //100 rounds off the speed in a nice way as the velocity goes between 0 and 1000 on average
		if let char = character {
			let speed = char.sprite.physicsBody?.velocity.dx
			if let spd = speed {
				factor = abs(Float(spd)/speedDivisionFactor)
				// absolute value because the direction handling is done in the parallax scrolling class.
			}
		}
		
		return factor
	}
	
	/**
	Handles what happens when a level is completed.
	*/
	func levelFinish() {
		scenePaused = true
		gameViewControllerDelegate?.endLevel()
	}
	
	
	/**
	Pans the camera to a specific location within the scene and then pans back to the original location.
	
	:param: location The CGPoint describing the location
	:param: duration How long the camera will take to get there (affects the speed the camera moves... d/t)
	:param: wait     How long the camera will wait until it pans back to the original location. 
	*/
	func panCameraToLocation(_ location:CGPoint, forDuration duration:TimeInterval, andThenWait wait:TimeInterval)
	{
		if let camera = camera
		{
			//Set the default direction and change it if necessary
			var toParallaxDirection:PBParallaxBackgroundDirection = kPBParallaxBackgroundDirectionRight
			
			if(location.x > camera.position.x) {
				toParallaxDirection = kPBParallaxBackgroundDirectionLeft
			}
			scenePaused = true
			
			let cameraOrigin = camera.position
			
			//This is the direction the parallax background needs to be moving for the pan direction.
			let setParallaxToDir = SKAction.run({
				if let farOut = self.farOutBackground {
					farOut.direction = toParallaxDirection
				}
				
				if let parallax = self.parallaxBackground {
					parallax.direction = toParallaxDirection
				}
				self.cameraSpeed = (distanceBetweenPointOne(cameraOrigin, andPointTwo: location) / Float(duration)) / 100.0
			})
			
			let reverseParallax = SKAction.run( {
				self.farOutBackground?.reverseMovementDirection()
				self.parallaxBackground?.reverseMovementDirection()
				self.cameraSpeed = (distanceBetweenPointOne(cameraOrigin, andPointTwo: location) / Float(duration)) / 100.0
				
			})
			
			let panCamera = SKAction.sequence([SKAction.move(to: location, duration: duration),SKAction.run({
				self.cameraSpeed = 0
			})])
			
			let panCameraBack = SKAction.move(to: cameraOrigin, duration: duration)
			let unpause = SKAction.run({
				self.scenePaused = false
				self.isPaused = false
			})
			
			let cameraAction:SKAction = SKAction.sequence([setParallaxToDir,panCamera,SKAction.wait(forDuration: wait),reverseParallax, panCameraBack,unpause])
			
			camera.run(cameraAction)
		}
	}
	
	
	/**
	Moves the camera based upon the character. Allows for one to one dependent X movement and Y movement based upon the original height of the scene.
	*/
	fileprivate func trackCameraToCharacter(){
		if let camera = camera {
			if let character = character {
                trackCameraX(camera, toCharacter: character)
                trackCameraY(camera, toCharacter: character)
			}
		}
	}
    
    /**
     Tracks the camera's X to the character's X
     This implementation assumes that the character and camera x start at the same 
     value, which is easily configured through the .sks file. Future improvement
     is to add multiple direction tracking so that camera will start at any point and
     move to character before 1-1 tracking, similar to Y tracking.
     
     - parameter camera:    <#camera description#>
     - parameter character: <#character description#>
     */
    fileprivate func trackCameraX(_ camera:SKCameraNode, toCharacter character:Character){
        camera.position.x = character.sprite.position.x
    }
    
    
    /**
     Tracks the character's Y position if the character is above the half screen mark. 
     Camera is at the half screen mark otherwise.
     
     - parameter camera:    SKCameraNode to position
     - parameter character: Character to track
     */
    fileprivate func trackCameraY(_ camera:SKCameraNode, toCharacter character:Character){
        let characterHeightThreshold:CGFloat = 0.5
        let cameraHeightThreshold:CGFloat = 7

        //Vertically moves the camera if the character is above the top of the initial viewport
        switch (character.sprite.position.y - self.size.height) {
        case let aboveHeight where aboveHeight > characterHeightThreshold:
            moveCamera(camera,
                       toY: character.sprite.position.y,
                       withDistanceThreshold: cameraHeightThreshold)
        
        case let belowHeight where belowHeight <= characterHeightThreshold:
            moveCamera(camera,
                      toY: self.size.height / 2,
                      withDistanceThreshold: cameraHeightThreshold)
        default:
            camera.position.y = (self.size.height/2)
        }
    }
    
    fileprivate func moveCamera(_ camera:SKCameraNode, toY y:CGFloat, withDistanceThreshold threshold:CGFloat) {
        
        switch (camera.position.y - y) {
        case let difference where difference < -threshold:
            camera.position.y += threshold
        case let difference where difference < -threshold && difference <= 0:
            camera.position.y += difference
        case let difference where difference > threshold:
            camera.position.y -= threshold
        case let difference where difference > -threshold && difference >= 0:
            camera.position.y -= difference
        default:
            camera.position.y = y
        }
    }
	
	/**
	Aligns the parallax background position with the cameraNode position that way the
	background follows along with the camera.
	
	The background speeds are increased with a factor determined by the character's speed.
	*/
	fileprivate func updateBackground(){
		if let camera = camera{
			
			// Aligns the parallax background position with the cameraNode position that way the
			// background follows along with the camera.
			
			self.parallaxBackground?.position.x = camera.position.x
			self.farOutBackground?.position.x = camera.position.x
			
			let backgroundSpeedFactor = determineBackgroundSpeedFactor()
			farOutBackground?.updateWithSpeedModified(byFactor: backgroundSpeedFactor)
			parallaxBackground?.updateWithSpeedModified(byFactor: backgroundSpeedFactor)
			
			if let character = character {
				if(character.direction == .right) {
					parallaxBackground?.direction = kPBParallaxBackgroundDirectionLeft
					farOutBackground?.direction = kPBParallaxBackgroundDirectionLeft
				}
				else if(character.direction == .left) {
					parallaxBackground?.direction = kPBParallaxBackgroundDirectionRight
					farOutBackground?.direction = kPBParallaxBackgroundDirectionRight
				}
			}
			
		}
	}
}

//MARK: SKPhysicsContactDelegate
extension CuriosityScene: SKPhysicsContactDelegate
{
	func didBegin(_ contact: SKPhysicsContact) {
		jumpCount = 0
		determineItemContactBetweenBodies(contact.bodyA, bodyB: contact.bodyB)
		determineEnvironmentContactBetweenBodies(contact.bodyA, bodyB: contact.bodyB)
	}
	
	
	/**
	Determines whether an item contacted a character and performs the item's stored effect if so.
	
	- parameter bodyA: SKPhysics body labeled A
	- parameter bodyB: SKPhysics body labeled B
	*/
	func determineItemContactBetweenBodies(_ bodyA:SKPhysicsBody, bodyB:SKPhysicsBody)
	{
		var item:CuriositySpriteNode?
		
		//Item Contact
		if(bodyA.categoryBitMask == PhysicsCategory.character.rawValue &&
			bodyB.categoryBitMask == PhysicsCategory.item.rawValue) {
			item = (bodyB.node as! CuriositySpriteNode)
		}
		else if (bodyB.categoryBitMask == PhysicsCategory.character.rawValue &&
			bodyA.categoryBitMask == PhysicsCategory.item.rawValue) {
			item = (bodyA.node as! CuriositySpriteNode)
		}
		
		if let validItem = item {
			validItem.storedEffect?()
			
			//This assumes we want to remove all items from parent at time of initial use. May need to extract and refactor...
			validItem.storedEffect = nil
			validItem.removeFromParent()
		}
	}
	
	
	/**
	Determines whether an Environment contacted a character and has particular effects if the Environment is of
	a particular type. eg:Level Finish environments.
	qv
	- parameter bodyA: SKPhysics body labeled A
	- parameter bodyB: SKPhysics body labeled B
	*/
	func determineEnvironmentContactBetweenBodies(_ bodyA:SKPhysicsBody, bodyB:SKPhysicsBody) {
        let finishNodeName = "Finish"
        var environment:SKSpriteNode?
        
        switch (bodyA.categoryBitMask, bodyB.categoryBitMask) {
        case let (a, b) where
            a == PhysicsCategory.character.rawValue &&
            b == PhysicsCategory.environment.rawValue:
            
            environment = bodyB.node as? SKSpriteNode
        case let (a,b) where
            b == PhysicsCategory.character.rawValue &&
            a == PhysicsCategory.environment.rawValue:
            
            environment = bodyA.node as? SKSpriteNode
        case let (a,b) where
            a == PhysicsCategory.environment.rawValue &&
            b == PhysicsCategory.environment.rawValue:
            
            let envA = bodyA.node as? SKSpriteNode
            let envB = bodyB.node as? SKSpriteNode
            let emitter = SKEmitterNode(fileNamed: "smokeParticle")
            
            if (envA?.name == finishNodeName) {
                emitter?.position = (envB?.position)!
                self.addChild(emitter!)
                envB?.removeFromParent()
            }
            else if (envB?.name == finishNodeName) {
                emitter?.position = (envA?.position)!
                self.addChild(emitter!)
                envA?.removeFromParent()
            }
        default:
           break
            
        }
		
		if let validEnv = environment {
			if validEnv.name == finishNodeName {
				levelFinish()
				}
        }
	}
	
}

