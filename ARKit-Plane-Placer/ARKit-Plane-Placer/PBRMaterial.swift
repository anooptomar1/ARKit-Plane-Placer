//
//  PBRMaterial.swift
//  ARKit-Plane-Placer
//
//  Created by Taylor Guidon on 7/23/17.
//

import Foundation
import SceneKit

class PBRMaterial {
    
    var materials: [String: SCNMaterial] = [:]
    
    func materialNamed(_ name: String) -> SCNMaterial {
        if let mat = materials[name] {
            return mat
        }
        
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
//        mat.diffuse.contents = UIImage(named: "Planes/\(name)-diffuse.png")
        mat.diffuse.contents = UIImage(named: "\(name)-diffuse.png")
        mat.roughness.contents = UIImage(named: "\(name)-roughness.png")
        mat.metalness.contents = UIImage(named: "\(name)-metal.png")
        mat.normal.contents = UIImage(named: "\(name)-normal.png")
        mat.diffuse.wrapS = .repeat
        mat.diffuse.wrapT = .repeat
        mat.roughness.wrapS = .repeat
        mat.roughness.wrapT = .repeat
        mat.metalness.wrapS = .repeat
        mat.metalness.wrapT = .repeat
        mat.normal.wrapS = .repeat
        mat.normal.wrapT = .repeat
        
        materials[name] = mat
        return mat
    }
    
}
