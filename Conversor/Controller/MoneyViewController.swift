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
    
    let APIKey = "02a9b6250b52e3c537cda831062b4f10"
    let baseURL = "http://data.fixer.io/api/latest?access_key=02a9b6250b52e3c537cda831062b4f10&symbols=CAD"
    
    var changeEur : Double = 0
    var changeDollar : Double = 0
    let todayString = Date().description(with: .current)
    
    //MARK: - Override functions
    /***************************************************************/
    
    //Keyboard appear at the beggining
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    //Set up at the beggining
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getMoneyData(url: baseURL)
        
        textField.keyboardType = UIKeyboardType.decimalPad
        
        SVProgressHUD.setCornerRadius(25)
        SVProgressHUD.setBorderWidth(5)
        
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
    @IBOutlet var mainView: UIView!
    
    @IBAction func changeBut(_ sender: UIButton) {
        //Save the last value in the textField
        defaults.set(textField.text, forKey: "lastTextField")
        
        //Animate Button & Label
        moneyLabel.zoomIn()
        sender.boing()
        
        //Separate the action depend on the button
        if sender.tag == 1 {
            convert(type: changeEur, symbol: "€")
        }else if sender.tag == 2{
            convert(type: changeDollar, symbol: "$")
        }
    }
    
    
    
    
    //MARK: - Convert money function
    /***************************************************************/
    
    func convert(type : Double, symbol : String){
        
        //Set the formate of the number to $ or €
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        
        if symbol == "€" {
            currencyFormatter.locale = Locale(identifier: "es_ES")
        }else if symbol == "$" {
            currencyFormatter.locale = NSLocale.current
        }
        
        //Round the number to 2 decimal digits
        if var priceText = Double(textField.text!){
            priceText = (priceText * type * 100).rounded()/100
        
            let priceString = currencyFormatter.string(from: priceText as NSNumber)
            
            
            moneyLabel.text = priceString
            
            defaults.set(moneyLabel.text, forKey: "LastMoneyLabel")
            
        }else {
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
                
                self.updateMoneyData(json: JSON(response.result.value!))
                
                self.updateLabel.text = "Last update:  Now"

            } else {
                //NO INTERNET
                self.loadingLabel.text = "Offline mode"
  
                self.updateValues(moneyValue: defaults.double(forKey: "lastValue"))
                
                let dateString = defaults.string(forKey: "lastDate")
                
                DateFormatter().dateFormat = "yyyy-MM-dd"
                let lastDate = DateFormatter().date(from: dateString!)
                let todayDate = DateFormatter().date(from: self.todayString)
                
                if lastDate == todayDate {
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
            
            updateValues(moneyValue: (json["rates"]["CAD"].doubleValue))
            
        }else {
            print("Error connection")
        }
    }
    
    //MARK: - Set value function //At the beggining
    /***************************************************************/
    
    func updateValues(moneyValue : Double) {
        changeEur = 1/moneyValue
        changeDollar = moneyValue
      
        rateLabel.text = "Courrent rate:  \((moneyValue*1000).rounded()/1000)"

    }
    
}

