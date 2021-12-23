//
//  ViewController.swift
//  plus15playground2
//
//  Created by Nicholas Lee on 2021-12-21.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        mapView.delegate = self
        
        mapView.addOverlays(self.parseGeoJSON())
        
        mapView.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.044916, longitude: -114.070336), span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06))
        
        super.viewDidLoad()
    }
    
    func parseGeoJSON() -> [MKOverlay] {
        guard let path = Bundle.main.path(forResource: "Plus15", ofType: "json") else {
            fatalError("Unable to get geojson")
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            let jsonData = try Data(contentsOf: url)
            let result: [Section] = try! JSONDecoder().decode([Section].self, from: jsonData)
        } catch {
            fatalError("unable to decode json")
        }
        
        
        return []
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if overlay is MKPolygon {
                let polygonRenderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
                polygonRenderer.lineWidth = 1.0
                polygonRenderer.strokeColor = UIColor.purple
                polygonRenderer.fillColor = UIColor.red
                return polygonRenderer
            }
            
            return MKOverlayRenderer()
    }


}

struct Section: Decodable {
    let structure_type: String!
    let type: String!
    let the_geom: Geom
}

struct Geom: Decodable {
    let type: String
    let coordinates: [[[[Double]]]]
    let revis_date: String!
    let access_hours: String!
    let modified_dt: String!
}

struct Result: Decodable {
    let data: [ResultItem]
}

struct ResultItem: Decodable {
    let title: String
    let items: [String]
}

