//
//  ViewController.swift
//  LazyWalker
//
//  Created by Emmet Susslin on 2/9/17.
//  Copyright © 2017 Emmet Susslin. All rights reserved.
//

// jared API: 372a9f91-e653-4793-a4e8-fb33663697db
//google places API: AIzaSyDMwIMkdZJIpz9Q6qJPI_E6SvAVLen9dEg


import UIKit
import CoreLocation
import CoreData
import Mapbox
import Alamofire
import Charts
import SwiftCharts
import GooglePlaces


class mapVC: UIViewController, MGLMapViewDelegate, UISearchBarDelegate, UITableViewDelegate {
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    
    
    @IBOutlet weak var menuView: UIView!
    
    @IBOutlet weak var darkFillView: UIView!
    
    @IBOutlet weak var toggleMenuButton: UIButton!
    
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    
    @IBOutlet weak var btn5: UIButton!
    
    


    


    @IBOutlet weak var overlay: UIView!
    @IBOutlet weak var logoImageview: UIImageView!
    @IBOutlet weak var mapView: MGLMapView!
    

    @IBOutlet weak var searchBtn: UIButton!

    
    @IBOutlet weak var imageView: UIImageView!

//    var mySearchBar: UISearchBar!
   
    var placesClient: GMSPlacesClient!
    

    var mask: CALayer!
    var animation: CABasicAnimation!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        menuView.center.x = screenSize.width / 2
        
        menuView.center.y = screenSize.height
        
        print(screenSize.width)
        
        darkFillView.layer.cornerRadius = 22.0
        
//        customView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        
        
        
        

        
        btn1.layer.cornerRadius = 22.0
        btn2.layer.cornerRadius = 22.0
        btn3.layer.cornerRadius = 22.0
        btn4.layer.cornerRadius = 22.0
        btn5.layer.cornerRadius = 22.0
                
