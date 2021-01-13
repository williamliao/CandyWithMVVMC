//
//  CandyMapViewModelType.swift
//  CandyWithMVVMC
//
//  Created by William on 2021/1/13.
//  Copyright © 2021 William. All rights reserved.
//

import Foundation
import MapKit

protocol CandyMapViewModelType {
    func configMapView(mapView: MKMapView)
    func showMapAnnotation(locations: [CandyLocation]) -> [MKAnnotation]
}
