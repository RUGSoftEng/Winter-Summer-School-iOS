//
//  RGSScheduleEventViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 7/17/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit
import MapKit
import Contacts
import CoreLocation

/// Class for representing annotations in an MKMapView.
class Location: NSObject, MKAnnotation {
    
    // MARK: - Variables & Constants
    
    /// The Title, displayed in the annotation View this class is used for.
    let title: String?
    
    /// The Subtitle also displayed in the annotation View.
    var subtitle: String?
    
    /// The coordinate of the location.
    let coordinate: CLLocationCoordinate2D
    
    // MARK: - Class Methods
    
    /// Returns an MKMapItem instance for use in the Maps application.
    func getMapItem() -> MKMapItem {
        let addressDictionary: [String: String] = [String(CNPostalAddressStreetKey): title!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
    
    // MARK: - Initializers
    
    /// Initializer
    init?(title: String, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}

class RGSScheduleEventViewController: RGSBaseViewController, RGSTabViewDelegate, NSLayoutManagerDelegate, MKMapViewDelegate {
    
    // MARK: - Variables & Constants
    
    /// The Event Object to be displayed in the View.
    var event: RGSEventDataModel!
    
    /// The UITextView for the event description.
    var descriptionTextView: UITextView!
    
    /// The MKMapView for the event location.
    var mapView: MKMapView!
    
    /// The identifier for MKAnnotation Views.
    let annotationIdentifier: String = "annotationIdentifier"
    
    // MARK: - Outlets
    
    /// The UILabel for the event title.
    @IBOutlet weak var titleLabel: UILabel!
    
    /// The UIButton for the event times.
    @IBOutlet weak var timesButton: UIButton!
    
    /// The RGSTabView tabs.
    @IBOutlet weak var tabView: RGSTabView!
    
    /// The swappable content view.
    @IBOutlet weak var contentView: UIView!
    
    /// The background UIView for the titleLabel.
    @IBOutlet weak var titleLabelBackgroundView: UIView!
    
    // MARK: - Outlets
    
    /// The height of the titleLabel.
    @IBOutlet weak var titleLabelHeight: NSLayoutConstraint!
    
    // MARK: - Actions
    
    @IBAction func didPressTimesButton(_ sender: UIControl) -> Void {
    }
    
    // MARK: - Superclass Method Overrides
    
    override func shouldShowReturnButton() -> Bool {
        return true
    }
    
    override func shouldShowTitleLabel() -> (Bool, String?) {
        return (false, nil)
    }
    
    // MARK: - Private Class Methods
    
    private func embedViewWithMargins(subView: UIView, to superView: UIView, with constant: CGFloat) {
        let views = ["subView": subView, "superView": superView]
        var constraints: [NSLayoutConstraint] = []
        subView.translatesAutoresizingMaskIntoConstraints = false
        // Create horizontal constraints.
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat:
            "H:|-\(constant)-[subView]-\(constant)-|",
            options: [], metrics: nil, views: views)
        
        // Create vertical constraints.
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat:
            "V:|-\(constant)-[subView]-\(constant)-|",
            options: [],
            metrics: nil, views: views)
        
        // Add to constraints collection.
        constraints += horizontalConstraints
        constraints += verticalConstraints
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func toggleTabbedViews() -> Void {
        mapView.isHidden = !mapView.isHidden
        descriptionTextView.isHidden = !descriptionTextView.isHidden
    }
    
    private func configureViews() -> Void {
        
        // Set fonts.
        titleLabel.font = SpecificationManager.sharedInstance.titleLabelFont
        timesButton.titleLabel?.font = SpecificationManager.sharedInstance.subTitleLabelFont
        descriptionTextView.font = SpecificationManager.sharedInstance.textViewFont
        
        // Set descriptionTextView colors.
        descriptionTextView.backgroundColor = UIColor.white
        
        // Set tabView colors.
        tabView.setColors(AppearanceManager.sharedInstance.lightBackgroundGrey, AppearanceManager.sharedInstance.lightTextGrey, AppearanceManager.sharedInstance.red, AppearanceManager.sharedInstance.lightBackgroundGrey)
        
        // Set tabView titles.
        tabView.setTitles(["Description", "Location"])
        
        // Set titleLabel background color.
        titleLabelBackgroundView.backgroundColor = AppearanceManager.sharedInstance.lightBackgroundGrey
        
        // Configure Contents
        if (event != nil) {
            
            // Set title.
            if let title = event.title {
                titleLabel.text = title
                let heightThatFits: CGFloat = UILabel.heightForString(text: title, with: titleLabel.font, bounded: titleLabel.bounds.height)
                titleLabelHeight.constant = min(SpecificationManager.sharedInstance.titleLabelMaximumHeight, heightThatFits)
            }
            
            // Set times.
            if let startDate = event.startDate, let endDate = event.endDate {
                let startDateString: String = DateManager.sharedInstance.dateToISOString(startDate, format: .scheduleEventDateFormat)!
                var endDateString: String = DateManager.sharedInstance.dateToISOString(endDate, format: .scheduleEventDateFormat)!
                
                // If it's the same day, present a shorter format.
                if (DateManager.sharedInstance.calendar.isDate(startDate, inSameDayAs: endDate)) {
                    endDateString = DateManager.sharedInstance.dateToISOString(endDate, format: .hoursAndMinutesFormat)!
                }

                timesButton.setTitle(startDateString + " - " + endDateString, for: .normal)
            }
            
            // Set description, round textView
            descriptionTextView.layer.cornerRadius = 10.0
            if let description = event.body {
                do {
                    descriptionTextView.attributedText = try NSAttributedString(HTMLString: description, font: descriptionTextView.font)
                } catch {
                    descriptionTextView.text = description
                }
            }
            
            // Set Address
            if let address = event.location {
                
                // Initialize the MapView default region.
                let coordinates = SpecificationManager.sharedInstance.defaultMapCoordinates.coordinate
                let radius = SpecificationManager.sharedInstance.defaultMapRadius
                let region = MKCoordinateRegionMakeWithDistance(coordinates, radius, radius)
                
                // Set the MapView region.
                mapView.setRegion(region, animated: false)
                
                // Attempt to geocode the address.
                let geocorder = CLGeocoder()
                
                geocorder.geocodeAddressString(address, completionHandler: {(placemarks, error) in
                    if (placemarks != nil && (placemarks?.indices.contains(0))!) {
                        let placemark = placemarks?[0]
                        let coordinate = placemark?.location?.coordinate
                        self.mapView.addAnnotation(Location(title: address, subtitle: address, coordinate: coordinate!)!)
                    } else {
                        let alertController = ActionManager.sharedInstance.getActionSheet(title: "Bad Address", message: "Maps failed to locate this address!", dismissMessage: "Okay")
                        self.present(alertController, animated: true, completion: nil)
                    }
                })

            }
        }
    }
    
    // MARK: - NSLayoutManager Delegate Methods
    
    /// Handler for the UITextView line spacing.
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return SpecificationManager.sharedInstance.textViewLineSpacing
    }
    
    // MARK: - MKMapView Delegate Methods
    
    /// Handling for when the user taps on the accessory indicator of a map annotation.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Location
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        location.getMapItem().openInMaps(launchOptions: launchOptions)
    }
    
