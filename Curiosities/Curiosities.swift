//
//  Item.swift
//  Curiosity
//
//

import UIKit

class CuriositySpriteNode: SKSpriteNode
{
    /// An effect that is stored as a closure for later use.
    var storedEffect:(() -> ())?
    
    
    /**
    Class method that generates a Curiosity "orb" with a particular color.
    These orbs are used as generic items that can have any stored effect and will have an automatic
    pulsing action.
    
    - parameter color: UIColor to make the orb
    
    - returns: An ItemSpriteNode that is configured as a circular orb with a forever pulsing action.
    */
    class func orbItemWithColor(_ color:UIColor) -> CuriositySpriteNode
    {
        let image = UIImage(named: "spark")
        let tempItem = CuriositySpriteNode(texture: SKTexture(image: image!))
        
        tempItem.physicsBody = SKPhysicsBody(texture: tempItem.texture!, alphaThreshold: 0.9, size: tempItem.size)
        tempItem.physicsBody?.isDynamic = false
        
        tempItem.physicsBody?.categoryBitMask = PhysicsCategory.item.rawValue
        tempItem.physicsBody?.collisionBitMask = PhysicsCategory.character.rawValue
        tempItem.physicsBody?.contactTestBitMask = PhysicsCategory.character.rawValue
        
        tempItem.color = color
        tempItem.colorBlendFactor = 0.8
        
        let pulse = SKAction.repeatForever(SKAction.sequence([SKAction.scale(by: 2.0, duration: 1),
                                                                    SKAction.scale(to: 1.0, duration: 1)]))
        
        tempItem.run(pulse)
        
        return tempItem
        
    }
}