        btn1.backgroundColor = .green
        btn2.backgroundColor = UIColor(red: 127.0/255.0, green: 255.0/255.0, blue: 0.0/255.0, alpha: 1)
        btn3.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 0.0/255.0, alpha: 1)
        btn4.backgroundColor = UIColor(red: 255.0/255.0, green: 150.0/255.0, blue: 0.0/255.0, alpha: 1)
        btn5.backgroundColor = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1)
                
        btn5.alpha = 0
        btn4.alpha = 0
        btn3.alpha = 0
        btn2.alpha = 0
        btn1.alpha = 0
        menuView.alpha = 0
        
        btn1.translatesAutoresizingMaskIntoConstraints = false
        btn2.translatesAutoresizingMaskIntoConstraints = false
        
        btn3.translatesAutoresizingMaskIntoConstraints = false
        
        btn4.translatesAutoresizingMaskIntoConstraints = false
        
        btn5.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        reset()
        
        setLocation()
        
        searchController = UISearchController(searchResultsController: resultsViewController)

        searchController?.searchResultsUpdater = resultsViewController

        resultsViewController?.tableCellBackgroundColor = .black
        resultsViewController?.primaryTextHighlightColor = .white
        resultsViewController?.primaryTextColor = .gray
        resultsViewController?.secondaryTextColor = .gray
        resultsViewController?.tableCellSeparatorColor = .gray
        
        
        
        imageView.alpha = 0
        imageView.frame = CGRect.init(x: 0, y: 100, width: screenSize.width - 60, height: screenSize.height / 6)
        imageView.center.x = self.view.center.x
        imageView.center.y = self.view.center.y / 2.5
        
        
        
        // Add the search bar to the right of the nav bar,
        // use a popover to display the results.
        // Set an explicit size as we don't want to use the entire nav bar.
        searchController?.searchBar.frame = (CGRect(x: 0, y: 0, width: screenSize.width - 30, height: 44.0))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: (searchController?.searchBar)!)

        definesPresentationContext = true
        
        // Keep the navigation bar visible.
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController?.modalPresentationStyle = .popover

        
        print(latitude)
        print(longitude)
        
        
        // HERE WE GO
        animateLaunch(image: UIImage(named: "people1")!)

        //SEARCHBARVIEW
        


        
        // map stuff
        
        // Set the map view‘s delegate property
        mapView.delegate = self
        
        mapView.frame = view.bounds
       
        mapView.styleURL = URL(string: "mapbox://styles/mapbox/dark-v9")
    
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        mapView.setCenter(CLLocationCoordinate2D(latitude: (latitude), longitude: (longitude)), zoomLevel: 13, animated: false)
        

        origin = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        totalDistanceOverall = self.distance(origin, destination)

    }
    
    
    
    /// TOGGLE MENU
    
  
    
    func reset() {
        
        // FOR ALL ROUTES
        paths.removeAll()
        
        // UNIQUE VALUES OF EACH ROUTE
        
        ascend.removeAll()
        descend.removeAll()
        totalDistance.removeAll()
        
        totalDistanceOverall = 0.0
        
        // ALL COORDINATES
        
        firstCoords.removeAll()
        secondCoords.removeAll()
        thirdCoords.removeAll()
        fourthCoords.removeAll()
        fifthCoords.removeAll()
        
        
        if self.mapView.annotations != nil {
//            print("ANNOTATION COUNT:")
//            print(mapView.annotations?.count)
            self.mapView.removeAnnotations(self.mapView.annotations!)
        }

    }
    
    func setLocation() {
        
        
        
        let currentLocation = locationManager.location
        
        latitude = (currentLocation?.coordinate.latitude)!
        longitude = (currentLocation?.coordinate.longitude)!
        
        let corner1 = CLLocationCoordinate2D(latitude: latitude + 0.1, longitude: longitude + 0.1)
        let corner2 = CLLocationCoordinate2D(latitude: latitude - 0.1, longitude: longitude - 0.1)
        
        let bounds = GMSCoordinateBounds(coordinate: corner1, coordinate: corner2)
        
//        print(bounds)
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        resultsViewController?.autocompleteBounds = bounds
        
//        print(resultsViewController?.autocompleteBounds)

    }
    
    

    
        


    func getGraphopper(destination: CLLocationCoordinate2D) {
        
        let destiny = destination
        
        let destLat = destiny.latitude
        let destLong = destiny.longitude

        let originString = "\(latitude)," + "\(longitude)"
        
        let deString = "\(destLat)," + "\(destLong)"
        
        let pointstring = originString + "&point=" + deString
        
        let theString = "https://graphhopper.com/api/1/route?point=" + pointstring + "&vehicle=foot&locale=en&elevation=true&points_encoded=false&ch.disable=true&heading=1&algorithm=alternative_route&alternative_route.max_paths=20&alternative_route.max_weight_factor=4&alternative_route.max_share_factor=2&key=a67e19cf-291b-492b-b380-68405b49e910"
//        
        print(theString)
        var allPathElevations = [Double]()
        
        Alamofire.request(theString).responseJSON { response in
        
            
            if let JSON = response.result.value as? [String:Any] {
                
             self.adjustCameraForRoutes()
                
//                print(response)
                
                let pathss = JSON["paths"] as! [[String:Any]]

                
                for path in pathss {
                    
                    let points = path["points"] as? [String:Any]
                    let coords = points?["coordinates"] as! NSArray!
                    
//                    allPathElevations.append(coords[2])
                   
                    var elevations = [Double]()
                    
                    ascend.append((path["ascend"] as? Double)!)
                    descend.append((path["descend"] as? Double)!)
                    totalDistance.append((path["distance"] as? Double)!)
                
                
                paths.append(path)
                }
                
                self.flattestRoute()
                self.findRange()
                self.setMenu()
            }
            
            }
        }
    
    func findRange() {
        
        let sortedRange = elevationRange.sorted()
        minElevation = sortedRange[0]
        maxElevation = sortedRange[sortedRange.count - 1]
        
    }

    
    func flattestRoute() {

        let sortedAscend = ascend.sorted()
        
        
        print("PATHS COUNT")
        print(paths.count)
        
        
        
    
        if (paths.count > 4) {
            
            
        let fiveflattest = ascend.index(of: sortedAscend[4])!
            printLine(index: fiveflattest, id: "4")
            }
        
        //FOURTH:
        if (paths.count > 3) {

        let fourflattest = ascend.index(of: sortedAscend[3])!
        printLine(index: fourflattest, id: "3")
        }

        //THIRD:
         if (paths.count > 2) {
        let threeflattest = ascend.index(of: sortedAscend[2])!
        printLine(index: threeflattest, id: "2")
        }
        
        //SECOND:
        if (paths.count > 1) {
        let twoflattest = ascend.index(of: sortedAscend[1])!
        printLine(index: twoflattest, id: "1")
        }
        
        
        // FIRST:
        let flattest = ascend.index(of: sortedAscend[0])!
        printLine(index: flattest, id: "0")
        
        findRange()

    }
    
    
    // PRINT FLATTEST ROUTES!

    
    func printLine(index: Int, id: String) {
        
        let path = paths[index]
        

        let points = path["points"]! as! AnyObject!
        
        
        
                let coords = points?["coordinates"] as! NSArray!
        
                    self.distanceElevation(points: coords!, id: id)

                            var linecoords = [CLLocationCoordinate2D]()
                            for coord in coords! {
        
                                let coordAry = coord as! NSArray
                                
                                let elevation = coordAry[2]
                                
                                elevationRange.append(elevation as! Double)
                                
                                let lat = coordAry[1]
                                let lng = coordAry[0]
                                
                                let ht = coordAry[2]
                                
                                let point = CLLocationCoordinate2D(latitude: lat as! CLLocationDegrees, longitude: lng as! CLLocationDegrees)
                                
                                
                                
                                add(coordinate: point, id: id)
                                
                                let coordpoint = CLLocationCoordinate2DMake(lat as! Double, lng as! Double)
                                
                                linecoords.append(coordpoint)
                                
                            }
        
        
        
                    totalDistanceOverall = self.distance(linecoords.first!, linecoords.last!)
        
        print("TOTAL DISTANCE")
        print(totalDistanceOverall)

        
                    for (index, _) in linecoords.enumerated() {
                            if index == 0 { continue } // skip first
                            self.split(linecoords[index - 1], linecoords[index], id)
                    }

        
        
                    let pointer = UnsafeMutablePointer<CLLocationCoordinate2D>(mutating: linecoords)
                    let shape = MGLPolyline(coordinates: pointer, count: UInt(linecoords.count))
        
                    shape.title = id
        
                   self.mapView.addAnnotation(shape)
                   mapView.selectAnnotation(shape, animated: true)
    }
    
    
    
    
    /// BOLD LINE
    
    func boldline(title: String) {
        
        let num = Int(title)!
        
        let sortedAscend = ascend.sorted()
        
        let index = ascend.index(of: sortedAscend[num])!
        
        let theindex = sortedAscend.index(of: ascend[index])!
        
//        print("INDEX:")
////        print(index)
        
        let path = paths[index]

        let points = path["points"]! as! AnyObject!
        let coords = points?["coordinates"] as! NSArray!
        var linecoords = [CLLocationCoordinate2D]()
        for coord in coords! {
            
            let coordAry = coord as! NSArray
            let lat = coordAry[1]
            let lng = coordAry[0]
            
            let coordpoint = CLLocationCoordinate2DMake(lat as! Double, lng as! Double)
            
            linecoords.append(coordpoint)
            
        }
        let pointer = UnsafeMutablePointer<CLLocationCoordinate2D>(mutating: linecoords)
        let shape = MGLPolyline(coordinates: pointer, count: UInt(linecoords.count))
        
        if (theindex == 0) {
            shape.title = "0BOLD"
        }
        
        if (theindex == 1) {
            shape.title = "1BOLD"
        }
        
        if (theindex == 2) {
            shape.title = "2BOLD"
        }
        
        if (theindex == 3) {
            shape.title = "3BOLD"
        }
        
        if (theindex == 4) {
            shape.title = "4BOLD"
        }
        
        self.mapView.addAnnotation(shape)
        }
    
    
    
    
    //// MAP STUFF
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        // Try to reuse the existing ‘pisa’ annotation image, if it exists.
        
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "dot")
        
        if annotationImage == nil {
            // Leaning Tower of Pisa by Stefan Spieler from the Noun Project.
            var image = UIImage(named: "dot")!
            
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            
            
            // Initialize the ‘pisa’ annotation image with the UIImage we just loaded.
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "dot")
        }
        
        return annotationImage
    }
    
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    
    func mapView(_ mapView: MGLMapView, calloutViewFor annotation: MGLAnnotation) -> UIView? {
        // Only show callouts for `Hello world!` annotation
        
        self.addAnnotationSubview(index: annotation.title!!)
        self.addGraphicSubview(index: annotation.title!!)
        return CustomCalloutView(representedObject: annotation)
        
    }
    
    
    func mapView(_ mapView: MGLMapView, leftCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        
       
        
        if (annotation.title! != nil) {
            
            let title = annotation.title!
            boldline(title: title!)
            
            let num = Int(title!)!
            
            let sortedAscend = ascend.sorted()
            
            let index = ascend.index(of: sortedAscend[num])!

            
            // Callout height is fixed; width expands to fit its content.
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
            label.textAlignment = .right
            label.textColor = UIColor(red: 0.81, green: 0.71, blue: 0.23, alpha: 1)
            label.text = "\(sortedAscend[num])" + " uphill climb"
            return label
        }
        
        return nil
    }

    
    
    
    ///// ANNOTATION PARTICULARS
    
    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        return UIButton(type: .detailDisclosure)
    }
    
    func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        // Hide the callout view.
        mapView.deselectAnnotation(annotation, animated: false)
        
        UIAlertView(title: annotation.title!!, message: "A lovely (if touristy) place.", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK").show()
    }
    
    
    
    func mapView(_ mapView: MGLMapView, didDeselect annotation: MGLAnnotation) {
        
        let catchtitle = String()
        
    
        removeSubview()
        
        
        let poly = mapView.annotations?.filter { annotation in
            
            return (annotation.title??.localizedCaseInsensitiveContains("BOLD") == true)
            
        }
        
        if (poly!.count > 0) {
        
        let first = poly?.first!
        
        mapView.removeAnnotation(first!)
        
        let name = first!.title!
        
        if (name == "4BOLD") {
            let shape = first as! MGLPolyline
            shape.title = "4"
            
            print(shape.title)
            self.mapView.addAnnotation(shape)
        }
        
        if (name == "3BOLD") {
            let shape = first as! MGLPolyline
            shape.title = "3"
            
            print(shape.title)
            self.mapView.addAnnotation(shape)
        }

        
        if (name == "2BOLD") {
            let shape = first as! MGLPolyline
            shape.title = "2"
            
            print(shape.title)
            self.mapView.addAnnotation(shape)
        }

        
        if (name == "1BOLD") {
            let shape = first as! MGLPolyline
            shape.title = "1"
            
            print(shape.title)
            self.mapView.addAnnotation(shape)
        }

        
        if (name == "0BOLD") {
            let shape = first as! MGLPolyline
            shape.title = "0"
            
            print(shape.title)
            self.mapView.addAnnotation(shape)
        }
        }

    }

    
    
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        // Set the alpha for all shape annotations to 1 (full opacity)
        return 1
    }
    
    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        // Set the line width for polyline annotations
        print("ANNOTATION TITLE:")
        print(annotation.title!)
        
        if ((annotation.title!.localizedCaseInsensitiveContains("BOLD") == true) && annotation is MGLPolyline) {
            
            return 12.0
        }
                else
        {

        return 4.0
        }
    
    }
    
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        // Give our polyline a unique color by checking for its `title` property
        
        
        if ((annotation.title == "0" || annotation.title == "0BOLD") && annotation is MGLPolyline) {

            return .green
        }
        if ((annotation.title == "1" || annotation.title == "1BOLD") && annotation is MGLPolyline) {

            return UIColor(red: 127.0/255.0, green: 255.0/255.0, blue: 0.0/255.0, alpha: 1)
        }
        
        if ((annotation.title == "2" || annotation.title == "2BOLD") && annotation is MGLPolyline) {

             return UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 0.0/255.0, alpha: 1)
        }
        
        if ((annotation.title == "3" || annotation.title == "3BOLD") && annotation is MGLPolyline) {

            return UIColor(red: 255.0/255.0, green: 150.0/255.0, blue: 0.0/255.0, alpha: 1)
        }
        
        if ((annotation.title == "4" || annotation.title == "4BOLD") && annotation is MGLPolyline) {

            return UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1)
        }
        else
        {
            return .brown
        }

    }
    
    
    
    // DIRECTIONAL BEARING:
    
    func DegreesToRadians(degrees: Double ) -> Double {
        return degrees * M_PI / 180
    }
    
    func RadiansToDegrees(radians: Double) -> Double {
        return radians * 180 / M_PI
    }
    
    func bearingToLocationRadian(destinationLocation:CLLocation) -> Double {
        
        let lat1 = DegreesToRadians(degrees: latitude)
        let lon1 = DegreesToRadians(degrees: longitude)
        
        let lat2 = DegreesToRadians(degrees: destinationLocation.coordinate.latitude);
        let lon2 = DegreesToRadians(degrees: destinationLocation.coordinate.longitude);
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x)
        
        return radiansBearing
    }
    
    func bearingToLocationDegrees(destinationLocation:CLLocation) -> Double{
        let heading = RadiansToDegrees(radians: bearingToLocationRadian(destinationLocation: destinationLocation))
        print("HEADING THIS DIRECTION:")
        print(heading)
        
        let degrees = (360.0 + heading) as! Double!
        
        print("DEGREES")
        print(degrees)
        
        destinationDirection = degrees!
        
        return heading
    }
    
    
    
    // MAP CAMERA

