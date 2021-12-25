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
        var result: [Section]
        
        do {
            let jsonData = try Data(contentsOf: url)
            result = try! JSONDecoder().decode([Section].self, from: jsonData)
            
            print(result.count)
            
            var polygons: [MKPolygon] = []
            
            for section in result {
                var exteriorPolygonPoints: [CLLocationCoordinate2D] = []
                var interiorPolygons: [MKPolygon] = []
                
                //the_geom.coordinates[0][0][0][1]
                //                           ^ coordinate pair
                
                //filling in exteriorPolygonPoints
                for i in 0..<section.the_geom.coordinates[0][0].count {
                    let point = CLLocationCoordinate2D(latitude: section.the_geom.coordinates[0][0][i][1], longitude: section.the_geom.coordinates[0][0][i][0])
                    exteriorPolygonPoints.append(point)
                }
                
                //filling in interiorPolygonPoints
                //creating interiorPolygon
                //adding newly created polygon to interiorPolygons
                for i in 1..<section.the_geom.coordinates[0].count {
                    var interiorPolygonPoints: [CLLocationCoordinate2D] = []
                    for j in 0..<section.the_geom.coordinates[0][i].count {
                        let point = CLLocationCoordinate2D(latitude: section.the_geom.coordinates[0][i][j][1], longitude: section.the_geom.coordinates[0][i][j][0])
                        interiorPolygonPoints.append(point)
                    }
                    interiorPolygons.append(MKPolygon(coordinates: interiorPolygonPoints, count: interiorPolygonPoints.count))
                }
                
                let polygon = MKPolygon(coordinates: exteriorPolygonPoints, count: exteriorPolygonPoints.count, interiorPolygons: interiorPolygons)
                polygons.append(polygon)
            }
            
            return polygons
            
        } catch {
            print("data is fucked")
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

