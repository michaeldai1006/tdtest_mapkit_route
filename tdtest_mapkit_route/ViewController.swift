import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var sourceTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var mainTextView: UITextView!
    
    @IBAction func goBtnDidPressed(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    private func initUI() {
        sourceTextField.text = ""
        destinationTextField.text = ""
        mainTextView.text = ""
    }
}