//    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
    
    func adjustCameraForRoutes() {
    
        let camera = MGLMapCamera(lookingAtCenter: mapView.centerCoordinate, fromDistance: totalDistanceOverall*1.7, pitch: 60, heading: (destinationDirection))
        
        print("TOTAL DISTANCE")
        print(totalDistanceOverall)
        
        // Animate the camera movement over 5 seconds.
        mapView.setCamera(camera, withDuration: 3, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        
        self.imageShow()
    }
    
    
    
        func imageShow() {
    
            print("imageshow!")
    
            UIView.animate(withDuration: 6, animations: {
               self.imageView.alpha = 0.5
            }) { (true) in
                UIView.animate(withDuration: 6, animations: {
                    self.imageHide()
                }, completion: { (true) in
    
                })
            }
    
        }
    
    func imageHide() {
        
        print("imagehide!")
        
        UIView.animate(withDuration: 6, animations: {
            self.imageView.alpha = 0.0
        }) { (true) in
            UIView.animate(withDuration: 1, animations: {
                //                    self.customView.alpha = 1
            }, completion: { (true) in
                
            })
        }
        
    }
    
    //// TOGGLE MENU
    
    @IBAction func toggleMenu(_ sender: UIButton) {
        
        if darkFillView.transform == CGAffineTransform.identity{
            
            UIView.animate(withDuration: 0.2, animations: {
                self.darkFillView.transform = CGAffineTransform(scaleX: 11, y: 11)
                self.menuView.transform = CGAffineTransform(translationX: 0, y: -60)
            }) { (true) in
                self.toggleMenuButton.transform = CGAffineTransform(rotationAngle: self.radians(degrees: 180.0))
            }
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.darkFillView.transform = .identity
                self.menuView.transform = .identity
                self.toggleMenuButton.transform = .identity
            }) { (true) in
                
            }
        }
    }
    
    @IBAction func btn1_pressed(_ sender: UIButton) {
    }
    
    @IBAction func btn2_pressed(_ sender: UIButton) {
    }

    @IBAction func btn3_pressed(_ sender: UIButton) {
    }


    @IBAction func btn4_pressed(_ sender: UIButton) {
    }
    
    @IBAction func btn5_pressed(_ sender: UIButton) {
    }
    
    func radians(degrees: Double) -> CGFloat {
        return CGFloat(degrees * .pi / degrees)
    }
    

    

    
    func setMenu() {
        
        menuView.alpha = 1
        // Create the views dictionary
        let viewsDictionary = ["btn1":btn1, "btn2":btn2, "btn3":btn3, "btn4":btn4, "btn5":btn5]
        
        
        
        menuView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[btn1(44)]-18-|",
                                                               options: [],
                                                               metrics: nil,
                                                               views: viewsDictionary))
        
        menuView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[btn2(44)]-18-|",
                                                               options: [],
                                                               metrics: nil,
                                                               views: viewsDictionary))
        
        menuView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[btn3(44)]-18-|",
                                                               options: [],
                                                               metrics: nil,
                                                               views: viewsDictionary))
        
        menuView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[btn4(44)]-18-|",
                                                               options: [],
                                                               metrics: nil,
                                                               views: viewsDictionary))
        
        menuView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[btn5(44)]-18-|",
                                                               options: [],
                                                               metrics: nil,
                                                               views: viewsDictionary))
        
        
        if paths.count > 4 {
            
            //buttons visible
            btn5.alpha = 1
            btn4.alpha = 1
            btn3.alpha = 1
            btn2.alpha = 1
            btn1.alpha = 1
            
            //POSITION 5 buttons on Menu
            menuView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[btn1(44)]-20-[btn2(44)]-20-[btn3(44)]-20-[btn4(44)]-20-[btn5(44)]-40-|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: viewsDictionary))
        } else if paths.count > 3 {
            
            btn4.alpha = 1
            btn3.alpha = 1
            btn2.alpha = 1
            btn1.alpha = 1
            //POSITION 4 buttons on Menu
            menuView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-54-[btn1(44)]-30-[btn2(44)]-30-[btn3(44)]-30-[btn4(44)]-54-|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: viewsDictionary))
        } else if paths.count > 2 {
            
            btn3.alpha = 1
            btn2.alpha = 1
            btn1.alpha = 1
            
            //POSITION 3 buttons on Menu
            menuView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-70-[btn1(44)]-51-[btn2(44)]-51-[btn3(44)]-70-|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: viewsDictionary))
        } else {
            btn2.alpha = 1
            btn1.alpha = 1
            //POSITION 2 buttons on Menu
            menuView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-100-[btn1(44)]-80-[btn2(44)]-100-|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: viewsDictionary))
        }
        
        

        
        
        
            }
}






// Handle the user's selection.
extension mapVC: GMSAutocompleteResultsViewControllerDelegate {

    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        
        

        self.reset()
        self.setLocation()
        
        searchController?.isActive = false
        
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        
        print(place.placeID)
        
        self.loadFirstPhotoForPlace(placeID: place.placeID)
        
        let lat = place.coordinate.latitude
        let lon = place.coordinate.longitude
        
        
        destination = CLLocationCoordinate2D(latitude: lat, longitude: lon)
//        self.bearingToLocationDegrees(destinationLocation:destination)
        
        bearingToLocationDegrees(destinationLocation:CLLocation(latitude: lat, longitude: lon))
        
        
        
        totalDistanceOverall = self.distance(origin, destination)
        self.getGraphopper(destination: destination)

    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

}

