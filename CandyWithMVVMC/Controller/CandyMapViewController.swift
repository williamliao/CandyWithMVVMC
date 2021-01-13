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
    }
    
    func render() {
        
        mapViewModel = CandyMapViewModel()
        
        viewModel.candyLocations.bind { [weak self]  (locations) in
            guard let self = self else { return }
            self.mapViewModel.configMapView(mapView: self.mapView)
            let work = self.mapViewModel.showMapAnnotation(locations: locations)
            self.mapView.addAnnotations(work)
        }
        
        viewModel.error.bind { (error) in
            guard let error = error else {
                return
            }
            
            print("error = \(error.localizedDescription)")
            
            //show Error View
        }
        
        self.viewModel.fetchCandyLocation()
        
    }
    
    deinit {
        print("CandyMapViewController deinit")
    }
}
