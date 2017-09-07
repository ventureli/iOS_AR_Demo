//
//  MyEarchScene.m
//  myFirstVR
//
//  Created by wenqiang li on 2017/9/1.
//  Copyright © 2017年 wenqiang li. All rights reserved.
//

float durationMAX = 10;
float durationMIN = 2;

#import "MyEarchSceneView.h"

@interface MyNode:NSObject
{
    
}

@property(nonatomic , strong)SCNNode *contentNode;
@property(nonatomic , strong)SCNNode *sphereeNode;
@property(nonatomic , assign)CGFloat radius;
@property(nonatomic , assign)CGFloat distance;
@property(nonatomic , assign)CGFloat circleDuration;
@property(nonatomic , strong)SCNAction *action;
@property(nonatomic , strong)SCNNode *circleNode;
@property(nonatomic , strong)UIColor *color;

- (void)pause;
@end
@implementation MyNode

- (void)pause
{
    [self.contentNode removeAllActions];
}

- (void)move
{
    if(_action)
    {
        [_contentNode runAction:_action];
    }
}

- (SCNNode *)circleNode
{
    if(_circleNode)
    {
        return _circleNode;
    }else
    {
        
        float bigRadius = self.distance ;
        CGPathRef path = CGPathCreateWithEllipseInRect( CGRectMake(-10, -10, 20, 20), &CGAffineTransformIdentity);
        CGPathAddEllipseInRect(path, &CGAffineTransformIdentity, CGRectMake(-9.98, -9.98, 19.96, 19.96));
        //    CGPathAddEllipseInRect(path, ,);
        UIBezierPath *bpath =  [UIBezierPath bezierPathWithCGPath:path];
        bpath.usesEvenOddFillRule = YES;
        bpath.flatness = 0.01;
        SCNShape *shape = [SCNShape shapeWithPath:bpath extrusionDepth:0.5];
        shape.firstMaterial.diffuse.contents = [[self color] colorWithAlphaComponent:0.5];
        shape.firstMaterial.transparent.contents =[[self color] colorWithAlphaComponent:1.0];
        SCNNode *circleNode = [SCNNode nodeWithGeometry:shape];
        
        circleNode.scale = SCNVector3Make(bigRadius/10, bigRadius/10, 0.001/1.0);
        
        circleNode.rotation = SCNVector4Make(1, 0, 0, M_PI_2);
        circleNode.position = SCNVector3Make(0, 0, 0);
        
        _circleNode = circleNode;
    }
    
    return _circleNode;
    
    
}
- (void)hideCircle
{
    
    [_circleNode removeFromParentNode];
}

- (void)showCircle
{
 
    [self.contentNode addChildNode:[self circleNode]];
}
@end

@interface MyEarchSceneView()<ARSCNViewDelegate,SCNPhysicsContactDelegate>
{
    SCNNode *_earthNode;
    SCNNode *_niuzongContent;
    SCNNode *_niuzong;
    CGFloat _duration ;
    BOOL _isPause ;
    BOOL _isShowCircle;
    NSMutableArray *_theNodes;
}

@end
@implementation MyEarchSceneView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        _duration = 5;
        _isShowCircle = YES;
        self.autoenablesDefaultLighting = YES;
        self.delegate = self;
        NSLog(@"self:%@",self);
        NSLog(@"self.scene.phpy:%@",self.scene.physicsWorld);
        self.scene.physicsWorld.contactDelegate = self;
        _theNodes = [NSMutableArray new];
        
        [self initTheNOde];
        
    }
    return self;
}


- (void)changeDebug
{
    static int i = 0;
    i = i %4;
    if(i == 0)
    {
        self.debugOptions = SCNDebugOptionShowBoundingBoxes;
    }
    if(i ==1)
    {
        
        self.debugOptions = SCNDebugOptionShowBoundingBoxes | SCNDebugOptionShowPhysicsShapes;
    }if(i ==2)
    {
        
        self.debugOptions = SCNDebugOptionShowBoundingBoxes | SCNDebugOptionShowPhysicsShapes |
        SCNDebugOptionShowPhysicsFields;
    }
    if(i ==3)
    {
        
        self.debugOptions = 0;
    }
    
    i +=1;
        
}

