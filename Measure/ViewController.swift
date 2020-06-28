//
//  ViewController.swift
//  Measure
//
//  Created by Gnanapriya C on 28/06/20.
//  Copyright © 2020 Gnanapriya C. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var dotArray = [SCNNode]()
    let textNode = SCNNode()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        sceneView.autoenablesDefaultLighting = true
        // Run the view's session
        sceneView.session.run(configuration)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotArray.count >= 2 {
            for dot in dotArray {
                dot.removeFromParentNode()
            }
            dotArray = [SCNNode]()
            textNode.removeFromParentNode()
        }
        if let location = touches.first?.location(in: sceneView){
            if let hitTestResult = sceneView.hitTest(location, types: .featurePoint).first {
                addDot(at: hitTestResult)
            }
        }
    }
    
    func addDot(at hitTestResult: ARHitTestResult) {
        let worldTransform = hitTestResult.worldTransform
        let dotObj = SCNSphere(radius: 0.005)
        let dotNode = SCNNode()
        dotNode.position = SCNVector3(x: worldTransform.columns.3.x, y: worldTransform.columns.3.y, z: worldTransform.columns.3.z)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.yellow
        dotObj.materials = [material]
        dotNode.geometry = dotObj
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotArray.append(dotNode)
        if dotArray.count >= 2 {
            calculateDistance()
        }
    }
    
    func calculateDistance() {
        let startDot = dotArray [0]
        let endDot = dotArray [1]

        let distance = sqrtf(powf(endDot.position.x - startDot.position.x, 2) + powf(endDot.position.y - startDot.position.y, 2) + powf(endDot.position.z - startDot.position.z, 2))
        print(distance)
        displayMeasurement(distance: String(distance * 100), position: endDot.position)
    }
    
    func displayMeasurement(distance: String, position: SCNVector3) {
        let text = SCNText(string: distance, extrusionDepth: 1.0)
        textNode.geometry = text
        text.firstMaterial?.diffuse.contents = UIColor.red
        textNode.position = SCNVector3(position.x, position.y + 0.01 , position.z)
        textNode.scale = SCNVector3(0.01, 0.01 , 0.01)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}
