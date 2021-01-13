//
//  CandyMapViewController.swift
//  CandyWithMVVMC
//
//  Created by William on 2021/1/13.
//  Copyright © 2021 William. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit


class CandyMapViewController: UIViewController, Storyboarded {
    
    var viewModel: CandyViewModelType!
    
    var mapViewModel: CandyMapViewModelType!
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        createMapView()
    }
    
    func render() {
        self.viewModel.fetchCandyLocation()
        mapViewModel = CandyMapViewModel()
        
        viewModel.candyLocations.bind { [weak self]  (locations) in
            let work = self?.mapViewModel.showMapAnnotation(locations: locations)
            self?.mapView.addAnnotations(work ?? [])
        }
        
        viewModel.error.bind { (error) in
            guard let error = error else {
                return
            }
            
            print("error = \(error.localizedDescription)")
            
            //show Error View
        }
    }
    
    func createMapView() {
        
        mapView.delegate = self
         
        // Set initial location in Honolulu
        let initialLocation = CLLocation(latitude: 23.553118, longitude: 121.0211024)
        
        var mapCenter:CLLocationCoordinate2D = CLLocationCoordinate2D()
        mapCenter.latitude = initialLocation.coordinate.latitude;
        mapCenter.longitude = initialLocation.coordinate.longitude;
        
        var mapSpan: MKCoordinateSpan = MKCoordinateSpan()
        mapSpan.latitudeDelta = 0.05;
        mapSpan.longitudeDelta = 0.05;
        
       mapView.centerToLocation(initialLocation)
        
        //let oahuCenter = CLLocation(latitude: 25.105497, longitude: 121.597366)
        let oahuCenter = CLLocation(latitude: 25.033499866, longitude: 121.558997764)
        let region = MKCoordinateRegion(
          center: oahuCenter.coordinate,
          latitudinalMeters: 500,
          longitudinalMeters: 500)

        
        if #available(iOS 13.0, *) {
            mapView.setCameraBoundary(
                MKMapView.CameraBoundary(coordinateRegion: region),
                animated: true)
            let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
            mapView.setCameraZoomRange(zoomRange, animated: true)
        } else {
            // Fallback on earlier versions
        }
        view.addSubview(mapView)
    }
}

extension CandyMapViewController: MKMapViewDelegate {
  // 1
  func mapView(
    _ mapView: MKMapView,
    viewFor annotation: MKAnnotation
  ) -> MKAnnotationView? {
    // 2
    guard let annotation = annotation as? CandyShop else {
      return nil
    }
    // 3
    let identifier = "artwork"
    var view: MKMarkerAnnotationView
    // 4
    if let dequeuedView = mapView.dequeueReusableAnnotationView(
      withIdentifier: identifier) as? MKMarkerAnnotationView {
      dequeuedView.annotation = annotation
      view = dequeuedView
    } else {
      // 5
      view = MKMarkerAnnotationView(
        annotation: annotation,
        reuseIdentifier: identifier)
      view.canShowCallout = true
      view.calloutOffset = CGPoint(x: -5, y: 5)
      view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    }
    return view
  }
    
    func mapView(
      _ mapView: MKMapView,
      annotationView view: MKAnnotationView,
      calloutAccessoryControlTapped control: UIControl
    ) {
      guard let artwork = view.annotation as? CandyShop else {
        return
      }

      let launchOptions = [
        MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
      ]
      artwork.mapItem?.openInMaps(launchOptions: launchOptions)
    }
}

private extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 1000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}
