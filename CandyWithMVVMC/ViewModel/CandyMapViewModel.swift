//
//  CandyMapViewModel.swift
//  CandyWithMVVMC
//
//  Created by William on 2021/1/13.
//  Copyright © 2021 William. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class CandyMapViewModel: NSObject {
    
    func showMapAnnotation(locations: [CandyLocation]) -> [MKAnnotation] {
        
        var annotations = [MKAnnotation]()
        
        for location in locations {
            
            // Show artwork on map
            let work = CandyShop(
                title: location.title,
                locationName: location.locationName,
                coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
            
            annotations.append(work)
            
        }
        
        return annotations
    }
    
}

extension CandyMapViewModel: CandyMapViewModelType {
   

}
