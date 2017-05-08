
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
        
        @IBAction func enterSearch(_ sender: AnyObject) {
            enterPressed = true
            self.yelpTable.reloadData()
            
        }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
        
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode  = NSLineBreakMode.byWordWrapping
        
        if enterPressed == true {
            
        if yelpSearchField.text != nil {
            
            Business.searchWithTerm(term: self.yelpSearchField.text!, completion: { (businesses: [Business]?, error: Error?) -> Void in
                self.businesses = businesses
                
                for business in businesses! {
                    
                    cell.textLabel?.text =  "\(businesses![indexPath.row].name!), Address: \(businesses![indexPath.row].address!)"
                    
                }
            })
        }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if yelpDestination1 == "" {
            yelpDestination1 = businesses[indexPath.row].address!
            print(yelpDestination1)
        } else {
            yelpDestination2 = businesses[indexPath.row].address!
            print(yelpDestination2)
        }
        
        
        performSegue(withIdentifier: "show_view", sender: self)



    }
    
    
    
    func dissmissKeyboard() {
        yelpSearchField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        yelpSearchField.resignFirstResponder()
        return true
    }

    
    


}
