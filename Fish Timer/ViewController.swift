//
//  ViewController.swift
//  Fish Timer
//
//  Created by Aiden Siegle on 8/18/20.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    
    @IBOutlet var FoodButtons: [FoodButton]!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet var currentFoodImage: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var promptLabel: UILabel!
    
    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
//    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    
    var currentTime = 0 //use to display timers current time (display)
    var cycleCount = 0  //use to track total time timers run
    var timerStartTime: Date!
    var selectedStages = (0,0,0,0)
    var currentStage = 0
    var timer = Timer()
    
    let foodTimes = ["Fish"  :[30,40,80, 380],
                     "Trophy Fish":[80,90,180, 480],
                     "Meat"  :[50,60,120, 420], //50,60,120,420
                     "Megaladon"   :[100,120,240, 540],
                     "Kraken":[100,120,240, 540],
                     "Fruit" :[0,0,15, 315],
                     "Bait"  :[0,0,10, 310]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        impactFeedbackgenerator.prepare()
//        notificationFeedbackGenerator.prepare()
        
        //Set Labels
        statusLabel.text = "Select a Food Type"
        statusLabel.isHidden = true
        timerLabel.isHidden = true
        promptLabel.isHidden = false
        cancelButton.isHidden = true
        
        currentFoodImage.layer.shadowOpacity = 1
        currentFoodImage.layer.shadowOffset = .zero
        currentFoodImage.layer.masksToBounds = false

        currentFoodImage.layer.shadowColor = UIColor.black.cgColor
        currentFoodImage.layer.shadowRadius = 2
        
        //Populate Buttons
        FoodButtons[0].FoodButton(food: "Fish", raw: "fish_raw.png", under: "fish_under.png", cooked: "fish_cooked.png", burnt: "fish_burnt.png")
        
        FoodButtons[1].label.text = "Trophy Fish"
        FoodButtons[1].image.image = UIImage(named: "fishTrophy.png")
        
        FoodButtons[2].label.text = "Megaladon"
        FoodButtons[2].image.image = UIImage(named: "Megalodon.png")
        
        FoodButtons[3].label.text = "Kraken"
        FoodButtons[3].image.image = UIImage(named: "fish.png")
        
        FoodButtons[4].FoodButton(food: "Meat", raw: "meat_raw.png", under: "meat_under.png", cooked: "meat_cooked.png", burnt: "meat_burnt.png")
        FoodButtons[5].FoodButton(food: "Fruit", raw: "fruit_raw.png", under: "fruit_raw.png", cooked: "fruit_raw.png", burnt: "fruit_burnt.png")
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            if success {
                print("Notifications Accepted")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    //convers seconds to minutes+seconds
    //based on code from https://stackoverflow.com/questions/26794703/swift-integer-conversion-to-hours-minutes-seconds
    func secondsToMinutesSeconds (seconds : Int) -> (Int, Int) {
      return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    //Called every second for timer
    @objc func tickTimer() {
        //keeps track of current time using elapsed time since timer start
        //this allows the timer to "run in the background" and keep accurate time when reopened
        let elapsed = Date().timeIntervalSince(timerStartTime)
        cycleCount = Int(elapsed)
        let button = timer.userInfo as! FoodButton?

        
        
        //Keeps track of current stage, updating status label and providing vibration feedback as needed
        if ((selectedStages.0 == selectedStages.1) && cycleCount == 1){ //Special case for fruits
//            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            statusLabel.text = "You can't cook fruit! \n Time until burnt:"
            timerLabel.textColor = UIColor.orange
            currentStage = 2
            
        } else if ((cycleCount >= selectedStages.0) && (currentStage == 0)){ //undercooked
            currentStage = 1
            //transitions to next stages image
            let toImage = button?.under
            UIView.transition(with: currentFoodImage, duration: 2.0, options: .transitionCrossDissolve, animations: {
                                self.currentFoodImage.image = toImage
                              }, completion: nil)
            
        } else if ((cycleCount >= selectedStages.1)  && (currentStage == 1)) { //cooked
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            statusLabel.text = "Done cooking! \n Time until burnt:"
            currentTime = selectedStages.2
            timerLabel.textColor = UIColor.orange
            currentStage = 2
            
            let toImage = button?.cooked
            UIView.transition(with: currentFoodImage, duration: 2.0, options: .transitionCrossDissolve, animations: {
                                self.currentFoodImage.image = toImage
                              }, completion: nil)
            
        } else if ((cycleCount >= selectedStages.2)  && (currentStage == 2)) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            statusLabel.text = "Burnt! \n Time until fire:"
            currentTime = selectedStages.3
            timerLabel.textColor = UIColor.red
            currentStage = 3
            
            let toImage = button?.burnt
            UIView.transition(with: currentFoodImage, duration: 2.0, options: .transitionCrossDissolve, animations: {
                                self.currentFoodImage.image = toImage
                              }, completion: nil)
            
        } else if (cycleCount >= selectedStages.3) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            statusLabel.text = "A fire has started!"
            timerLabel.text = ""
            currentFoodImage.layer.shadowColor = UIColor.red.cgColor
            currentFoodImage.layer.shadowRadius = 15
            cancelButton.isHidden = true
            timer.invalidate()
        }
        
        //Updates timer
        var (m, s) = secondsToMinutesSeconds(seconds: currentTime - cycleCount) //converts time
        if (s < 0){ s = 0 } //purely cosmetic, just to avoid ugly timer numbers in some edge cases
        timerLabel.text = String(format: "%01d:%02d", m, s)
    }


    //each stack has it's own Tap recognizer, but they share an action
    @IBAction func onPress(_ sender: UILongPressGestureRecognizer) {
        //clear any previous notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
 
        let view = sender.view
        let button = (view?.subviews[0])! as! FoodButton //get stackView from UIView
        let name = button.label.text ?? "Error" //Get name of food
        
//        let currentColor = UIColor.copy(view?.backgroundColor ?? UIColor.gray)
//        print(view?.backgroundColor.self)
                
        if sender.state == .began {
            //begin animation
            UIView.animate(withDuration: 0.1, animations: {
                view?.backgroundColor = UIColor.init(named: "BackgroundColor")
                view?.transform = CGAffineTransform(scaleX: 0.95, y: 0.93)
            })
            
        }
        if sender.state == .ended {
            //haptic feedback, end animation
            impactFeedbackgenerator.impactOccurred()
             UIView.animate(withDuration: 0.1, animations: {
                view?.transform = CGAffineTransform.identity
                view?.backgroundColor = UIColor.separator
             })
           
            
        
            timer.invalidate() //end any timers that may have been running
            timerLabel.textColor = UIColor.label //Reset label color
            currentFoodImage.image = button.image.image //set image of cooking fish
            cancelButton.isHidden = false //Show cancel button
            statusLabel.isHidden = false
            timerLabel.isHidden = false
            promptLabel.isHidden = true
            timerStartTime = Date() //get current time at timer start, used to track current time
            cycleCount = 0
            
            currentFoodImage.layer.shadowColor = UIColor.black.cgColor
            currentFoodImage.layer.shadowRadius = 2
           
            //Create tuple of all stages for current food
            selectedStages = (foodTimes[name]?[0] ?? 0, foodTimes[name]?[1] ?? 0, foodTimes[name]?[2] ?? 0, foodTimes[name]?[3] ?? 0)
            currentStage = 0
            
            //create notifcations
            createNotifications(name: name, stages: selectedStages)
            
            //Special case for fruit, which go straight to burning
            if (selectedStages.1 != 0) {
                statusLabel.text = "Cooking..." //Set status text
                currentTime = selectedStages.1
            } else {
                statusLabel.text = "You can't cook fruit! \n Time until burnt:"
                timerLabel.textColor = UIColor.orange
                currentTime = selectedStages.2
            }
            
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(tickTimer), userInfo:button, repeats: true)
            let (m, s) = secondsToMinutesSeconds(seconds: currentTime)
            timerLabel.text = String(format: "%01d:%02d", m, s) //update time to start time

            //Allow timer to run on background task
            RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        }
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests() //clear any previous notifications
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
    
    
    func createNotifications(name: String, stages: (Int,Int,Int,Int)){
        
        var trigger: UNTimeIntervalNotificationTrigger
        var request: UNNotificationRequest
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default

        if(stages.0 != stages.1){
            content.title = "Done Cooking!"
            content.body = "Your \(name) is done cooking"
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(stages.1), repeats: false)
            request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
//        let content = UNMutableNotificationContent()
        content.title = "Burnt!"
        content.body = "Oh no, your \(name) has burned"
        trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(stages.2), repeats: false)
        request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        
        content.title = "Fire!"
        content.body = "Watch out, your \(name) has caught fire"
        trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(stages.3), repeats: false)
        request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        
    }
    
    
    
    
  
    
    

}

