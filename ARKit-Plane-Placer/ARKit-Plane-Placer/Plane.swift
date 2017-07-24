//
//  Plane.swift
//  ARKit-Plane-Placer
//
//  Created by Taylor Guidon on 7/21/17.
//

import Foundation
import SceneKit
import ARKit

enum BodyType : Int {
    case box = 1
    case plane = 2
}

class Plane: SCNNode {
    let pbrMaterial = PBRMaterial()
    var anchor: ARPlaneAnchor
    var planeGeometry: SCNPlane!
    
    init(anchor: ARPlaneAnchor) {
        self.anchor = anchor
        super.init()
        
        let width = anchor.extent.x
        let height = anchor.extent.z
        
        planeGeometry = SCNPlane(width: CGFloat(width), height: CGFloat(height))
        
        let material = pbrMaterial.materialNamed("grid")
        planeGeometry.materials = [material]
        planeGeometry.name = "grid"
        
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
        planeNode.physicsBody?.categoryBitMask = BodyType.plane.rawValue
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0)

        setTextureScale()
        
        addChildNode(planeNode)
    }
    
    func hide() {
        let transparentMaterial = SCNMaterial()
        transparentMaterial.diffuse.contents = UIColor.white.withAlphaComponent(0.0)
        planeGeometry.materials = [transparentMaterial]
    }
    
    func update(anchor :ARPlaneAnchor) {
        // As the user moves around the extend and location of the plane
        // may be updated. We need to update our 3D geometry to match the
        // new parameters of the plane.
        planeGeometry.width = CGFloat(anchor.extent.x)
        planeGeometry.height = CGFloat(anchor.extent.z)
        
        // When the plane is first created it's center is 0,0,0 and the nodes
        // transform contains the translation parameters. As the plane is updated
        // the planes translation remains the same but it's center is updated so
        // we need to update the 3D geometry position
        self.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        
        guard let node = childNodes.first else {
            return
        }
        node.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeGeometry, options: nil))
        
        setTextureScale()
    }
        
    func setTextureScale() {
        let width: Float = Float(planeGeometry.width)
        let height: Float = Float(planeGeometry.height)
        
        // As the width/height of the plane updates, we want our tron grid material to
        // cover the entire plane, repeating the texture over and over. Also if the
        // grid is less than 1 unit, we don't want to squash the texture to fit, so
        // scaling updates the texture co-ordinates to crop the texture in that case
        let material = planeGeometry.material(named: "grid")
        let scaleFactor: Float = 1
        let m = SCNMatrix4MakeScale(width * scaleFactor, height * scaleFactor, 1)
//        material?.diffuse.contentsTransform = SCNMatrix4MakeScale(width, height, 1)
//        material?.diffuse.wrapS = SCNWrapMode.repeat
        material?.diffuse.contentsTransform = m
        material?.roughness.contentsTransform = m
        material?.metalness.contentsTransform = m
        material?.normal.contentsTransform = m
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

