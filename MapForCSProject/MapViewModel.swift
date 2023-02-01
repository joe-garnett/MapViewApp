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
    static let startingLocation = CLLocationCoordinate2D(latitude: 37.331516, longitude: -121.891054)
    // This describes the default "zoom" in
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
}

final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // This describes the amount of map and where is visible to the user
    @Published var region = MKCoordinateRegion(center: MapDetails.startingLocation, span: MapDetails.defaultSpan)
    
    var locationManager: CLLocationManager?
    var previousLocation: CLLocation?
    @Published var distanceTravelled: Double = 0.0
    
    private var startingLocation: CLLocation? // Add this property to store the starting location
    
    // To get the user location it that their 'location services' are on in the settings
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            // The delegate allows communication between the settings of the user and this app
            locationManager!.delegate = self
            // It is justified to force unwrap the optional here as the function is called directly above it and only once
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
    
    
    
    
    
    //MARK: FIXË
    
    // Add a method to calculate the distance travelled
    func distanceTraveled() -> Double {
        guard let location = locationManager?.location, let startingLocation = startingLocation else {
            return 0
        }
        return location.distance(from: startingLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
                if previousLocation == nil {
                    previousLocation = location
                }
                let distance = location.distance(from: previousLocation!)
                // coverts distance into type CLLocationManager
                var distanceFromStart = distanceTraveled()
                distanceFromStart += distance
        
                previousLocation = location

    }
}
