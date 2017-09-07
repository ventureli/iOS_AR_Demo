//
//  MyEarchScene.h
//  myFirstVR
//
//  Created by wenqiang li on 2017/9/1.
//  Copyright © 2017年 wenqiang li. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>
@interface MyEarchSceneView : ARSCNView

- (void)onTap:(UIButton *)btn;
- (void)onTapShowCircle:(UIButton *)btn;

- (void)changeDebug;;
@end
