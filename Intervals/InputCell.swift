//
//  InputCell.swift
//  Intervals
//
//  Created by Hunter Whittle on 4/14/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import UIKit

class InputCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    let kMinComponent = 0
    let kSecComponent = 1
    let kInitalSelectionIndex = 6

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    
    var picker = UIPickerView()
    
    var minString = ""
    var secString = ""
    
    var minutes: Int = 0
    var seconds: Int = 0
    var duration: Int = 0
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.nameTextField.returnKeyType = UIReturnKeyType.Done
        self.nameTextField.autocapitalizationType = UITextAutocapitalizationType.Sentences
        self.nameTextField.delegate = self
        self.durationTextField.delegate = self
        
        let inputView: UIView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 260))
        let toolBar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, inputView.frame.size.width, 44))
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: Selector("pickerDoneButtonTapped"))
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        toolBar.items = [space, doneBarButton]
        inputView.addSubview(toolBar)
        
        self.picker = UIPickerView(frame: CGRectMake(0, toolBar.frame.size.height, inputView.frame.size.width, 0))
        self.picker.dataSource = self
        self.picker.delegate = self
        self.picker.selectRow(kInitalSelectionIndex, inComponent: kSecComponent, animated: false)
        
        var minX: CGFloat = 0.0
        var secX: CGFloat = 0.0
        if UIScreen.mainScreen().bounds.size.width < 375.0 {
            //pre iPhone 6
            minX = 90
            secX = 240
        }
        else if UIScreen.mainScreen().bounds.size.width < 414.0 {
            //iPhone 6
            minX = 120
            secX = 270
        }
        else {
            //iPhone 6 Plus
            minX = 140
            secX = 290
        }
        
        let minLabel = UILabel(frame: CGRectMake(minX, 95, 50, 25))
        minLabel.textColor = UIColor.blackColor()
        minLabel.backgroundColor = UIColor.clearColor()
        minLabel.text = "min"
        self.picker.addSubview(minLabel)
        
        let secLabel = UILabel(frame: CGRectMake(secX, 95, 50, 25))
        secLabel.textColor = UIColor.blackColor()
        secLabel.backgroundColor = UIColor.clearColor()
        secLabel.text = "sec"
        self.picker.addSubview(secLabel)
        
        inputView.addSubview(self.picker)
        self.durationTextField.inputView = inputView
    }
    
    //MARK: UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        var result: Int = 1
        
        if component == kMinComponent {
            result = 60
        }
        else if component == kSecComponent {
            result = 12
        }
        
        return result
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        
        var title = ""
        
        if component == kMinComponent {
            title = "\(row)"
        }
        else if component == kSecComponent {
            title = "\(row*5)"
        }
        
        return title;
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        let string = self.pickerView(pickerView, titleForRow: row, forComponent: component)
        if component == kMinComponent {
            self.minutes = string.toInt()!
            if self.minutes != 0 {
                self.minString = "\(string) min"
            }
            else {
                self.minString = ""
                if self.seconds == 0 {
                    self.picker.selectRow(row+1, inComponent: component, animated: true)
                    
                    let newString = self.pickerView(pickerView, titleForRow: row+1, forComponent: component)
                    self.minString = "\(newString) min"
                    self.minutes = newString.toInt()!
                }
            }
        }
        else if component == kSecComponent {
            self.seconds = string.toInt()!
            if self.seconds != 0 {
                self.secString = "\(string) sec"
            }
            else {
                self.secString = ""
                if self.minutes == 0 {
                    self.picker.selectRow(row+1, inComponent: component, animated: true)
                    
                    let newString = self.pickerView(pickerView, titleForRow: row+1, forComponent: component)
                    self.secString = "\(newString) sec"
                    self.seconds = newString.toInt()!
                }
            }
        }
        
        self.duration = Int(self.minutes*60) + self.seconds
        self.durationTextField.text = "\(self.minString) \(self.secString)"
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        
        var result: CGFloat = 1.0
        
        if component == kMinComponent {
            result = 100.0
        }
        else if component == kSecComponent {
            result = 190.0
        }
        
        return result
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if textField == durationTextField {
            if textField.text == "" {
                pickerView(picker, didSelectRow: kInitalSelectionIndex, inComponent: kSecComponent)
            }
            else {
                picker.selectRow(minutes, inComponent: kMinComponent, animated: false)
                pickerView(picker, didSelectRow: minutes, inComponent: kMinComponent)
                picker.selectRow(seconds/5, inComponent: kSecComponent, animated: false)
                pickerView(picker, didSelectRow: seconds/5, inComponent: kSecComponent)
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: Misc methods
    
    func pickerDoneButtonTapped() {
        self.endEditing(true)
    }
}
