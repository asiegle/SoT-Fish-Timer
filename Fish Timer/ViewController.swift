//
//  ViewController.swift
//  Fish Timer
//
//  Created by Aiden Siegle on 8/18/20.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet var FoodButtons: [FoodButton]!
    @IBOutlet weak var timer: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FoodButtons[0].label.text = "Fish"
        FoodButtons[1].label.text = "Trophy Fish"

        // Do any additional setup after loading the view.
        
    }


}

