//
//  ActionTableViewController.swift
//  LazyMode
//
//  Created by Work on 4/6/16.
//  Copyright © 2016 whileAliveWork. All rights reserved.
//
// reference from
// https://www.youtube.com/watch?v=VWgr_wNtGPM

import UIKit
import CoreData

class ActionTableViewController: UITableViewController{

    // This are all actions in the list
    var actions :[Action] = [Action]()
    var habits :[Habit] = [Habit]()
    var dataManager = DataManager()
    
    // This function is called after the view did load
    override func viewDidLoad() {
        super.viewDidLoad()
//        loadData()
//        self.tableView.reloadData()
    }

    // This function is called before the view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        self.tableView.reloadData()
    }
    
    // This funciton loads all actions from the Core Data database
    func loadData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Action")
        do {
            let result = try managedContext.fetch(fetchRequest)
            actions = result as! [Action]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        habits = dataManager.loadData("Habit") as! [Habit]
        print(actions.count)
        print(habits.count)
    }
    

    // MARK: - Table view data source

    // This function specify the number of sections in the table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // This function specify the number of cells in each sections in the table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return actions.count
        } else {
            return habits.count
        }
    }


    fileprivate struct Storyboad {
        static let ActionReuseIdentifier = "actionCell"
        static let HabitReuseIdentifier = "habitCell"
    }
    
    // This function specifies the how each cell should be displayed in the tableViewCell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboad.ActionReuseIdentifier, for: indexPath) as! ActionListViewCell
            print(indexPath.row)
            let action = actions[indexPath.row]
            
            cell.action = action
            return cell
        } else {
            // indexPath == 1
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboad.HabitReuseIdentifier, for: indexPath)
            print(indexPath.row)
            let habit = habits[indexPath.row]
            cell.textLabel!.text = habit.name
            cell.detailTextLabel!.text = "\(Int(habit.duration) / (60 * 60)) Hrs \(Int(habit.duration) / 60 % 60) Mins per Day" // !optional unwrap
            return cell
        }
        

        // Configure the cell...
        
    }

    // This enable the deletion function
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let section = indexPath.section
        
        if editingStyle == .delete {
            // Delete the row from the data source
            if section == 0 {
                deleteCoreData(actions[indexPath.row])
                actions.remove(at: indexPath.row)
            } else if section == 1{
                deleteCoreData(habits[indexPath.row])
                habits.remove(at: indexPath.row)
            }
 
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // Helper function to delete date from Core Data
    func deleteCoreData(_ deleteData : NSManagedObject){
        deleteData.managedObjectContext?.delete(deleteData)
        dataManager.saveContext()
    }

    // MARK: - Navigation

    // Prepare for segue
    // In this case to the ActionViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case "actionCell":
                let cell = sender as! UITableViewCell
                if let indexPath = tableView.indexPath(for: cell){
                    let cellData = actions[indexPath.row]
                    let destinationController = segue.destination as! ActionViewController
                    destinationController.cellData = cellData
                }
            case "habitCell":
                let cell = sender as! UITableViewCell
                if let indexPath = tableView.indexPath(for: cell){
                    let habit = habits[indexPath.row]
                    let destinationController = segue.destination as! HabitViewController
                    destinationController.habit = habit
                }
            default:
                break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 && actions.count > 0 {
            return "Actions"
        } else if section == 1 && habits.count > 0 {
            return "Habits"
        } else {
            return nil
        }
    }
    

}
