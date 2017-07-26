//
//  ViewController.swift
//  ARKit-Plane-Placer
//
//  Created by Taylor Guidon on 7/21/17.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var detectSwitch: UISwitch!
    @IBOutlet weak var hideSwitch: UISwitch!
    
    var planes = [Plane]()
    var boxes: [SCNNode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        setupRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setConfiguration(withPlaneDetection: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func setupRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGestureRecognizer.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: - Setup
    
    func setConfiguration(withPlaneDetection: Bool) {
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        if withPlaneDetection {
            configuration.planeDetection = .horizontal
        } else {
            configuration.planeDetection = []
        }
        
        sceneView.session.run(configuration)
    }
    
    // MARK: - Tap
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        let tapPoint = recognizer.location(in: sceneView)
        let result = sceneView.hitTest(tapPoint, types: .existingPlaneUsingExtent)
        guard let hitResult = result.first else {
            print("No hit result")
            return
        }
        
        addObjectToSceneWith(hitResult)
    }
    
    // MARK: - Add objects
    
    func addObjectToSceneWith(_ hitResult: ARHitTestResult) {
        let dimension: CGFloat = 0.1
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        let cube = SCNBox(width: dimension, height: dimension, length: dimension, chamferRadius: 0)
        cube.materials = [material]
        
        let node = SCNNode(geometry: cube)
        node.physicsBody?.mass = 1.0
        node.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.kinematic, shape: nil)
        let yOffset: Float = Float(cube.height)
        node.position = SCNVector3Make(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y.advanced(by: yOffset), hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(node)
        boxes.append(node)
    }
    
    // MARK: - Toggle settings
    
    @IBAction func togglePlaneDetection(_ sender: UISwitch) {
        if sender.isOn {
            // detect planes
            setConfiguration(withPlaneDetection: true)
        } else {
            // stop plane detection
            setConfiguration(withPlaneDetection: false)
        }
    }
    
    @IBAction func togglePlaneHidden(_ sender: UISwitch) {
        if sender.isOn {
            // hide planes
            planes.forEach({ $0.hide() })
        } else {
            // show planes
            planes.forEach({ $0.show() })
        }
    }
    
    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !(anchor is ARPlaneAnchor) {
            return
        }
        
        let plane = Plane(anchor: anchor as! ARPlaneAnchor)
        planes.append(plane)
        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        let plane = planes.filter { plane in
            return plane.anchor.identifier == anchor.identifier
            }.first
        
        if plane == nil {
            return
        }
        
        plane?.update(anchor: anchor as! ARPlaneAnchor)
    }

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
