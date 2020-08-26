//
//  ViewController.swift
//  Fish Timer
//
//  Created by Aiden Siegle on 8/18/20.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet var FoodButtons: [FoodButton]!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet var currentFoodImage: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    
    var currentTime = 0
    var timer = Timer()
    
    let foodTimes = ["Fish"  :[30,40,80, 380],
                     "Trophy Fish":[80,90,180, 480],
                     "Meat"  :[50,60,120, 420],
                     "Megaladon"   :[100,120,240, 540],
                     "Kraken":[100,120,240, 540],
                     "Fruit" :[0,0,15, 315],
                     "Bait"  :[0,0,10, 310]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set Labels
        statusLabel.text = "Select a Food Type"
        cancelButton.isHidden = true
        
        //Populate Buttons
        FoodButtons[0].label.text = "Fish"
        FoodButtons[0].image.image = UIImage(named: "fish.png")
        
        FoodButtons[1].label.text = "Trophy Fish"
        FoodButtons[1].image.image = UIImage(named: "fishTrophy.png")
        
        FoodButtons[2].label.text = "Megaladon"
        FoodButtons[2].image.image = UIImage(named: "Megalodon.png")
        
        FoodButtons[3].label.text = "Kraken"
        FoodButtons[3].image.image = UIImage(named: "fish.png")
        
        FoodButtons[4].label.text = "Meat"
        FoodButtons[4].image.image = UIImage(named: "fish.png")
        
        FoodButtons[5].label.text = "Fruit"
        FoodButtons[5].image.image = UIImage(named: "fish.png")
    }
    
    //convers seconds to minutes+seconds
    //based on code from https://stackoverflow.com/questions/26794703/swift-integer-conversion-to-hours-minutes-seconds
    func secondsToMinutesSeconds (seconds : Int) -> (Int, Int) {
      return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    //Called every second for timer
    @objc func tickTimer() {
        currentTime -= 1
        let (m, s) = secondsToMinutesSeconds(seconds: currentTime) //converts time

        timerLabel.text = String(format: "%01d:%02d", m, s) //updates timer
//        print(currentTime)
                
        if (currentTime <= 0) {
            timerLabel.text = "Done!"
            statusLabel.text = ""
            cancelButton.isHidden = true
//            currentFoodImage.image = nil
            timer.invalidate()
        }
    }


    //each stack has it's own Tap recognizer, but they share an action
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        timer.invalidate() //end any timers that may have been running
        
        let view = sender.view
        let button = (view?.subviews[0])! as! FoodButton //get stackView from UIView
        let name = button.label.text ?? "Error" //Get name of food
        
        statusLabel.text = "Cooking..." //Set status text
        currentFoodImage.image = button.image.image //set image of cooking fish
        cancelButton.isHidden = false //Show cancel button

        
        currentTime = foodTimes[name]?[1] ?? 0 //get time until cooked
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(tickTimer), userInfo: button, repeats: true)
        let (m, s) = secondsToMinutesSeconds(seconds: currentTime)
        timerLabel.text = String(format: "%01d:%02d", m, s) //update time to start time

        //Allow timer to run on background task
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        timer.invalidate()
        statusLabel.text = "Select a Food Type"
        timerLabel.text = "0:00"
        currentFoodImage.image = nil
        cancelButton.isHidden = true
    }
    
}