- (void)initTheNOde
{
    [self initNode];
}

- (void)onTapShowCircle:(UIButton *)btn
{
    if(!_isShowCircle)
    {
        for(int i = 0 ;i < [_theNodes count];i ++)
        {
            MyNode *node = _theNodes[i];
            [node showCircle];
        }
    }else
    {
        
        for(int i = 0 ;i < [_theNodes count];i ++)
        {
            MyNode *node = _theNodes[i];
            [node hideCircle];
        }
    }
    
    _isShowCircle = !_isShowCircle;
    
}

- (void)onTap:(UIButton *)btn
{
    if(_isPause)
    {
        _isPause = NO;
        [btn setTitle:@"暂停" forState:UIControlStateNormal];
        NSLog(@"duration is:%@",@(_duration));
        [_niuzongContent removeAllActions];
        SCNAction *action = [SCNAction rotateByAngle:M_PI*2 aroundAxis:SCNVector3Make(0, 1, 0) duration:3];
        [_niuzongContent runAction:[SCNAction repeatActionForever:action]];
        for(int i = 0 ;i < [_theNodes count];i ++)
        {
            MyNode *node = _theNodes[i];
            [node move];
        }
        
    }else{
        _isPause = YES;
        
        [btn setTitle:@"继续" forState:UIControlStateNormal];
        [_niuzongContent removeAllActions];
        for(int i = 0 ;i < [_theNodes count];i ++)
        {
            MyNode *node = _theNodes[i];
            [node pause];
        }
    }
        
}
- (void)initNode
{
    
    [self addEarthNode];
    [self addAnotherNode];
    
    [self addTopHint];
    [self addhintText];
    
    SCNAction *action = [SCNAction rotateByAngle:M_PI*2 aroundAxis:SCNVector3Make(0, 1, 0) duration:3];
    [_niuzongContent runAction:[SCNAction repeatActionForever:action]];
    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.scene.physicsWorld.contactDelegate = self;
     
    });
    
}

- (void)addTopHint
{
    SCNText *text = [[SCNText alloc] init];
    
    text.string = @"宇宙速度";
    text.font = [UIFont fontWithName:@"Courier-Bold" size:12];
    text.firstMaterial.diffuse.contents = [UIColor redColor];
    text.extrusionDepth = 1;
    SCNNode *textNodeB = [SCNNode nodeWithGeometry:text];
    textNodeB.scale = SCNVector3Make(0.05/12, 0.05/12, 0.03/12);
    textNodeB.position = SCNVector3Make(-0.1, 0.25 , -0.1);
    text.firstMaterial.diffuse.contents = [UIColor orangeColor];
    text.firstMaterial.specular.contents = [UIColor orangeColor];
    text.firstMaterial.emission.contents = [UIColor orangeColor];
    [_earthNode addChildNode:textNodeB];
    
}

- (void)addhintText
{
    SCNText *textB = [[SCNText alloc] init];
    textB.string = @"第一宇宙速度:\n物体所受重力=万有引力= 航天器沿地球表面作圆周运动时向心力\n计算公式:V1=√gR(m/s)，其中g=9.8(m/s^2)，R=6.37×10^6（m)。\n----fatobyli制作---";
    textB.font = [UIFont fontWithName:@"Courier-Bold" size:12];
    textB.firstMaterial.diffuse.contents = [UIColor redColor];
    textB.extrusionDepth = 1;
    SCNNode *textNodeC = [SCNNode nodeWithGeometry:textB];
    textNodeC.scale = SCNVector3Make(0.01/12, 0.01/12, 0.01/12);
    textNodeC.position = SCNVector3Make(-0.1, 0.2 , -0.1);
    textB.firstMaterial.diffuse.contents = [UIColor orangeColor];
    textB.firstMaterial.specular.contents = [UIColor orangeColor];
    textB.firstMaterial.emission.contents = [UIColor orangeColor];
    
    [_earthNode addChildNode:textNodeC];
    
    
}

