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
    
    var currentTime = 0
    var timer = Timer()
    
    let foodTimes = ["Fish"  :[30,40,80, 380],
                     "Trophy Fish":[80,90,180, 480],
                     "meat"  :[50,60,120, 420],
                     "meg"   :[100,120,240, 540],
                     "kraken":[100,120,240, 540],
                     "fruit" :[0,0,15, 315],
                     "bait"  :[0,0,10, 310]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        FoodButtons[0].label.text = "Fish"
        FoodButtons[0].image.image = UIImage(named: "fish.png")
        FoodButtons[1].label.text = "Trophy Fish"
        FoodButtons[1].image.image = UIImage(named: "fishTrophy.png")
    }
    
    //convers seconds to minutes+seconds
    //based on code from https://stackoverflow.com/questions/26794703/swift-integer-conversion-to-hours-minutes-seconds
    func secondsToMinutesSeconds (seconds : Int) -> (Int, Int) {
      return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    //Called every second for timer
    @objc func tickTimer() {
        currentTime -= 1
        let (m, s) = secondsToMinutesSeconds(seconds: currentTime)

        timerLabel.text = String(format: "%01d:%02d", m, s) //"\(m):\(s)" //updates timer
        print(currentTime)
                
        if (currentTime == 0) {
            timerLabel.text = "Done!"
            timer.invalidate()
        }
    }


    //each stack has it's own Tap recognizer, but they share an action
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        timer.invalidate()
        
        let view = sender.view
        let button = (view?.subviews[0])! as! FoodButton
        let name = button.label.text ?? "Error"
        print(name)
        
        currentTime = foodTimes[name]?[1] ?? 0
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(tickTimer), userInfo: button, repeats: true)
        let (m, s) = secondsToMinutesSeconds(seconds: currentTime)
//        timerLabel.text = "\(m):\(s)"
        timerLabel.text = String(format: "%01d:%02d", m, s) 


        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        
        
       


    }
    

}

