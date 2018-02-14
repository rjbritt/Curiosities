//
//  LevelSelectViewController.swift
//  Curiosity
//
//
//  This VC manages the logic for the main level choices.
//

import UIKit


class LevelSelectViewController: UIViewController {

    fileprivate let levelDescriptors = ["Tutorial", "Level 1", "Level 2"]
    @IBOutlet weak var tutorialButton: UIButton!
    @IBOutlet weak var level1Button: UIButton!
    @IBOutlet weak var level2Button: UIButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tutorialButton.alpha = 0
        self.level1Button.alpha = 0
        self.level2Button.alpha = 0
        
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.tutorialButton.alpha = 1
            self.level1Button.alpha = 1
            self.level2Button.alpha = 1
        }) 
        
        level1Button.isUserInteractionEnabled = LevelTracker.levelIsUnlocked(.Level1)
        level1Button.tintColor = level1Button.isUserInteractionEnabled ? view.tintColor : UIColor.gray
        level2Button.isUserInteractionEnabled = LevelTracker.levelIsUnlocked(.Level2)
        level2Button.tintColor = level2Button.isUserInteractionEnabled ? view.tintColor : UIColor.gray
    }
    
    @IBAction func goToLevel(_ sender: UIButton) {
        if let text = sender.titleLabel?.text {
            let gameVC = self.storyboard?.instantiateViewController(withIdentifier: "GameLevel") as? GameViewController
            switch text {
            case "Level 1":
                guard let lvl = gameVC?.levelMgr.goToLevel(.Level1), lvl else {return} //error state
            case "Level 2":
                guard let lvl = gameVC?.levelMgr.goToLevel(.Level2), lvl else {return} //error state
            default:
                //Starts the tutorial over if the tuturial has been completed, goes to the highest tutorial otherwise.
                guard let lvl = gameVC?.levelMgr.goToLevel(LevelTracker.levelIsUnlocked(.Level1) ? .Tut1 : LevelTracker.highestUnlockedLevel), lvl  else {return} //error state
            }
            if let gameVC = gameVC {
                self.show(gameVC, sender: nil)
            }
        }
    }
}