- (void)addAnotherNode
{

    float radius = 0.015;
    SCNSphere *newSphere = [SCNSphere sphereWithRadius:radius];
    SCNMaterial *newNodeMaterial = [SCNMaterial material];
    newNodeMaterial.diffuse.contents = [UIColor redColor];
    newSphere.firstMaterial = newNodeMaterial;
    SCNNode *newNode = [SCNNode nodeWithGeometry:newSphere];
    
    SCNPhysicsShape *shpe;
    
    shpe = [SCNPhysicsShape shapeWithGeometry:newSphere options:nil];
    newNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic shape:shpe];
    newNode.physicsBody.affectedByGravity = NO;
    newNode.physicsBody.categoryBitMask = 1;
    newNode.physicsBody.contactTestBitMask = 3;
    newNode.physicsBody.collisionBitMask = 3;
    
    SCNNode *contentNode = [SCNNode node];
    [contentNode addChildNode:newNode];
    newNode.position = SCNVector3Make(0.16, 0, 0);
    SCNNode *baseNode = [SCNNode node];
    [baseNode addChildNode:contentNode];
    [_earthNode addChildNode:baseNode];
    
    SCNText *text = [[SCNText alloc] init];
    text.string = @"牛总";
    text.font = [UIFont fontWithName:@"Courier-Bold" size:12];
    text.firstMaterial.diffuse.contents = [UIColor redColor];
    text.firstMaterial.emission.contents = [UIColor redColor];
    
    text.extrusionDepth = 1;
    SCNNode *textNode = [SCNNode nodeWithGeometry:text];
    
    textNode.position = SCNVector3Make(-0.01, (0.013) + (radius - 0.015) , 0);
    textNode.scale = SCNVector3Make(0.01/12, 0.01/12, 0);
    
    [newNode addChildNode:textNode];
    
    float bigRadius = 0.16 + radius/2.0;
    CGPathRef path = CGPathCreateWithEllipseInRect( CGRectMake(-10, -10, 20, 20), &CGAffineTransformIdentity);
    CGPathAddEllipseInRect(path, &CGAffineTransformIdentity, CGRectMake(-9.95, -9.95, 19.9, 19.9));
    //    CGPathAddEllipseInRect(path, ,);
    UIBezierPath *bpath =  [UIBezierPath bezierPathWithCGPath:path];
    bpath.usesEvenOddFillRule = YES;
    bpath.flatness = 0.01;
    SCNShape *shape = [SCNShape shapeWithPath:bpath extrusionDepth:0.5];
    shape.firstMaterial.diffuse.contents = [UIColor orangeColor];
    shape.firstMaterial.transparent.contents = [[UIColor orangeColor] colorWithAlphaComponent:0.5];
    SCNNode *circleNode = [SCNNode nodeWithGeometry:shape];

    circleNode.scale = SCNVector3Make(bigRadius/10, bigRadius/10, 0.001/0.5);
    
    circleNode.rotation = SCNVector4Make(1, 0, 0, M_PI_2);
    circleNode.position = SCNVector3Make(0, 0, 0);
    
    [contentNode addChildNode:circleNode];
    
    
    
    _niuzongContent = contentNode;
    _niuzong = newNode;

    

}

