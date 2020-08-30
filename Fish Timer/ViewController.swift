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
    @IBOutlet weak var promptLabel: UILabel!
    
    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    
    var currentTime = 0 //use to display timers current time (display)
    var cycleCount = 0  //use to track total time timers run
    var selectedStages = (0,0,0,0)
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
        
        impactFeedbackgenerator.prepare()
        notificationFeedbackGenerator.prepare()

        
        //Set Labels
        statusLabel.text = "Select a Food Type"
        statusLabel.isHidden = true
        timerLabel.isHidden = true
        promptLabel.isHidden = false
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
        cycleCount += 1
        currentTime -= 1
        
        //updates timer
        if ((selectedStages.0 == selectedStages.1) && cycleCount == 1){ //Special case for fruits
            notificationFeedbackGenerator.notificationOccurred(.warning)
            statusLabel.text = "You can't cook fruit! \n Time until burnt:"
            let (m, s) = secondsToMinutesSeconds(seconds: currentTime) //converts time
            timerLabel.text = String(format: "%01d:%02d", m, s)
            timerLabel.textColor = UIColor.orange
        } else if (cycleCount == selectedStages.0){ //undercooked
            //reserved
            let (m, s) = secondsToMinutesSeconds(seconds: currentTime) //converts time
            timerLabel.text = String(format: "%01d:%02d", m, s)
        } else if (cycleCount == selectedStages.1) { //cooked
            notificationFeedbackGenerator.notificationOccurred(.success)
            statusLabel.text = "Done cooking! \n Time until burnt:"
            currentTime = selectedStages.2 - selectedStages.1
            let (m, s) = secondsToMinutesSeconds(seconds: currentTime) //converts time
            timerLabel.text = String(format: "%01d:%02d", m, s)
            timerLabel.textColor = UIColor.orange
        } else if (cycleCount == selectedStages.2) {
            notificationFeedbackGenerator.notificationOccurred(.warning)
            statusLabel.text = "Burnt! \n Time until fire:"
            currentTime = selectedStages.3 - selectedStages.2
            let (m, s) = secondsToMinutesSeconds(seconds: currentTime) //converts time
            timerLabel.text = String(format: "%01d:%02d", m, s)
            timerLabel.textColor = UIColor.red
        } else if (cycleCount == selectedStages.3) {
            notificationFeedbackGenerator.notificationOccurred(.error)
            statusLabel.text = "A fire has started!"
            timerLabel.text = ""
            cancelButton.isHidden = true
            timer.invalidate()
        } else {
            let (m, s) = secondsToMinutesSeconds(seconds: currentTime) //converts time
            timerLabel.text = String(format: "%01d:%02d", m, s)
        }
        
        
                
//        if (currentTime <= 0) {
//            timerLabel.text = "Done!"
//            statusLabel.text = "Done cooking! \n Time until burnt:"
//            cancelButton.isHidden = true
// //            currentFoodImage.image = nil
// //            timer.invalidate()
//        }
    }


    //each stack has it's own Tap recognizer, but they share an action
    @IBAction func onPress(_ sender: UILongPressGestureRecognizer) {
 
        let view = sender.view
        let button = (view?.subviews[0])! as! FoodButton //get stackView from UIView
        let name = button.label.text ?? "Error" //Get name of food
                
        if sender.state == .began {
            impactFeedbackgenerator.impactOccurred()
            UIView.animate(withDuration: 0.1, animations: {
                view?.transform = CGAffineTransform(scaleX: 0.95, y: 0.93)
            })
        }
        if sender.state == .ended {
            impactFeedbackgenerator.impactOccurred()
             UIView.animate(withDuration: 0.1, animations: {
                view?.transform = CGAffineTransform.identity
             })
        
            timer.invalidate() //end any timers that may have been running
            timerLabel.textColor = UIColor.label //Reset label color
            currentFoodImage.image = button.image.image //set image of cooking fish
            cancelButton.isHidden = false //Show cancel button
            statusLabel.isHidden = false
            timerLabel.isHidden = false
            promptLabel.isHidden = true
            cycleCount = 0
           
            //Create tuple of all stages for current food
            selectedStages = (foodTimes[name]?[0] ?? 0, foodTimes[name]?[1] ?? 0, foodTimes[name]?[2] ?? 0, foodTimes[name]?[3] ?? 0)
            
            //Special case for fruit, which go straight to burning
            if (selectedStages.1 != 0) {
                statusLabel.text = "Cooking..." //Set status text
                currentTime = selectedStages.1
            } else {
                statusLabel.text = "You can't cook fruit! \n Time until burnt:"
                timerLabel.textColor = UIColor.orange
                currentTime = selectedStages.2
            }
            
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(tickTimer), userInfo: button, repeats: true)
            let (m, s) = secondsToMinutesSeconds(seconds: currentTime)
            timerLabel.text = String(format: "%01d:%02d", m, s) //update time to start time

            //Allow timer to run on background task
            RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        }
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        timer.invalidate()
        statusLabel.text = "Select a Food Type"
        timerLabel.textColor = UIColor.label
        timerLabel.text = "0:00"
        statusLabel.isHidden = true
        timerLabel.isHidden = true
        promptLabel.isHidden = false
        currentFoodImage.image = nil
        cancelButton.isHidden = true
    }
    
    
    
    
  
    
    

}

