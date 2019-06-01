import Foundation
import MapKit

class TDMapTools {
    static func addressStringToLocation(addressString: String, completion: ((CLLocation?, Error?) -> Void)?) {
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(addressString) { (placemarks, error) in
            completion?(placemarks?.first?.location, error)
        }
    }
}
