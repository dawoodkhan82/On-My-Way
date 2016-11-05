
import Foundation
import UIKit
import CoreLocation

var yelpDestination1 = ""
var yelpDestination2 = ""

class YelpSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var businesses: [Business]!
    
    @IBOutlet var yelpSearchField: UITextField!

    
    var enterPressed = false
    
    
    @IBOutlet var yelpTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        yelpTable.dataSource = self
        yelpTable.delegate = self
        yelpSearchField.delegate = self
        
//        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("dissmissKeyboard")))

        
        

    }
        
        @IBAction func enterSearch(sender: AnyObject) {
            enterPressed = true
            self.yelpTable.reloadData()
            
        }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
        
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode  = NSLineBreakMode.ByWordWrapping
        
        if enterPressed == true {
            
        if yelpSearchField.text != nil {
            
            Business.searchWithTerm(self.yelpSearchField.text!, completion: { (businesses: [Business]!, error: NSError!) -> Void in
                self.businesses = businesses
                
                for business in businesses {
                    
                    cell.textLabel?.text =  "\(businesses[indexPath.row].name!), Address: \(businesses[indexPath.row].address!)"
                    
                }
            })
        }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if yelpDestination1 == "" {
            yelpDestination1 = businesses[indexPath.row].address!
            print(yelpDestination1)
        } else {
            yelpDestination2 = businesses[indexPath.row].address!
            print(yelpDestination2)
        }
        
        
        performSegueWithIdentifier("show_view", sender: self)



    }
    
    
    
    func dissmissKeyboard() {
        yelpSearchField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        yelpSearchField.resignFirstResponder()
        return true
    }

    
    


}
