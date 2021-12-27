//
//  ViewController.swift
//  plus15playground2
//
//  Created by Nicholas Lee on 2021-12-21.
//

import UIKit
import MapKit

class ViewController: UIViewController{

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        mapView.delegate = self
        
        parseGeoJSON()
        
        //parseGeoJSONWithFile()
        
        mapView.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.045000, longitude: -114.069000), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
        
        super.viewDidLoad()
    }
    
    func parseGeoJSON(){
        let url = "https://data.calgary.ca/resource/3u3x-hrc7.json"
        
        var polygons: [MKOverlay] = []
        
        let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { jsonData, response, error in
            guard let jsonData = jsonData, error == nil else {
                print("using json file")
                self.parseGeoJSONWithFile()
                return
            }
            
            var json: [Section]?
            do {
                json = try JSONDecoder().decode([Section].self, from: jsonData)
                print(json![2])
            } catch {
                print("failed to convert data from api")
                self.parseGeoJSONWithFile()
                return
            }
            
            guard let result = json else {
                print ("lol idk")
                self.parseGeoJSONWithFile()
                return
            }
            
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
                polygon.title = section.access_hours == nil ? "access hours not available" : section.access_hours
                
                polygons.append(polygon)
            }
            
            self.updateMapViewOverlays(polygons: polygons)
            print("used api data")
        })
        
        task.resume()
    }
    
    func parseGeoJSONWithFile() {
        print("used file data")
        guard let path = Bundle.main.path(forResource: "Plus15", ofType: "json") else {
            fatalError("Unable to get geojson")
        }
        
        let url = URL(fileURLWithPath: path)
        var result: [Section]
        
        do {
            let jsonData = try Data(contentsOf: url)
            result = try! JSONDecoder().decode([Section].self, from: jsonData)
            
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
                polygon.title = section.access_hours == nil ? "access hours not available" : section.access_hours
                polygons.append(polygon)
            }
            
            //return polygons
            updateMapViewOverlays(polygons: polygons)
            
        } catch {
            print("data is messed")
        }
    }
    
    func updateMapViewOverlays(polygons: [MKOverlay]) {
        DispatchQueue.main.async {
            self.mapView.addOverlays(polygons)
        }
    }
}

extension ViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if overlay is MKPolygon {
                let polygonRenderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
                if overlay.title == "access hours not available" {
                    polygonRenderer.lineWidth = 1.0
                    polygonRenderer.strokeColor = UIColor.purple
                    polygonRenderer.fillColor = UIColor.red
                    polygonRenderer.alpha = 0.4
                } else {
                    polygonRenderer.lineWidth = 1.0
                    polygonRenderer.strokeColor = UIColor.purple
                    polygonRenderer.fillColor = UIColor.gray
                    polygonRenderer.alpha = 0.4
                }
                
                return polygonRenderer
            }
            
            return MKOverlayRenderer()
    }
}

struct Section: Codable {
    let structure_type: String!
    let type: String!
    let the_geom: Geom
    let revis_date: String!
    let access_hours: String!
    let modified_dt: String!
}

struct Geom: Codable {
    let type: String
    let coordinates: [[[[Double]]]]
}

