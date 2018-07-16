//
//  ViewController.swift
//  LazyMode
//
//  Created by Work on 4/5/16.
//  Copyright © 2016 whileAliveWork. All rights reserved.
//

import UIKit
import CoreData

// extension of NSDate
extension Date {
    // This function compute the interval between this NSDate with the given NSDate. 
    // It return a Int representing the interval of the data 
    func minutesFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }
}


// action view controller
class ActionViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    var toBeClose : [Bool] = [false, false, true, false, true, false, true, false, true, true, false, true, false, true, false, true, true, false]
    var originalHeight : [CGFloat] = [44, 44, 44, 44, 44, 44, 44, 44, 44, 230, 44, 44, 44, 230, 44, 44, 216, 44]
    
    var actionName:String? {
        set {
            actionTitle.text = newValue
        }
        get {
            return actionTitle.text
        }
    }
    
    
    // type value
    var typeValue:Int = 0 {
        didSet {
            switch typeValue {
            case 0:
                typeDisplay.text = "Due"
            case 1:
                typeDisplay.text = "Fixed"
            default:
                break
            }
            typePicker.selectedSegmentIndex = typeValue
        }
    }
    
    @IBAction func typePickerChanged(_ sender: UISegmentedControl) {
        typeValue = sender.selectedSegmentIndex
    }
    @IBOutlet weak var typePicker: UISegmentedControl!
    @IBOutlet weak var typeDisplay: UILabel!
    
    // completion value
    var completionValue:Float = 0 {
        didSet {
            if (completionValue == 100){
                completionDisplay.text = "Compeleted"
            } else {
                completionDisplay.text =  String(Int(completionValue)) + " %"
            }
            completionPicker.value = completionValue
        }
    }
    @IBOutlet weak var completionDisplay: UILabel!
    @IBOutlet weak var completionPicker: UISlider!
    @IBAction func completionPcikerChanged(_ sender: UISlider) {
        completionValue = completionPicker.value
    }
    
    //importance value
    var importanceValue:Int = 0 {
        didSet {
            switch importanceValue {
            case 0:
                importanceDisplay.text = "Must"
            case 1:
                importanceDisplay.text = "Important"
            case 2:
                importanceDisplay.text = "Normal"
            default:
                break
            }
            importancePicker.selectedSegmentIndex = importanceValue
        }
    }
    @IBOutlet weak var importancePicker: UISegmentedControl!
    @IBOutlet weak var importanceDisplay: UILabel!
    @IBAction func importancePickerChanged(_ sender: UISegmentedControl) {
        importanceValue = sender.selectedSegmentIndex
    }
    
    //accuracy
    var accuracyValue:Int = 0 {
        didSet {
            switch accuracyValue {
            case 0:
                accuracyDisplay.text = "Accurate"
            case 1:
                accuracyDisplay.text = "Familiar"
            case 2:
                accuracyDisplay.text = "Unknown"
            default:
                break
            }
            accuracyPicker.selectedSegmentIndex = accuracyValue
        }
    }
    @IBAction func accuracyPickerChanged(_ sender: UISegmentedControl) {
        accuracyValue = sender.selectedSegmentIndex
    }
    @IBOutlet weak var accuracyPicker: UISegmentedControl!
    @IBOutlet weak var accuracyDisplay: UILabel!
    
    // duration Value
    var durationMinutes:Int = 0
    {
        didSet {
            updateDurationUI()
        }
    }
    var durationDays:Int = 0 {
        didSet {
            updateDurationUI()
        }
    }
    // This function updates UI for displaying duration values
    func updateDurationUI(){
        durationMinuteDisplay.text = String(durationDays) + " Days"
        durationDisplay.text = "Duration \(durationDays) Days \(durationMinutes / 60) Hours"
        durationDayPicker.value = Double(durationDays)
        durationMinutePicker.countDownDuration = Double(durationMinutes) * 60.0
        durationMinutePicker.reloadInputViews()
    }
    
    @IBOutlet weak var durationDayPicker: UIStepper!
    @IBOutlet weak var durationDisplay: UILabel!
    @IBOutlet weak var durationMinuteDisplay: UILabel!
    
    @IBOutlet weak var durationMinutePicker: UIDatePicker!
    @IBAction func durationMinutePickerChanged(_ sender: UIDatePicker) {
        durationMinutes = Int(sender.countDownDuration) / 60
    }
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        durationDays = Int(sender.value)
    }
    
    // previous path helper
    fileprivate var previousIndexPath: IndexPath?

    
    // dueDate value
    var dueDate: Date = Date(){
        didSet {
            dueDateDisplay.text = "Due in \(dueDays) Days \(dueHours) Hours"
            dueDatePicker.date = dueDate
            dueDatePicker.reloadInputViews()
        }
    }
    var dueDays: Int {
        let minutes = dueDate.minutesFrom(Date())
        return minutes / 60 / 24
    }
    var dueHours: Int {
        let minutes = dueDate.minutesFrom(Date())
        return minutes % (60 * 24) / 60
    }
    @IBAction func dueDatePickerChanged(_ sender: UIDatePicker) {
        dueDate = sender.date
    }
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var dueDateDisplay: UILabel!
    
    // MARK - repetition
    
    // value 0 means no repetition, 1 mean repeat everday, etc.
    var repetitionDays: Int = 0 {
        didSet {
            if (repetitionDays == 0){
                repetitionDisplay.text = "Not Repeat"
            } else if (repetitionDays % 7 == 0){
                repetitionDisplay.text = "Repeat Every \(repetitionDays / 7) Weeks"
                repetitionPicker.selectRow(repetitionDays / 7, inComponent: 0, animated: true)
                repetitionPicker.selectRow(1, inComponent: 1, animated: true)
            } else {
                repetitionDisplay.text = "Repeat Every \(repetitionDays) Days"
                
                repetitionPicker.selectRow(repetitionDays, inComponent: 0, animated: true)
                repetitionPicker.selectRow(0, inComponent: 1, animated: true)
            }
        }
    }
    @IBOutlet weak var repetitionPicker: UIPickerView!
    @IBOutlet weak var repetitionDisplay: UILabel!
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 21
        case 1:
            return 2
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 0){
            return String(row)
        } else {
            if (row == 0){
                return "days"
            } else {
                return "weeks"
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let numbers = repetitionPicker.selectedRow(inComponent: 0)
        let type = repetitionPicker.selectedRow(inComponent: 1)
        print(numbers)
        print(type)
        if (type == 0){
            repetitionDays = numbers
        } else {
            repetitionDays = numbers * 7
        }
    }
    
    // Hide Repeated Action

    @IBOutlet weak var hiddenPicker: UISwitch!
    
    
    
    func updateUI() {
        tableView.reloadData()
    }
    
    //This method will try to correctly expand and hide cells whenever any row in the table view is touched by user
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // close the current expanding cell
        print("didSelectRow is called")
        self.tableView.beginUpdates()
        // Insert or delete rows
        
        if let expandingPath = previousIndexPath {
            let cell = tableView.cellForRow(at: expandingPath) as! ActionTableViewCell
            let currentRow = expandingPath.row
            
            var closed = 0
            while closed < cell.expanableNum {
                let row = currentRow + 1 + closed
                let path = IndexPath(row: row, section: 0)
                let cell = tableView.cellForRow(at: path) as! ActionTableViewCell
                cell.isHidden = true
                toBeClose[row] = true
                closed += 1
            }
            previousIndexPath = nil
            // don't expand if it touch the same cell
            if expandingPath == indexPath {
                //tableView.reloadData()
                self.tableView.endUpdates()
                return
            }
        }
        
        
        
        // expand the cell if it's expanable (expanableNum > 0)
        let cell = tableView.cellForRow(at: indexPath) as! ActionTableViewCell
        let currentRow = indexPath.row
        
        if cell.expanableNum > 0 {
            var closed = 0

            while closed < cell.expanableNum {
                let row = currentRow + 1 + closed
                let path = IndexPath(row: row, section: 0)
                let cell = tableView.cellForRow(at: path) as! ActionTableViewCell
                cell.isHidden = false
                toBeClose[row] = false
                closed += 1
            }
            previousIndexPath = indexPath
        }
        
        self.tableView.endUpdates()
    }
    
    //This method manages the height of each cell which is used to give part of the hide and expand UI
    // namely, any row whose toBeClose value is false, will be hide (height to zero)
    // toBeClose represents which cell should be hide, which cell should be display using an array of boolean values
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        if toBeClose[row] {
            return 0
        } else {
            return originalHeight[row]
        }
    }
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var cellData: Action?
    
    enum ViewType {
        case add
        case modify
    }
    var type:ViewType = .add
    
    @IBOutlet weak var actionTitle: UITextField! { didSet { actionTitle.delegate = self}}
    
    
    @IBAction func Cancel(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //This function is called when the view is loaded
    //More specifitly, we can update the table view to make sure all data is up to date. 
    //It also changes the "Save" button to "Modify" if user is editing the action, instead of 
    //Add new actions.
    override func viewDidLoad() {
        super.viewDidLoad()
        //toBeClose = [false, false, true, false, true, false, true, true, false, true, false, true, false, false]
        loadData()
        if type == .add {
            actionTitle.becomeFirstResponder()
        } else {
                saveButton.title = "Modify"
        }
//        let backgroundImage = UIImage(named: "blue_background")
//        self.view.backgroundColor = UIColor(patternImage: backgroundImage!)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    fileprivate struct DataIdentifier {
        static let Name = "name"
    }
    
    // This function load data from a cellDate representing by Action
    func loadData(){
        if let actionDataObject = cellData {
            type = .modify
            actionName = actionDataObject.value(forKey: "name") as? String
            typeValue = actionDataObject.value(forKey: "type") as! Int
            accuracyValue = actionDataObject.value(forKey: "accuracy") as! Int
            dueDate = actionDataObject.value(forKey: "dueDate") as! Date
            importanceValue = actionDataObject.value(forKey: "importance") as! Int
            durationDays = actionDataObject.value(forKey: "durationDays") as! Int
            durationMinutes = actionDataObject.value(forKey: "durationMinutes") as! Int
            
            completionValue = actionDataObject.value(forKey: "completionRate") as! Float
            repetitionDays = actionDataObject.value(forKey: "repetitionDays") as! Int
            hiddenPicker.isOn = actionDataObject.hidden;
        }
    }

    // This function hides the button whenever user touches "Return" button on the keyboard.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    // called when 'return' key pressed. return false to ignore.
    {
        textField.resignFirstResponder()
        return true
    }
    
    // This function saves all information of the action to Core Data database
    func save(){
        
        //prepare saving
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "Action", in: managedContext)!
        let actionObject = Action(entity: entityDescription, insertInto: managedContext)
        
        write(actionObject)
    
    }
    
    // This function updates information of a give Action , and save it to Core Data database
    func write(_ actionObject: Action){
        actionObject.setValue(actionName, forKey: "name")
        actionObject.setValue(typeValue, forKey: "type")
        actionObject.setValue(accuracyValue, forKey: "accuracy")
        actionObject.setValue(dueDate, forKey: "dueDate")
        actionObject.setValue(importanceValue, forKey: "importance")
        actionObject.setValue(durationDays, forKey: "durationDays")
        actionObject.setValue(durationMinutes, forKey: "durationMinutes")
        
        actionObject.setValue(repetitionDays, forKey: "repetitionDays")
        actionObject.setValue(completionValue, forKey: "completionRate")
        actionObject.hidden = hiddenPicker.isOn;
        
        do {
            try actionObject.managedObjectContext?.save()
        } catch {
            let saveError = error as NSError
            print(saveError)
        }
    }

    //MARK: Navigation

    // This action is invoked when teh Save button is touched
    // It will save the data, and then pop the current view to return
    @IBAction func Save(_ sender: UIBarButtonItem) {
        print("Haha")
        if let data = cellData {
            write(data)
        } else {
            print("save")
            save()
        }
        self.navigationController?.popViewController(animated: true)
    }

}

