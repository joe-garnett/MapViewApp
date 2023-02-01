//
//  ContentViewModel.swift
//  MapForCSProject
//
//
//
import MapKit
//
//// Allows more code consiceness
enum MapDetails {
    // Default location (Apple HQ)
    static let startingLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    // This describes the default "zoom" in
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
}

final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // This describes the amount of map and where is visible to the user
    @Published var region = MKCoordinateRegion(center: MapDetails.startingLocation, span: MapDetails.defaultSpan)
    
    var locationManager: CLLocationManager?
    var previousLocation: CLLocation? = nil
    var totalDistance = 0.0
    var count = 1
    //@Published var totalDistance: CLLocation?e
    //MARK: THIS MITE BREAK
    //var previousLocation: CLLocation? //test
    //@Published var distanceTravelled: Double = 0.0
    //var previousLocations: [CLLocation?] = []
    
    private var startingLocation: CLLocation? // Add this property to store the starting location
    
    // To get the user location it that their 'location services' are on in the settings
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            // The delegate allows communication between the settings of the user and this app
            locationManager!.delegate = self
            // It is justified to force unwrap the optional here as the function is called directly above it and only once
            locationManager?.startUpdatingLocation()
        } else {
            print("Location services are disabled.")
        }
    }
    
    private func checkLocationAuthorisation() {
        // Ensures the user has given sufficient permissions to get their location
        guard let locationManager = locationManager else {return}
        // This code safely unwraps the optional
        
        // The switch statement goes through the possiblities of authorisation
        switch locationManager.authorizationStatus {
            case .notDetermined:
                // This displays a pop up where the user can select their authorisation status
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
                // Restricted is due to external conditions e.g. parental controls
                print("Your location resetricted")
            case .denied:
                // Denied is when the user actively agrees to NOT share their location
                print("You have denied app permissions - to fix this go into your app settings")
            
            // This case occurs when the user has selected that they are willing to share their location
            case .authorizedAlways, .authorizedWhenInUse:
                // Subsequently the map displays the icon on the map at the current user's location
                guard let location = locationManager.location else {return}
            // Safely unwraps the optional ^
                if startingLocation == nil {
                    startingLocation = location // Update the starting location
                }
                region = MKCoordinateRegion(center: location.coordinate, span: MapDetails.defaultSpan)
            @unknown default:
            // Fallback for cases that weren’t matched by any previous case statement
                print("Unknown defualt")
                break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorisation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            
            // Caclulates the current coordinates and converts them to type CLLocationCoordinate2D
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            //region = MKCoordinateRegion(center: coordinate, span: MapDetails.defaultSpan) -THIS IS VERY SLOW so won't include.
            
            // Finds current speed of user in m/s
            let speed = location.speed
            // Converts from m/s to km/h
            let speedKPH = speed*3.6
            
            // Optional unwrapping
            if let previousLocation = previousLocation {
                // Finds distance in m between last known location and most recently known location
                let distance = location.distance(from: previousLocation)
                totalDistance += distance
                
                // This is a terrible fix (that works). ONLY xactly the second distance is wildy wrong. So i negated the value.
                if count <= 2 {
                    totalDistance -= distance
                    count += 1
                }
                // For testing purposes
                print(String(distance) + " metres")
                print(String(totalDistance) + " total metres")
            }
            // Set current location to previousLocation
            previousLocation = location
        }
    }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            //handle error
            print("There was an error")
        }
}
