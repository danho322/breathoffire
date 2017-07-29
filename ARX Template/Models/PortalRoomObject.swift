//
//  PortalRoomObject.swift
//  ARX Template
//
//  Created by Daniel Ho on 7/28/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import SceneKit

class PortalRoomObject: SCNNode {
    override init() {
        super.init()
        
        let wallNode = SCNNode()
        wallNode.position = position
        
        let sideLength = Nodes.WALL_LENGTH * 3
        let halfSideLength = sideLength * 0.5
        
        let endWallSegmentNode = Nodes.wallSegmentNode(length: sideLength,
                                                       maskXUpperSide: true)
        endWallSegmentNode.eulerAngles = SCNVector3(0, 90.0.degreesToRadians, 0)
        endWallSegmentNode.position = SCNVector3(0, Float(Nodes.WALL_HEIGHT * 0.5), Float(Nodes.WALL_LENGTH) * -1.5)
        wallNode.addChildNode(endWallSegmentNode)
        
        // mask off the inside
        let endWallMaskNode = Nodes.maskWall(sideLength: sideLength, eulerAngles: endWallSegmentNode.eulerAngles, position: endWallSegmentNode.position + position)
        addChildNode(endWallMaskNode)

        let sideAWallSegmentNode = Nodes.wallSegmentNode(length: sideLength,
                                                         maskXUpperSide: true)
        sideAWallSegmentNode.eulerAngles = SCNVector3(0, 180.0.degreesToRadians, 0)
        sideAWallSegmentNode.position = SCNVector3(Float(Nodes.WALL_LENGTH) * -1.5, Float(Nodes.WALL_HEIGHT * 0.5), 0)
        wallNode.addChildNode(sideAWallSegmentNode)
        
        // mask off the inside
        let sideAWallMaskNode = Nodes.maskWall(sideLength: sideLength, eulerAngles: sideAWallSegmentNode.eulerAngles, position: sideAWallSegmentNode.position + position)
        addChildNode(sideAWallMaskNode)

        let sideBWallSegmentNode = Nodes.wallSegmentNode(length: sideLength,
                                                         maskXUpperSide: true)
        sideBWallSegmentNode.position = SCNVector3(Float(Nodes.WALL_LENGTH) * 1.5, Float(Nodes.WALL_HEIGHT * 0.5), 0)
        wallNode.addChildNode(sideBWallSegmentNode)
        
        // mask off the inside
        let sideBWallMaskNode = Nodes.maskWall(sideLength: sideLength, eulerAngles: sideBWallSegmentNode.eulerAngles, position: sideBWallSegmentNode.position + position)
        addChildNode(sideBWallMaskNode)

        
        let doorSideLength = (sideLength - Nodes.DOOR_WIDTH) * 0.5
        
        let leftDoorSideNode = Nodes.wallSegmentNode(length: doorSideLength,
                                                     maskXUpperSide: true)
        leftDoorSideNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
        leftDoorSideNode.position = SCNVector3(Float(-halfSideLength + 0.5 * doorSideLength),
                                               Float(Nodes.WALL_HEIGHT) * Float(0.5),
                                               Float(Nodes.WALL_LENGTH) * 1.5)
        wallNode.addChildNode(leftDoorSideNode)
        
        // mask off the inside
        let leftDoorSideMaskNode = Nodes.maskWall(sideLength: doorSideLength, eulerAngles: leftDoorSideNode.eulerAngles, position: leftDoorSideNode.position + position)
        addChildNode(leftDoorSideMaskNode)

        
        let rightDoorSideNode = Nodes.wallSegmentNode(length: doorSideLength,
                                                      maskXUpperSide: true)
        rightDoorSideNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
        rightDoorSideNode.position = SCNVector3(Float(halfSideLength - 0.5 * doorSideLength),
                                                Float(Nodes.WALL_HEIGHT) * Float(0.5),
                                                Float(Nodes.WALL_LENGTH) * 1.5)
        wallNode.addChildNode(rightDoorSideNode)
        
        // mask off the inside
        let rightDoorSideMaskNode = Nodes.maskWall(sideLength: doorSideLength, eulerAngles: rightDoorSideNode.eulerAngles, position: rightDoorSideNode.position + position)
        addChildNode(rightDoorSideMaskNode)
        
        let aboveDoorNode = Nodes.wallSegmentNode(length: Nodes.DOOR_WIDTH,
                                                  height: Nodes.WALL_HEIGHT - Nodes.DOOR_HEIGHT)
        aboveDoorNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
        aboveDoorNode.position = SCNVector3(0,
                                            Float(Nodes.WALL_HEIGHT) - Float(Nodes.WALL_HEIGHT - Nodes.DOOR_HEIGHT) * 0.5,
                                            Float(Nodes.WALL_LENGTH) * 1.5)
        wallNode.addChildNode(aboveDoorNode)
       
        // mask off the inside
        let aboveDoorMaskNode = Nodes.maskWall(sideLength: Nodes.DOOR_WIDTH, height: Nodes.WALL_HEIGHT - Nodes.DOOR_HEIGHT, eulerAngles: aboveDoorNode.eulerAngles, position: aboveDoorNode.position + position)
        addChildNode(aboveDoorMaskNode)
        
        let floorNode = Nodes.plane(pieces: 3,
                                    maskYUpperSide: false)
        floorNode.position = SCNVector3(0, 0, 0)
        wallNode.addChildNode(floorNode)
        
        let roofNode = Nodes.plane(pieces: 3,
                                   maskYUpperSide: true)
        roofNode.position = SCNVector3(0, Float(Nodes.WALL_HEIGHT), 0)
        wallNode.addChildNode(roofNode)
        
        addChildNode(wallNode)
        
        
        // we would like shadows from inside the portal room to shine onto the floor of the camera image(!)
        let floor = SCNFloor()
        floor.reflectivity = 0
        floor.firstMaterial?.diffuse.contents = UIColor.white
        floor.firstMaterial?.colorBufferWriteMask = SCNColorMask(rawValue: 0)
        let floorShadowNode = SCNNode(geometry:floor)
        floorShadowNode.position = position
        addChildNode(floorShadowNode)
        
        let roof = SCNBox(width: Nodes.WALL_LENGTH * CGFloat(3),
                          height: Nodes.WALL_WIDTH,
                          length: Nodes.WALL_LENGTH * CGFloat(3),
                          chamferRadius: 0)
        roof.firstMaterial?.diffuse.contents = UIColor.white
        roof.firstMaterial?.colorBufferWriteMask = SCNColorMask(rawValue: 0)
        let roofShadowNode = SCNNode(geometry:floor)
        roofShadowNode.position = SCNVector3(position.x, position.y + Float(Nodes.WALL_HEIGHT), position.z)
        addChildNode(roofShadowNode)
        
        
        let light = SCNLight()
        // [SceneKit] Error: shadows are only supported by spot lights and directional lights
        light.type = .spot
        light.spotInnerAngle = 70
        light.spotOuterAngle = 120
        light.zNear = 0.00001
        light.zFar = 5
        light.castsShadow = true
        light.shadowRadius = 200
        light.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        light.shadowMode = .deferred
        let constraint = SCNLookAtConstraint(target: floorShadowNode)
        constraint.isGimbalLockEnabled = true
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(position.x,
                                        position.y + Float(Nodes.DOOR_HEIGHT),
                                        position.z - Float(Nodes.WALL_LENGTH))
        lightNode.constraints = [constraint]
        addChildNode(lightNode)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
