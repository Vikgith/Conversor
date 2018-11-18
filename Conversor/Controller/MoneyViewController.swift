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
    
    @IBAction func changeToEur(_ sender: UIButton){
        convert(type: changeEur, symbol: "€")
        defaults.set(textField.text, forKey: "lastTextField")
    }
    
    @IBAction func changeToDollar(_ sender: UIButton){
        convert(type: changeDollar, symbol: "$")
        defaults.set(textField.text, forKey: "lastTextField")
    }
    
    //MARK: - Convert money function
    /***************************************************************/
    
    func convert(type : Double, symbol : String){
        
            let currencyFormatter = NumberFormatter()
            currencyFormatter.usesGroupingSeparator = true
            currencyFormatter.numberStyle = .currency
            
            if symbol == "€" {
                currencyFormatter.locale = Locale(identifier: "es_ES")
            }else if symbol == "$" {
                currencyFormatter.locale = NSLocale.current
            }
            
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
                
                let lastValue : Double = defaults.double(forKey: "lastValue")
  
                self.updateValues(moneyValue: lastValue)
                
                print("Error: \(String(describing: response.result.error))")
                
                self.updateLabel.text = "Last update:  Later today"
            }
        }
    }

    //MARK: - JSON Parsing //At the beggining if you have internet
    /***************************************************************/

    func updateMoneyData(json : JSON) {
        
        if json["success"] == true{
            
            defaults.set((json["rates"]["CAD"].doubleValue), forKey: "lastValue")
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
        
//        let lastDate : String = defaults.object(forKey: "lastDate") as! String
//        updateLabel.text = "Last update:  \(lastDate)"

    }
    
}

