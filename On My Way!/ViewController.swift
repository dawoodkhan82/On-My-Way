
import UIKit
import CoreLocation
import MapKit

var locManager = CLLocationManager()


class ViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet var startField: UITextField!
    @IBOutlet var destinationField1: UITextField!
    @IBOutlet var destinationField2: UITextField!
    @IBOutlet var finalDestinationField: UITextField!
    @IBOutlet var enterButtonArray: [UIButton]!
    @IBOutlet var addTask: UIButton!
    var addTaskPressed = false

    
    
    @IBAction func addTaskAction(sender: AnyObject) {
        addTaskPressed = true
    }
    
    
    let locationManager = CLLocationManager()
    
    var locationTuples: [(textField: UITextField!, mapItem: MKMapItem?)]!
    
    
    var locationsArray: [(textField: UITextField!, mapItem: MKMapItem?)] {
        var filtered = locationTuples.filter({ $0.mapItem != nil })
        filtered += [filtered.first!]
        return filtered
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestLocation()
        }
        locationTuples = [(startField, nil), (destinationField1, nil), (destinationField2, nil), (finalDestinationField, nil)]
        
        destinationField1.text = yelpDestination1
        
        if yelpDestination2 != "" {
            destinationField2.text = yelpDestination2
        }
        
        if (endDestination.isEmpty) {
            print("No end destination was entered")
        } else {
            finalDestinationField.text = endDestination
        }
    
    }
    
    
    
    @IBAction func getDirections(sender: AnyObject) {
        view.endEditing(true)
        performSegueWithIdentifier("show_directions", sender: self)
    }

    
    
    @IBAction func swapFields(sender: AnyObject) {
        swap(&destinationField1.text, &destinationField2.text)
        swap(&locationTuples[1].mapItem, &locationTuples[2].mapItem)
        swap(&self.enterButtonArray.filter{$0.tag == 2}.first!.selected, &self.enterButtonArray.filter{$0.tag == 3}.first!.selected)
    }
    
    @IBAction func addressEntered(sender: AnyObject){
        view.endEditing(true)
        let currentTextField = locationTuples[sender.tag-1].textField
        CLGeocoder().geocodeAddressString(currentTextField.text!,
            completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                if let placemarks = placemarks {
                    var addresses = [String]()
                    for placemark in placemarks {
                        addresses.append(self.formatAddressFromPlacemark(placemark))
                    }
                    self.showAddressTable(addresses, textField: currentTextField,
                        placemarks: placemarks, sender: sender as! UIButton)
                    //--------------------
                    if (sender.tag == 4) {
                        print(addresses[0])
                        endDestination = String(addresses[0])
                    }
                    
                } else {
                    self.showAlert("Address was not found.")
                    
                }
        })
        
        
    }
    
    func showAddressTable(addresses: [String], textField: UITextField,
        placemarks: [CLPlacemark], sender: UIButton) {
            
            let addressTableView = AddressTableView(frame: UIScreen.mainScreen().bounds, style: UITableViewStyle.Plain)
            addressTableView.addresses = addresses
            addressTableView.currentTextField = textField
            addressTableView.placemarkArray = placemarks
            addressTableView.mainViewController = self
            addressTableView.sender = sender
            addressTableView.delegate = addressTableView
            addressTableView.dataSource = addressTableView
            view.addSubview(addressTableView)
    }
    

    
    func formatAddressFromPlacemark(placemark: CLPlacemark) -> String {
        return (placemark.addressDictionary!["FormattedAddressLines"] as!
            [String]).joinWithSeparator(", ")
    }
    
    
    func showAlert(alertString: String) {
        let alert = UIAlertController(title: nil, message: alertString, preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "OK",
            style: .Cancel) { (alert) -> Void in
        }
        alert.addAction(okButton)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func dissmissKeyboard() {
        finalDestinationField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        finalDestinationField.resignFirstResponder()
        return true
    }

    

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        if (addTaskPressed == true) {
            true
        }else if locationTuples[0].mapItem == nil ||
            (locationTuples[1].mapItem == nil && locationTuples[2].mapItem == nil) {
                showAlert("Please enter a valid starting point and at least one destination.")
                return false
        } else {
            return true
        }
        return true
    }
    
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (addTaskPressed == false) {
            let mapViewController = segue.destinationViewController as! MapView
            mapViewController.locationArray = locationsArray
        }
    }

    
    
}




//extension ViewController: UITextFieldDelegate {
//    
//    func textField(textField: UITextField,shouldChangeCharactersInRange range: NSRange,replacementString string: String) -> Bool {
//            enterButtonArray.filter{$0.tag == textField.tag}.first!.selected = false
//            locationTuples[textField.tag-1].mapItem = nil
//            return true
//    }
//    
//    func textFieldDidBeginEditing(textField: UITextField) {
////        moveViewUp()
//    }
//    
//    func textFieldDidEndEditing(textField: UITextField) {
////        moveViewDown()
//    }
//    
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        view.endEditing(true)
////        moveViewDown()
//        return true
//    }
//}



extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(locations.last!,
            completionHandler: {(placemarks:[CLPlacemark]?, error:NSError?) -> Void in
                if let placemarks = placemarks {
                    let placemark = placemarks[0]
                    self.locationTuples[0].mapItem = MKMapItem(placemark:
                        MKPlacemark(coordinate: placemark.location!.coordinate,addressDictionary: placemark.addressDictionary as! [String:AnyObject]?))
                    self.startField.text = self.formatAddressFromPlacemark(placemark)
                    self.enterButtonArray.filter{$0.tag == 1}.first!.selected = true
                    
                    print(self.formatAddressFromPlacemark(placemark))
                }

        })
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
}
    
    
    
    
    


