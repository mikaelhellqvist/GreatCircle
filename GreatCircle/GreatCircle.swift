import CoreLocation
import Foundation
import UIKit

precedencegroup ExponentiationPrecedence {
    associativity: right
    higherThan: MultiplicationPrecedence
}

infix operator ** : ExponentiationPrecedence

func ** (_ base: Double, _ exp: Double) -> Double {
    return pow(base, exp)
}

func ** (_ base: Float, _ exp: Float) -> Float {
    return pow(base, exp)
}

struct GreatCircle {

    let earthRadius = 6371000.0
    
    func discretizePoints(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, discritizeDistance: Double = 50000) -> [CLLocationCoordinate2D] { //17000

        var fromLat = from.latitude
        var fromLon = from.longitude
        let toLat = to.latitude
        let toLon = to.longitude
        
        var pointsCoordinates = [from]
        var distance = getPointDistance(from: from, to: to)
        if distance > 1500000 { print("Very big distance") }
        
        let coordinates2 = CLLocationCoordinate2DMake(toLat, toLon)
        while distance > discritizeDistance {

            let bearing = getBearingDegree(from: CLLocationCoordinate2DMake(fromLat, fromLon),
                                           to: CLLocationCoordinate2DMake(toLat, toLon))
            
            let destCoord = getDestinationCoordinates(coordinate: CLLocationCoordinate2DMake(fromLat, fromLon),
                                                      dist: discritizeDistance, bearing: bearing)
            
            fromLat = (destCoord.latitude).rounded(toPlaces: 6)
            fromLon = (destCoord.longitude).rounded(toPlaces: 6)
            
            pointsCoordinates.append(CLLocationCoordinate2DMake(fromLat, fromLon))
            
            distance = getPointDistance(from: CLLocationCoordinate2DMake(fromLat, fromLon),
                                        to: coordinates2)
        }
        pointsCoordinates.append(CLLocationCoordinate2DMake(toLat, toLon))
        
        return pointsCoordinates
    }
    
    func getPointDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        
        let fromLat = from.latitude.toRadians()
        let fromLon = from.longitude.toRadians()
        let toLat = to.latitude.toRadians()
        let toLon = to.longitude.toRadians()
        
        let latDiff = (toLat - fromLat)
        let lonDiff = (toLon - fromLon)
        
        let a = (sin(latDiff / 2) ** 2) + cos(fromLat) * cos(toLat) * (sin(lonDiff / 2) ** 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        let dist = c * earthRadius
        
        return dist
    }
    
    func getBearingDegree(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        
        let fromLat = from.latitude.toRadians()
        let fromLon = from.longitude.toRadians()
        let toLat = to.latitude.toRadians()
        let toLon = to.longitude.toRadians()
        
        let lonDiff = (toLon - fromLon)
        let a = sin(lonDiff) * cos(toLat)
        let b = cos(fromLat) * sin(toLat) - sin(fromLat) * cos(toLat) * cos(lonDiff)
        let brng_deg = atan2(a, b)
        
        let cleanAngle = cleanAngleDegree(angle: brng_deg.toDegrees())
        
        return cleanAngle
    }
    
    func cleanAngleDegree(angle: Double) -> Double {
        
        var cleanAngle = angle
        while cleanAngle >= 360 {
            cleanAngle -= 360
        }
        while cleanAngle < 0 {
            cleanAngle += 360
        }
        return cleanAngle
    }
    
    func getDestinationCoordinates(coordinate: CLLocationCoordinate2D, dist: Double, bearing: Double) -> CLLocationCoordinate2D {

        let lat = coordinate.latitude.toRadians()
        let lon = coordinate.longitude.toRadians()
        let inBearing = bearing.toRadians()
        
        var lat2 = asin(sin(lat) * cos(dist / earthRadius) + cos(lat) * sin(dist / earthRadius) * cos(inBearing))
        var lon2 = lon + atan2(sin(inBearing) * sin(dist / earthRadius) * cos(lat),cos(dist / earthRadius) - sin(lat) * sin(lat2))
        
        lat2 = lat2.toDegrees()
        lon2 = lon2.toDegrees()
        
        let coordinate = CLLocationCoordinate2DMake(lat2, lon2)
        return coordinate
    }
}

