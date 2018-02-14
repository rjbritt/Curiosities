//
//  Character.swift
//  Characters designed to be used to play Curiosity.
//  Curiosity
//
//

import UIKit
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


class Character
{
    enum XDirection
    {
        case right, left, none
    }
    
    //MARK: Private Properties
    fileprivate let leftVelocityMovementThreshold:CGFloat = -0.1 // m/s that determines if the character is moving to the left.
    fileprivate let rightVelocityMovementThreshold:CGFloat = 0.1 // m/s that determines if the character is moving to the right.
    
    //MARK: Public Properties
    var sprite:SKSpriteNode
    var jumpXMovementConstant:Double = 0 //Determines the amount of movement allowed midair while jumping
    var torqueConstant:Double = 0 //Determines the amount of torque applied during movement
    var jumpConstant:CGFloat = 0 //Determines the amount of vertical impulse applied during a jump
    
    var jumpVelocityThreshold:CGFloat = 50 //character must be ascending with more velocity than this threshold
    var fallingVelocityThreshold:CGFloat = -30 //character must be descending with more velocity than this threshold.
    
    var accelerationX:Double = 0
    var accelerationY:Double = 0
    
    var canJump = true
    
    //MARK: Initializers
    init(spriteNode:SKSpriteNode) {
        sprite = spriteNode
    }
    
    //MARK: Computed Properties
    var isFalling:Bool {
        if sprite.physicsBody?.velocity.dy < fallingVelocityThreshold {
            return true
        }
        return false
    }
    
    var isJumping:Bool // Computed property to tell whether the character is jumping or not.
        {
            if ((sprite.physicsBody?.velocity.dy > jumpVelocityThreshold))
            {
                return true
            }
            return false
            
        }
    
    var direction:XDirection //Computed property to tell the direction of the character
    {
        if (sprite.physicsBody?.velocity.dx > rightVelocityMovementThreshold)
        {
            return .right
        }
        else if (sprite.physicsBody?.velocity.dx < leftVelocityMovementThreshold)
        {
            return .left
        }
        return .none
        
    }
    
    //MARK: Class Methods

    /**
    Returns a default character configuration.
    */
	class func defaultCharacter() -> Character
    {
        var character:Character
        character = Character(spriteNode: SKSpriteNode(imageNamed: "Ball"))
        
        character.sprite.name = "Character"
        character.sprite.physicsBody = SKPhysicsBody(circleOfRadius: character.sprite.size.height/2)
        character.sprite.physicsBody?.mass = 0.2
        character.jumpXMovementConstant = 1.5
        character.torqueConstant = 10
        character.jumpConstant = 75
        
        character.sprite.physicsBody?.affectedByGravity = true
        character.sprite.physicsBody?.allowsRotation = true
        character.sprite.physicsBody?.categoryBitMask = PhysicsCategory.character.rawValue
        character.sprite.physicsBody?.friction = 1.0
		
        return character
    }
    
    //MARK: Instance Methods
    /**
     Commands the character to perform the physics related to a jump
     
     - parameter multiplier: A multiplier to apply to the jumpConstant. This allows variable jump height.
     */
    func jump(_ multiplier:CGFloat)
    {
        //resets the Y velocity so the current velocity has no impact on net jump height.
        sprite.physicsBody?.velocity.dy = 0
        sprite.physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpConstant * multiplier))
    }
    
    /**
    Approximation of a torque curve for characters. Doubles the torque applied within the first 90 m/s of their X velocity
    
    - parameter velocity: The full velocity vector of the character
    
    - returns: An appropriate torque depending on the character's X velocity and the tilt of the device.
    */
    func torqueToApplyForCharacterWithVelocity(_ velocity:CGVector) -> CGFloat
    {
        
        var torque:CGFloat = CGFloat(-accelerationX / torqueConstant)

        //If velocity is below a certain threshold, apply double the torque to get the character moving faster
        if fabs(velocity.dx) < 90.0
        {
            torque *= 2
        }
        
        //If acceleration is in the opposite direction as velocity, double the torque again to change directions
        if(CGFloat(accelerationX) * velocity.dx < 0)
        {
            torque *= 2
        }
        
        return torque
    }
    
    /**
     Commands the character to move. Physics are applied to the sprite's physicsBody, meaning the effects of a move are
     felt outside of the one frame that this method is called.
    */
    func move() {
        let deltaX = CGFloat(accelerationX * jumpXMovementConstant)
        
        let torqueX = torqueToApplyForCharacterWithVelocity(sprite.physicsBody!.velocity)
  
        // Determines any side motion in air
        if (isJumping)
        {
            sprite.physicsBody?.applyImpulse(CGVector(dx: deltaX, dy: 0))
        }
        // Defaults to determining side motion on an area marked as solid
        else
        {
            sprite.physicsBody?.applyTorque(torqueX)
        }
    }
}
