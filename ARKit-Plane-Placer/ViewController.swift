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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setConfiguration(withPlanesHidden: false)
    }
    
    func setConfiguration(withPlanesHidden: Bool) {
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        if withPlanesHidden {
            configuration.planeDetection = []
        } else {
            configuration.planeDetection = .horizontal
        }
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @IBAction func togglePlaneDetection(_ sender: UISwitch) {
        if sender.isOn {
            // detect planes
            setConfiguration(withPlanesHidden: false)
        } else {
            // stop plane detection
            setConfiguration(withPlanesHidden: true)
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
