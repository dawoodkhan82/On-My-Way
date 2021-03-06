

import Foundation
import UIKit
import MapKit
import CoreLocation

class MapView: UIViewController {
    

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var directionsTableView: DirectionsTableView!
    
    var activityIndicator: UIActivityIndicatorView?
    var locationArray: [(textField: UITextField?, mapItem: MKMapItem?)]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addActivityIndicator()
        calculateSegmentDirections(0, time: 0, routes: [])
        
        locationArray.removeLast()
        
        // Drop a pin at each stop
        /*
         for (index, value) in shoppingList.enumerated() {
         print("Item \(index + 1): \(value)")
         }
         */
//        for (var i = 0; i < locationArray.count; i = +1) {
        for (i) in locationArray {
//            print(locationArray[i].textField.text!)
            print(i.textField?.text!)
            
//            let address = locationArray[i].textField.text!
            let address = i.textField?.text!
            let geocoder = CLGeocoder()
            
            geocoder.geocodeAddressString(address!, completionHandler: {(placemarks, error) -> Void in
                if((error) != nil){
                    print("Error", error)
                }
                if let placemark = placemarks?.first {
                    let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                    let dropPin = MKPointAnnotation()
                    dropPin.coordinate = coordinates
                    self.mapView.addAnnotation(dropPin)
                }
            })
            
            
        }
       
    }
    

    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: UIScreen.main.bounds)
        activityIndicator?.activityIndicatorViewStyle = .whiteLarge
        activityIndicator?.backgroundColor = view.backgroundColor
        activityIndicator?.startAnimating()
        view.addSubview(activityIndicator!)
    }
    
    func hideActivityIndicator() {
        if activityIndicator != nil {
            activityIndicator?.removeFromSuperview()
            activityIndicator = nil
        }
    }
    
    
    //Create the segented routes
    func calculateSegmentDirections(_ index: Int,time: TimeInterval, routes: [MKRoute]) {
        let request: MKDirectionsRequest = MKDirectionsRequest()
        request.source = locationArray[index].mapItem
        request.destination = locationArray[index+1].mapItem
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        let directions = MKDirections(request: request)
        directions.calculate (completionHandler: {
            (response: MKDirectionsResponse?, error: Error?) in
            if let routeResponse = response?.routes {
                let quickestRouteForSegment: MKRoute =
                routeResponse.sorted(by: {$0.expectedTravelTime <
                    $1.expectedTravelTime})[0]
                
                var timeVar = time
                var routeVar = routes
                routeVar.append(quickestRouteForSegment)
                timeVar += quickestRouteForSegment.expectedTravelTime
                if index+2 < self.locationArray.count {
                    self.calculateSegmentDirections(index+1, time: timeVar, routes: routeVar)
                } else {
                    self.hideActivityIndicator()
                    self.showRoute(routeVar, time: timeVar)
                }
                
            } else if let _ = error {
                let alert = UIAlertController(title: nil,
                    message: "Directions not available.", preferredStyle: .alert)
                let okButton = UIAlertAction(title: "OK",
                    style: .cancel) { (alert) -> Void in
                        self.navigationController?.popViewController(animated: true)
                }
                alert.addAction(okButton)
                self.present(alert, animated: true,
                    completion: nil)
            }
        })
    }
    
    
    //Display directions table view
    func displayDirections(_ directionsArray: [(startingAddress: String,
        endingAddress: String, route: MKRoute)]) {
            directionsTableView.directionsArray = directionsArray
            directionsTableView.delegate = directionsTableView
            directionsTableView.dataSource = directionsTableView
            directionsTableView.reloadData()
    }
    
    func showRoute(_ routes: [MKRoute], time: TimeInterval) {
        var directionsArray = [(startingAddress: String, endingAddress: String, route: MKRoute)]()
        for i in 0..<routes.count {
            plotPolyline(routes[i])
//            directionsArray += [(locationArray[i].textField?.text!,
//                endAddress: locationArray[i+1].textField?.text!, route: routes[i])]
            
            
            directionsArray = [(startingAddress:(locationArray[i].textField!.text!),
                                endingAddress: (locationArray[i+1].textField!.text!), route: routes[i])]
            
            
//            directionsArray += [(startingAddress: locationArray[index].textField?.text!, endingAddress: locationArray[index+1].textField?.text!, route: routes[index])]
            
        }
        displayDirections(directionsArray)
        printTimeToLabel(time)
    }
    
    func printTimeToLabel(_ time: TimeInterval) {
        var timeString = time.formatted()
//        totalTimeLabel.text = "Total Time: \(timeString)"
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        automaticallyAdjustsScrollViewInsets = false
    }
    
    func plotPolyline(_ route: MKRoute) {
        mapView.add(route.polyline)
        if mapView.overlays.count == 1 {
            mapView.setVisibleMapRect(route.polyline.boundingMapRect,
                edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
                animated: false)
        }
        else {
            let polylineBoundingRect =  MKMapRectUnion(mapView.visibleMapRect,
                route.polyline.boundingMapRect)
            mapView.setVisibleMapRect(polylineBoundingRect,
                edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
                animated: false)
        }
    }
    
}



extension MapView: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView,rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            if (overlay is MKPolyline) {
                if mapView.overlays.count == 1 {
                    polylineRenderer.strokeColor =
                        UIColor.blue.withAlphaComponent(0.75)
                } else if mapView.overlays.count == 2 {
                    polylineRenderer.strokeColor =
                        UIColor.green.withAlphaComponent(0.75)
                } else if mapView.overlays.count == 3 {
                    polylineRenderer.strokeColor =
                        UIColor.red.withAlphaComponent(0.75)
                }
                polylineRenderer.lineWidth = 5
            }
            return polylineRenderer
    }
}
