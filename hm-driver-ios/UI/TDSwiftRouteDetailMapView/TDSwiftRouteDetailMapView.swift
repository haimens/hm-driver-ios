import UIKit
import MapKit

public enum TDSwiftRouteDetailMapViewError: Error {
    case coordinateInvalid
    case routeNotFound
}

public enum TDSwiftRouteDetailMapViewLocationType: String {
    case source
    case destination
}

public class TDSwiftRouteDetailMapView: MKMapView, MKMapViewDelegate {
    // Default appearance config
    public static let defaultConfig = TDSwiftRouteDetailMapViewConfig(sourceTintColor: UIColor(red:0.84, green:0.65, blue:0.28, alpha:1.0),
                                                                      destinationTintColor: UIColor(red:0.06, green:0.03, blue:0.42, alpha:1.0),
                                                                      routeTintColor: UIColor(red:0.06, green:0.03, blue:0.42, alpha:1.0),
                                                                      routeLineWidth: 5.0,
                                                                      routeDashPhase: 2.0,
                                                                      routeDashPattern: [12, 8])
    
    
    // Default map info
    public static let defaultInfo = TDSwiftRouteDetailMapViewInfo(sourceTitle: "Location A",
                                                                  destinationTitle: "Location B",
                                                                  sourceLocation: CLLocation(latitude: 33.942168, longitude: -118.421376),
                                                                  destinationLocation: CLLocation(latitude: 34.0375, longitude: -118.54))
    
    // Map appearance config and info
    private var config: TDSwiftRouteDetailMapViewConfig
    private var info: TDSwiftRouteDetailMapViewInfo
    
    required init?(coder aDecoder: NSCoder) {
        // Assign default values
        self.config = TDSwiftRouteDetailMapView.defaultConfig
        self.info = TDSwiftRouteDetailMapView.defaultInfo
        
        // Super class init
        super.init(coder: aDecoder)
        
        // Mapview delegate
        self.delegate = self
    }
    
    // Config map view appearance and/or info
    public func config(config: TDSwiftRouteDetailMapViewConfig?, info: TDSwiftRouteDetailMapViewInfo?) {
        if let config = config { self.config = config }
        if let info = info { self.info = info }
    }
    
    // Draw route on map view
    public func drawRoute(removeOldRoute: Bool, completion: ((TDSwiftRouteDetailMapViewResult?, TDSwiftRouteDetailMapViewError?) -> Void)?) {
        if removeOldRoute {
            // Remove old annotations
            self.removeAnnotations(self.annotations)
            self.removeOverlays(self.overlays)
        }
        
        // Place mark
        let sourcePlacemark = MKPlacemark(coordinate: info.sourceLocation.coordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: info.destinationLocation.coordinate, addressDictionary: nil)
        
        // Map item
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        // Source annotation
        let sourceAnnotation = TDSwiftRouteDetailMapViewAnnotation()
        if let location = sourcePlacemark.location {
            sourceAnnotation.locationType = .source
            sourceAnnotation.coordinate = location.coordinate
            sourceAnnotation.title = info.sourceTitle
        } else {
            completion?(nil, .coordinateInvalid)
            return
        }
        
        // Destination annotation
        let destinationAnnotation = TDSwiftRouteDetailMapViewAnnotation()
        if let location = destinationPlacemark.location {
            destinationAnnotation.locationType = .destination
            destinationAnnotation.coordinate = location.coordinate
            destinationAnnotation.title = info.destinationTitle
        } else {
            completion?(nil, .coordinateInvalid)
            return
        }
        
        self.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        
        // Destination request
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) -> Void in
            
            guard let response = response, let route = response.routes.first else {
                completion?(nil, .routeNotFound)
                return
            }
            
            // Draw
            self.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            // Map region
            let rect = route.polyline.boundingMapRect
            self.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 80.0, left: 80.0, bottom: 80, right: 80.0), animated: true)
            
            // Route result
            let result = TDSwiftRouteDetailMapViewResult(distance: route.distance, expectedTravelTime: route.expectedTravelTime)
            completion?(result, nil)
            return
        }
    }
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Route appearance
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = config.routeTintColor
        renderer.lineWidth = config.routeLineWidth
        renderer.lineDashPhase = config.routeDashPhase
        renderer.lineDashPattern = config.routeDashPattern
        
        return renderer
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Annotation view reuse id
        let annotationId = "TDSwiftRouteDetailMapViewAnnotationView"
        
        // Convert annotation to custom type
        guard let annotationWithType = annotation as? TDSwiftRouteDetailMapViewAnnotation else { fatalError("INVALID MAP ANNOTATION FOUND") }

        // Reuse or create annotation view
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationId) as? MKMarkerAnnotationView
        if annotationView == nil { annotationView = MKMarkerAnnotationView(annotation: annotationWithType, reuseIdentifier: annotationId) }

        // Custom annotation view
        guard let locationType = annotationWithType.locationType else { fatalError("MAP ANNOTATION TYPE NOT FOUND") }
        switch locationType {
        case .source:
            annotationView?.markerTintColor = config.sourceTintColor
        case .destination:
            annotationView?.markerTintColor = config.destinationTintColor
        }

        return annotationView
    }
}
