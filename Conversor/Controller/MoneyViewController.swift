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
    var date : String = ""
    var valueCAD : Double = 0
    
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
        
        textField.text = "1"
                
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
    }
    
    @IBAction func changeToDollar(_ sender: UIButton){
        convert(type: changeDollar, symbol: "$")
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
            
        }else {
            SVProgressHUD.showError(withStatus: "Please insert value")
            SVProgressHUD.dismiss(withDelay: 0.7)
        }
    }
    
    //MARK: - Networking, Alamofire
    /***************************************************************/

    func getMoneyData(url: String) {

        Alamofire.request(url, method: .get).responseJSON {
            response in
            if response.result.isSuccess {
                //GOT THE DATA FROM INTERNET
                self.loadingLabel.text = ""
                self.updateMoneyData(json: JSON(response.result.value!))

            } else {
                //NO INTERNET
                self.loadingLabel.text = "Offline mode"
                
                let lastValue2 : Double = defaults.object(forKey: "lastValue") as! Double
  
                self.updateValues(moneyValue: lastValue2)
                
                print("Error: \(String(describing: response.result.error))")
            }
        }
    }

    //MARK: - JSON Parsing
    /***************************************************************/

    func updateMoneyData(json : JSON) {
        
        if json["success"] == true{
            
            valueCAD = json["rates"]["CAD"].doubleValue
            date = json["date"].stringValue
            
            defaults.set(valueCAD, forKey: "lastValue")
            defaults.set(date, forKey: "lastDate")
            
            updateValues(moneyValue: valueCAD)
            
        }else {
            print("Error connection")
        }
    }
    
    //MARK: - Set value function
    /***************************************************************/
    
    func updateValues(moneyValue : Double) {
        changeEur = 1/moneyValue
        changeDollar = moneyValue
        
        let lastDate2 : String = defaults.object(forKey: "lastDate") as! String
        
        rateLabel.text = "Courrent rate:  \(moneyValue)"
        updateLabel.text = "Last update:  \(lastDate2)"

    }
    
}

