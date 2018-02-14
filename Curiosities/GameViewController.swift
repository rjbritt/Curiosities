
//
//  GameViewController.swift
//  This view controller manages the view that presents the CuriosityScene SKScene. It handles
//  the delegation of the level setup to the scene extension methods and loads the 
//  CuriosityScene from the appropriate .sks file as declared in the levelSelected property.
//
//

import UIKit 
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(_ file : String?) -> SKNode? {
        if let path = Bundle.main.path(forResource: file, ofType: "sks") {
            var sceneData: Data?
            do {
                sceneData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            } catch _ {
                sceneData = nil
            }
            let archiver = NSKeyedUnarchiver(forReadingWith: sceneData!)
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! CuriosityScene
            archiver.finishDecoding()
			
			scene.size = CGSize(width: 736, height: 414)
			
            return scene
        } else {
            return nil
        }
    }
    
}


class GameViewController: UIViewController
{
    var levelMgr:LevelTracker = LevelTracker()
    weak var scene:CuriosityScene?
    fileprivate var force:CGFloat = 0
    fileprivate var debugGame = false
    
    /**
    Configures the scene depending on the current level and 
    conditionally calls methods based on what level has been selected with the scene.
    */
    func prepareCuriosityScene()
    {
        if let scene = CuriosityScene.unarchiveFromFile(levelMgr.currentLevel.rawValue) as? CuriosityScene
        {
            self.scene = scene
            
            // Configure the view.
            let skView = self.view as! SKView
            
            if (debugGame) {
                skView.showsFPS = true
                skView.showsNodeCount = true
                skView.showsDrawCount = true
            }
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = SKSceneScaleMode.resizeFill
            
            scene.gameViewControllerDelegate = self
            
            //Configure the logic for each level
            switch levelMgr.currentLevel
            {
                
            case .Tut1:
                GameLevelConfig.configureTutorialForScene(scene, TutorialNumber: 1)
            case .Tut2:
                GameLevelConfig.configureTutorialForScene(scene, TutorialNumber: 2)
            case .Tut3:
                GameLevelConfig.configureTutorialForScene(scene, TutorialNumber: 3)
            case .Tut4:
                GameLevelConfig.configureTutorialForScene(scene, TutorialNumber: 4)
                break
            case .Level1:
                GameLevelConfig.configureLevel1ForScene(scene)
            case .Level2:
                GameLevelConfig.configureLevel2ForScene(scene)
 
            }
			
			scene.orientation = UIApplication.shared.statusBarOrientation
            
            skView.presentScene(scene)
        }
    }
	//MARK: View Lifecycle methods
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		prepareCuriosityScene()
	}
	
    override var shouldAutorotate : Bool {
        return false
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.landscape
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Memory Warning")
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let scalingFactor = touch.maximumPossibleForce / 2.0
            force = max((touch.force)/scalingFactor, force)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        scene?.jump(force)
        force = 0
    }
}

//MARK: Delegate Methods
extension GameViewController {
	/**
	Ends the game level by presenting the view controller that is after a finished game scene and before a new game scene.
	Typically used as a callback when a GameViewController is set as a delegate to any other class.
	*/
	func endLevel()
	{
        //No matter the selection, unlock the next level.
        levelMgr.nextLevel()
        
        let alert = UIAlertController(title: "Finished", message: "You've finished the level!", preferredStyle: .actionSheet)
        let selectLevel = UIAlertAction(title: "Return to Level Select", style: .default) { (alert: UIAlertAction!) -> Void in
            self.returnToLevelSelect()
        }
        
        let  nextLevel = UIAlertAction(title: "Next Level", style: .default) { (alert: UIAlertAction!) -> Void in
            self.prepareCuriosityScene()
        }
        
        alert.addAction(nextLevel)
        alert.addAction(selectLevel)
        present(alert, animated: true, completion:nil)
	}
	
	/**
	Returns the user to the level select view controller.
	Typically used as a callback when a GameViewController is set as a delegate to any other class.
	*/
	func returnToLevelSelect()
	{
		//Dismisses this view controller
		self.presentingViewController?.dismiss(animated: false, completion:{
            //presenting a new nil scene triggers the previous scene's willMoveFromView
            let skView = self.view as! SKView
            skView.presentScene(nil)
		})
		
	}
	
	
}