- (void)setAnB
{
    float radius = 0.015;
    SCNSphere *newSphere = [SCNSphere sphereWithRadius:radius];
    SCNMaterial *newNodeMaterial = [SCNMaterial material];
    newNodeMaterial.diffuse.contents = [UIColor purpleColor];
    newSphere.firstMaterial = newNodeMaterial;
    SCNNode *newNode = [SCNNode nodeWithGeometry:newSphere];
   
    SCNPhysicsShape *shpe = [SCNPhysicsShape shapeWithGeometry:newSphere options:nil];
    newNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic shape:shpe];
    newNode.physicsBody.affectedByGravity = NO;
    newNode.physicsBody.categoryBitMask = 1;
    newNode.physicsBody.contactTestBitMask = 3;
    newNode.physicsBody.collisionBitMask = 3;
    
   
    SCNNode *contentNode = [SCNNode node];
    [contentNode addChildNode:newNode];
    newNode.position = SCNVector3Make(-0.16, 0, 0);
    SCNNode *baseNode = [SCNNode node];
    [baseNode addChildNode:contentNode];
    [_earthNode addChildNode:baseNode];
    
    SCNText *text = [[SCNText alloc] init];
    text.string = @"";
    text.font = [UIFont fontWithName:@"Courier-Bold" size:12];
    text.firstMaterial.diffuse.contents = [UIColor redColor];
    text.extrusionDepth = 1;
    SCNNode *textNode = [SCNNode nodeWithGeometry:text];
    textNode.scale = SCNVector3Make(0.05/12, 0.05/12, 0);
    textNode.position = SCNVector3Make(-0.01, - (0.18) + (radius - 0.015) , 0);
    textNode.scale = SCNVector3Make(0.2,0.2 ,1);
    [newNode addChildNode:textNode];

    
}

 

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint eventLocation = [[touches anyObject] locationInView:self];
    CGPoint point = [self convertPoint:eventLocation fromView:nil];
    
    // Get the hit on the earth
    NSArray *hits = [self hitTest:point options:@{SCNHitTestRootNodeKey: _earthNode,
                                                  SCNHitTestIgnoreChildNodesKey: @YES}];
    
    SCNHitTestResult *hit = [hits firstObject];
    if (!hit) return;
    
    
    SCNVector3 position = hit.localCoordinates;
    GLKVector3 pinDirection = GLKVector3Make(1.0, 0, 0.0);
    GLKVector3 normal       = SCNVector3ToGLKVector3(hit.localNormal);
    
    GLKVector3 rotationAxis = GLKVector3CrossProduct(pinDirection, normal);
    CGFloat    cosAngle     = GLKVector3DotProduct(pinDirection, normal);
    GLKVector4 rotation = GLKVector4MakeWithVector3(rotationAxis, acos(cosAngle));
    
    //addnode
    
    float radius =[self randomRadius];
    UIColor *color = [self randomColor];
    SCNSphere *newSphere = [SCNSphere sphereWithRadius:radius];
    SCNMaterial *newNodeMaterial = [SCNMaterial material];
    newNodeMaterial.diffuse.contents = color;
    newSphere.firstMaterial = newNodeMaterial;
    SCNNode *newNode = [SCNNode nodeWithGeometry:newSphere];
    SCNNode *contentNode = [SCNNode node];
    [contentNode addChildNode:newNode];
    float distance =[self randomDistance];
    newNode.position = SCNVector3Make(distance, 0, 0);
    CGFloat randTime =[self randomTime:distance];
    CGFloat clock = [self randClockWise]?1:-1;
    SCNAction *actionone = [SCNAction rotateByAngle:M_PI*2  *clock aroundAxis:SCNVector3Make(0, 1, 0) duration:randTime];
    SCNAction *action = [SCNAction repeatActionForever:actionone];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [contentNode runAction:action];
    });
    SCNNode *baseNode = [SCNNode node];
    [baseNode addChildNode:contentNode];
    baseNode.rotation =SCNVector4FromGLKVector4(rotation);
    [_earthNode addChildNode:baseNode];
    
    SCNText *text = [[SCNText alloc] init];
    
    text.string = [self randomText];
    text.font = [UIFont fontWithName:@"Courier-Bold" size:12];
    text.firstMaterial.diffuse.contents = [UIColor redColor];
    text.firstMaterial.emission.contents = [UIColor redColor];
    text.extrusionDepth = 1;
    
    NSLog(@"radius is:%@",@(radius));
    
    
    SCNNode *textNode = [SCNNode nodeWithGeometry:text];
    
    textNode.position = SCNVector3Make(-0.01, (0.013) + (radius - 0.015) , 0);
    textNode.scale = SCNVector3Make(0.01/12, 0.01/12, 0);
    
    [newNode addChildNode:textNode];
    
    
    SCNPhysicsShape *shape = [SCNPhysicsShape shapeWithGeometry:[SCNSphere sphereWithRadius:radius] options:nil];

    newNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic shape:shape];
    //    _niuzong.physicsBody.mass = 2.0;
    newNode.physicsBody.categoryBitMask = 2;
    newNode.physicsBody.collisionBitMask = 1;
    newNode.physicsBody.contactTestBitMask =1;
    self.scene.physicsWorld.contactDelegate = self;
    
    MyNode *myNode = [MyNode new];
    myNode.contentNode = contentNode;
    myNode.sphereeNode = newNode;
    myNode.radius = radius;
    myNode.distance = distance;
    myNode.circleDuration = randTime;
    myNode.action =action;
    myNode.color =color;
    [_theNodes addObject:myNode];
    if(_isShowCircle)
    {
        [myNode showCircle];
    }
        
    
    
}

