//
//  ViewController.swift
//  Conversor
//
//  Created by Victor Alonso on 2018-11-14.
//  Copyright © 2018 Victor Alonso. All rights reserved.
//

import UIKit
import SVProgressHUD
import ChameleonFramework
import SwiftyJSON
import Alamofire

let defaults = UserDefaults.standard

class ViewController: UIViewController{
    
    
    //MARK: - Variables and Constants
    /***************************************************************/
    
    //API Key = "02a9b6250b52e3c537cda831062b4f10"
    let baseURL = "http://data.fixer.io/api/latest?access_key=02a9b6250b52e3c537cda831062b4f10&symbols=CAD"
    
    var rateEUR : Double = 0
    var rateDOLLAR : Double = 0
    let todayString = Date().description(with: .current)
    
    //MARK: - Override functions
    /***************************************************************/
    
    //Keyboard appear at the beggining
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Type of keyboard
        textField.keyboardType = UIKeyboardType.decimalPad
        //Appear at the beggining
        textField.becomeFirstResponder()
    }
    
    //Set up at the beggining
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show()
        
        //Get the data from internet
        getMoneyData(url: baseURL)
        
        //Put in the screen the last values saved
        textField.text = defaults.string(forKey: "lastTextField")
        moneyLabel.text = defaults.string(forKey: "LastMoneyLabel")
        
    }

    
    //MARK: - IBOutlets, IBActions
    /***************************************************************/
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var updateLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet var totalView: UIView!
    
    @IBAction func changeBut(_ sender: UIButton) {
        //Save the last value in the textField
        defaults.set(textField.text, forKey: "lastTextField")
        
        //Animate Button & Label
        moneyLabel.zoomIn()
        sender.boing()
        
        //Separate the action depend on the button
        if sender.tag == 1 {
            convert(rate: rateEUR, symbol: "euro")
        }else if sender.tag == 2{
            convert(rate: rateDOLLAR, symbol: "dollar")
        }
    }

    //MARK: - Convert money function
    /***************************************************************/
    
    func convert(rate : Double, symbol : String){

        //Multiply the textfield to the current rate and change the current type text
        if var priceText = Double(textField.text!){
            priceText = priceText * rate
            
            moneyLabel.text = priceText.changeFormat(currency: symbol)
            
            defaults.set(moneyLabel.text, forKey: "LastMoneyLabel")
            
        }else {
            moneyLabel.text = ""
            
            totalView.shake()
            
            SVProgressHUD.showError(withStatus: "Please insert value")
            SVProgressHUD.dismiss(withDelay: 0.7)
        }
    }
    
    //MARK: - Networking, Alamofire (Automatically at the beggining)
    /***************************************************************/

    func getMoneyData(url: String) {

        Alamofire.request(url, method: .get).responseJSON {
            response in
            if response.result.isSuccess {
                //GOT THE DATA FROM INTERNET
                self.loadingLabel.text = ""
                SVProgressHUD.dismiss()
                
                self.updateMoneyData(json: JSON(response.result.value!))
                
                self.updateLabel.text = "Last update:  Now"

            } else {
                //NO INTERNET
                self.loadingLabel.text = "Offline mode"
                SVProgressHUD.dismiss()
  
                self.updateValues(moneyRate: defaults.double(forKey: "lastValue"))
                
                let dateString = defaults.string(forKey: "lastDate")
                
                let lastDate = dateString!.toDate()
                
                if lastDate < Date() {
                    self.updateLabel.text = "Last update: Earlier today"
                }else{
                    self.updateLabel.text = "Last update: One day or more"
                }
            }
        }
    }

    //MARK: - JSON Parsing //At the beggining if you have internet
    /***************************************************************/

    func updateMoneyData(json : JSON) {
        
        if json["success"] == true{
            
            //Save MONEY value
            defaults.set(json["rates"]["CAD"].doubleValue, forKey: "lastValue")
            //Save DAY value
            defaults.set(json["date"].stringValue, forKey: "lastDate")
            
            updateValues(moneyRate: (json["rates"]["CAD"].doubleValue))
            
        }else {
            print("Error connection")
        }
    }
    
    //MARK: - Set value function //At the beggining
    /***************************************************************/
    
    func updateValues(moneyRate : Double) {
        rateEUR = 1/moneyRate
        rateDOLLAR = moneyRate
      
        rateLabel.text = "Courrent rate:  \((moneyRate).roundWithDecimal(decimals: 4))"
    }
    
}