    /// Returns a View for a map Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Location {
            var annotationView: MKPinAnnotationView
            
            if let v = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView {
                v.annotation = annotation
                annotationView = v
            } else {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
                annotationView.canShowCallout = true
                annotationView.calloutOffset = CGPoint(x: -5, y: 5)
                annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView!
            }
            return annotationView
        }
        return nil
    }
    
    // MARK: - RGSTabView Delegate Methods
    
    func didSelectTab(tab: UIButton, withTag: Int) {
        toggleTabbedViews()
    }
    
    
    // MARK: - Class Method Overrides
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Never display Warning Popup Button.
        self.dismissWarningPopup(animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the Navigation Bar Theme (Mandatory)
        setNavigationBarTheme()
        
        // Initialize TextView, MapView.
        descriptionTextView = UITextView(frame: CGRect(origin: .zero, size: contentView.bounds.size))
        mapView = MKMapView(frame: CGRect(origin: .zero, size: contentView.bounds.size))
        
        // Add TextView, MapView to ContentView.
        contentView.addSubview(mapView)
        contentView.addSubview(descriptionTextView)
        
        // Set constraints.
        embedViewWithMargins(subView: descriptionTextView, to: contentView, with: 8.0)
        embedViewWithMargins(subView: mapView, to: contentView, with: 0.0)
        
        // Set TextView layoutManager delegate.
        descriptionTextView.layoutManager.delegate = self
        
        // Set mapView hidden.
        mapView.isHidden = true
        
        // Set RGSTabView delegate.
        tabView.delegate = self
        
        // Set mapView delegate.
        mapView.delegate = self
        
        // Configure the contents of the views.
        configureViews()
    }

}
