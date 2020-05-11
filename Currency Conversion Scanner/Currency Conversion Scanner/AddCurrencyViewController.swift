//
//  AddCurrencyViewController.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 11/5/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//

import Foundation
import UIKit

class AddCurrencyViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
        
    @IBOutlet weak var pickerView: UIPickerView!
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        buttonTapped()
    }
    
    weak var addCurrencyDelegate: AddCurrencyDelegate?
    var selectedItem = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numberOfComponents(in: pickerView)
    }
    
    func buttonTapped(){
        navigationController?.popViewController(animated: true)
        //addCurrencyDelegate?.addCurrency(country: <#T##String#>, currencyAbbreviation: <#T##String#>)
    }
}
