//
//  ViewController.swift
//  Measure AR
//
//  Created by Harshit Satyaseel on 06/08/18.
//  Copyright © 2018 Harshit Satyaseel. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    // this array will be used to keep the track of all the dots in the real world.
    var dotNodes = [SCNNode]() // initilized it to an empty array as in beginig there will be no node.
    var textNode = SCNNode() // a node for the text to display
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        // For showing the fetures or ancor points in the real world.
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // for detecting the users touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // this is the logic for calculating the new measurements if we have any previous mesearments by the user.
        if dotNodes.count >= 2{
            for dot in dotNodes{
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
            
        }
       
        // grab the touch point on the 2d screen and convert it into the 3d co-ordinates
        
        if let touchLocation = touches.first?.location(in: sceneView){
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResults = hitTestResults.first {
                addDot(at: hitResults)
                
            }
        }
    }
    // Creating the custom addDot function for adding the dot in the real world position
        func addDot(at hitResult: ARHitTestResult) {
            // create a dot geometry
            let dotGeometry = SCNSphere(radius: 0.005)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.red
            
            dotGeometry.materials = [material]
            // now create a node for the created geomatery
            let dotNode = SCNNode(geometry: dotGeometry)
            
            dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
            
            sceneView.scene.rootNode.addChildNode(dotNode)
            
            dotNodes.append(dotNode)
            
            if dotNodes.count >= 2 {
                calculate()
            }
        }
    
    func calculate(){
        
        let startPosition = dotNodes[0]
        let endPosition = dotNodes[1]
        
        print(startPosition.position)
        print(endPosition.position)
        // calculating the 2 point distance between the 3d space
        let a = endPosition.position.x - startPosition.position.x
        let b = endPosition.position.y - startPosition.position.y
        let c = endPosition.position.z - startPosition.position.y
        
        let  distance = sqrt(pow(a,2) + pow(b,2) + pow(c,2))
        let newDistance = "distance: \(String(format:"%.2f cm", distance * 100.0))" // displaying the length into centremeter.
        updateTest(text: "\(newDistance)" , atPosition: endPosition.position)
        
    }
    
    func updateTest(text: String, atPosition: SCNVector3){
        // if we have any previously calculated then remove those first
        textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: text, extrusionDepth: 0.1)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        // create a node for this material
        
        textNode = SCNNode(geometry: textGeometry)
        
        textNode.position = SCNVector3(atPosition.x, atPosition.y + 0.01, atPosition.z)
        
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
       
    }
}
