//
//  FoodButton.swift
//  Fish Timer
//
//  Created by Aiden Siegle on 8/20/20.
//

import UIKit

class FoodButton: UIStackView {
    
//    var label: UILabel!
//    var image: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    //images for each stage
    var raw: UIImage!
    var under: UIImage!
    var cooked: UIImage!
    var burnt: UIImage!
    
    //Initializer function
    func FoodButton(food: String, raw: String, under: String, cooked: String, burnt: String){
        
        //sets values
        self.label.text = food
        self.raw = UIImage(named: raw)
        self.under = UIImage(named: under)
        self.cooked = UIImage(named: cooked)
        self.burnt = UIImage(named: burnt)
        self.image.image = self.raw
        
        //sets shadow propeties
        image.layer.shadowColor = UIColor.black.cgColor
        image.layer.shadowOpacity = 1
        image.layer.shadowOffset = .zero
        image.layer.shadowRadius = 1.5
        image.layer.masksToBounds = false
    }
    
    
    

}