- (void)physicsWorld:(SCNPhysicsWorld *)world didBeginContact:(SCNPhysicsContact *)contact
{
    NSLog(@"heree");
}
- (void)physicsWorld:(SCNPhysicsWorld *)world didUpdateContact:(SCNPhysicsContact *)contact
{
    NSLog(@"update");
}
- (void)physicsWorld:(SCNPhysicsWorld *)world didEndContact:(SCNPhysicsContact *)contact
{
    
    NSLog(@"heree");
}

- (BOOL)randClockWise
{
    return arc4random()%2 == 1;
}
- (CGFloat)randomRadius
{
    return [self randomFloatWithMin:0.002 max:0.01];
}

- (CGFloat)randomDistance
{
    return [self randomFloatWithMin:0.16 max:0.30];
}

- (CGFloat)randomTime:(CGFloat)distance
{
    float rate = (distance - 0.16)/0.16;
    return rate *(10 - 4) +4;
    return [self randomFloatWithMin:4.0 max:10.0];
}

- (UIColor *)randomColor
{
    return [UIColor colorWithRed:[self randomFloatWithMin:0.0 max:1.0] green:[self randomFloatWithMin:0.0 max:1.0] blue:[self randomFloatWithMin:0.0 max:1.0] alpha:1.0];
}
- (NSString *)randomText
{
    NSArray *array  = @[@"涛哥",@"小胖",@"雪娇",@"慧姐",@"老何",@"丹丹"];
    int index =  arc4random()%[array count];
    return array[index];
}

-(float) randomFloatWithMin:(float)min max:(float)max
{
    return ((arc4random() %10) / 10.0) * (max - min) + min;
}

- (SCNNode *)NewContentNode:(CGFloat)radius contents:(id)content
{
    SCNSphere *newSphere = [SCNSphere sphereWithRadius:0.015];
    SCNMaterial *newNodeMaterial = [SCNMaterial material];
    newNodeMaterial.diffuse.contents = content;
    newSphere.firstMaterial = newNodeMaterial;
    SCNNode *newNode = [SCNNode nodeWithGeometry:newSphere];
    SCNNode *contentNode = [SCNNode node];
    [contentNode addChildNode:newNode];
    newNode.position = SCNVector3Make(radius, 0, 0);

    return contentNode;
    
}

