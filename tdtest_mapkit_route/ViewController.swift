import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var sourceTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var mainTextView: UITextView!
    
    @IBAction func goBtnDidPressed(_ sender: UIButton) {
        // Address String
        guard let sourceText = sourceTextField.text, let destinationText = destinationTextField.text, !sourceText.isEmpty, !destinationText.isEmpty else {
            alertError(errorMessage: "Address missing")
            return
        }
        
        // From location
        TDMapTools.addressStringToLocation(addressString: sourceText) { (location, error) in
            guard let sourceCoordinate = location?.coordinate else {
                self.alertError(errorMessage: "Source address invalid")
                return
            }
            self.appendStringToMainTextView(info: "From location: \(String(describing: location))")
            
            
            // To location
            TDMapTools.addressStringToLocation(addressString: destinationText) { (location, error) in
                guard let destinationCoordinate = location?.coordinate else {
                    self.alertError(errorMessage: "Destination address invalid")
                    return
                }
                self.appendStringToMainTextView(info: "To location: \(String(describing: location))")
                
                
                // Place mark
                let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate, addressDictionary: nil)
                let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
                
                // Map item
                let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
                let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
                
                // Annotation
                let sourceAnnotation = MKPointAnnotation()
                if let location = sourcePlacemark.location {
                    sourceAnnotation.coordinate = location.coordinate
                } else {
                    self.alertError(errorMessage: "Source place mark invalid")
                    return
                }
                
                let destinationAnnotation = MKPointAnnotation()
                if let location = destinationPlacemark.location {
                    destinationAnnotation.coordinate = location.coordinate
                } else {
                    self.alertError(errorMessage: "Destination place mark invalid")
                    return
                }
                
                self.mainMapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
                
                // Destination request
                let directionRequest = MKDirections.Request()
                directionRequest.source = sourceMapItem
                directionRequest.destination = destinationMapItem
                directionRequest.transportType = .automobile
                
                // Calculate the direction
                let directions = MKDirections(request: directionRequest)
                directions.calculate { (response, error) -> Void in
                    guard let response = response else {
                        self.alertError(errorMessage: "Route not found")
                        return
                    }
                    
                    // Draw
                    let route = response.routes.first!
                    self.mainMapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
                    
                    // Map region
                    let rect = route.polyline.boundingMapRect
                    self.mainMapView.setRegion(MKCoordinateRegion(rect), animated: true)
                    
                    // Route info
                    self.appendStringToMainTextView(info: "advisoryNotices \(response.routes.first!.advisoryNotices)")
                    self.appendStringToMainTextView(info: "distance \(response.routes.first!.distance)")
                    self.appendStringToMainTextView(info: "expectedTravelTime \(response.routes.first!.expectedTravelTime)")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        setupDelegate()
    }
    
    private func initUI() {
        sourceTextField.text = ""
        destinationTextField.text = ""
        mainTextView.text = ""
        
        // Tap to dismiss
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.mainMapView.addGestureRecognizer(tap)
    }
    
    
    
    private func setupDelegate() {
        mainMapView.delegate = self
    }
    
    private func appendStringToMainTextView(info: String) {
        mainTextView.text += "\(info)\n\n";
    }
    
    private func alertError(errorMessage message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        // Render route
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        renderer.lineWidth = 5.0
        
        return renderer
    }
}