- (void)addEarthNode
{
    SCNSphere *earch = [SCNSphere sphereWithRadius:0.10];
    earch.segmentCount = 55;
    SCNMaterial *earchMateiral = [SCNMaterial material];
    earchMateiral.diffuse.contents = [UIImage imageNamed:@"earth_diffuse_4k.jpg"];
    earchMateiral.specular.contents = [UIImage imageNamed:@"earth_specular_1k.jpg"];
    earchMateiral.emission.contents = [UIImage imageNamed:@"earth_lights_4k.jpg"];
    earchMateiral.normal.contents = [UIImage imageNamed:@"earth_normal_4k.jpg"];
    earchMateiral.multiply.contents =[UIColor colorWithWhite:0.9 alpha:1.0];
    earchMateiral.shininess = 0.5;
    
    earch.firstMaterial = earchMateiral;
    
    SCNNode *earthNode = [SCNNode nodeWithGeometry:earch];
    SCNNode *axisNode = [SCNNode node];
    [axisNode addChildNode:earthNode];
    _earthNode = earthNode;
    // axisNode.rotation = SCNVector4Make(1, 0, 0, M_PI/6);
    
    SCNSphere *clounds = [SCNSphere sphereWithRadius:0.1075];
    clounds.segmentCount = 144;
    SCNMaterial *cloundsMatrials = [SCNMaterial material];
    cloundsMatrials.diffuse.contents = [UIColor whiteColor];
    cloundsMatrials.locksAmbientWithDiffuse = YES;
    cloundsMatrials.transparent.contents = [UIImage imageNamed:@"clouds_transparent_2K.jpg"];
    cloundsMatrials.transparencyMode = SCNTransparencyModeRGBZero;
    cloundsMatrials.writesToDepthBuffer = NO;
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"AtmosphereHalo" withExtension:@"glsl"];
    NSError *error;
    NSString *shaderSource = [[NSString alloc] initWithContentsOfURL:url
                                                            encoding:NSUTF8StringEncoding
                                                               error:&error];
    if (!shaderSource) {
        NSLog(@"Failed to load shader source code, with error: %@", [error localizedDescription]);
    } else {
        cloundsMatrials.shaderModifiers = @{ SCNShaderModifierEntryPointFragment : shaderSource };
    }
    
    
    clounds.firstMaterial = cloundsMatrials;
    SCNNode *cloudNode = [SCNNode nodeWithGeometry:clounds];
    [earthNode addChildNode:cloudNode];
    earthNode.rotation = SCNVector4Make(0, 1, 0, 0);
    cloudNode.rotation = SCNVector4Make(0, 1, 0, 0);
    
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"rotation.w"];
    rotate.byValue = @(M_PI *2.0);
    rotate.duration = 20.0;
    rotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotate.repeatCount = INFINITY;
    
//    [earthNode addAnimation:rotate forKey:@"rotate the earth"];
    
    CABasicAnimation *rotateClouds = [CABasicAnimation animationWithKeyPath:@"rotation.w"]; // animate the angle
    rotateClouds.byValue   = @(-M_PI*2.0);
    rotateClouds.duration  = 50;
    rotateClouds.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotateClouds.repeatCount = INFINITY;
    [cloudNode addAnimation:rotateClouds forKey:@"slowly move the clouds"];
    
    axisNode.position = SCNVector3Make(0, -0.2, -.8);
    [self.scene.rootNode addChildNode:axisNode];
}

- (void)addBoxNode
{
    CGFloat boxSize = .05;
    SCNBox *box = [SCNBox boxWithWidth:boxSize height:boxSize length:boxSize chamferRadius:0];
    SCNNode *boxNode = [SCNNode nodeWithGeometry:box];
    boxNode.position  = SCNVector3Make(0, 0, - 0.15);
    UIColor *lightBlueColor = [UIColor colorWithRed:4.0/255.0 green:120.0/255.0 blue:255.0/255.0 alpha:1.0];
    box.firstMaterial.diffuse.contents = lightBlueColor;
    box.firstMaterial.locksAmbientWithDiffuse = YES;
    [self.scene.rootNode addChildNode:boxNode];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}
- (void)renderer:(id <SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time
{
//    NSLog(@"heree");
}
@end
