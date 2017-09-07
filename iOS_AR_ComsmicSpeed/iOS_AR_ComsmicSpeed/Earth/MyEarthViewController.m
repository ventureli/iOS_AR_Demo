//
//  MyEarthViewController.m
//  myFirstVR
//
//  Created by wenqiang li on 2017/9/1.
//  Copyright © 2017年 wenqiang li. All rights reserved.
//

#import "MyEarthViewController.h"
#import <ARKit/ARKit.h>
#import <SceneKit/SceneKit.h>
#import "MyEarchSceneView.h"
@interface MyEarthViewController ()                 <ARSessionDelegate,ARSCNViewDelegate>
@property(nonatomic ,strong)MyEarchSceneView            *arscnView;
@property(nonatomic ,strong)ARSession                   *arSession;
@property(nonatomic ,strong)ARConfiguration             *arconfiguration;
@property(nonatomic ,strong)UISlider                     *slider;
@property(nonatomic ,strong)UIButton                         *btn;
@property(nonatomic ,strong)UIButton                         *btnB;
@property(nonatomic ,strong)UIButton                         *btnC;



@end

@implementation MyEarthViewController
- (ARSCNView *)arscnView
{
    if (_arscnView != nil) {
        return _arscnView;
    }
    _arscnView = [[MyEarchSceneView alloc] initWithFrame:self.view.bounds];
    _arscnView.session = self.arSession;
    _arscnView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _arscnView.automaticallyUpdatesLighting = YES;

 
    
    return _arscnView;
}

- (ARSession *)arSession
{
    if(_arSession != nil)
    {
        return _arSession;
    }
    _arSession = [[ARSession alloc] init];
    _arSession.delegate = self;
    return _arSession;
}

- (ARConfiguration *)arconfiguration
{
    if(!_arconfiguration)
    {
        ARWorldTrackingConfiguration *configuration = [[ARWorldTrackingConfiguration alloc] init];
        _arconfiguration = configuration;
        configuration.planeDetection = ARPlaneDetectionHorizontal;
        configuration.lightEstimationEnabled = YES;
    }
    return _arconfiguration;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.arscnView];
 
    
    self.btn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height  - 100, 100, 100)];
    [self.btn setBackgroundColor:[UIColor orangeColor]];
    [self.btn setTitle:@"暂停" forState: UIControlStateNormal];
    self.btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin ;
    self.btn.layer.masksToBounds = YES;
    self.btn.layer.cornerRadius = 5;
    
    [self.btn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btn];
    
    self.btnB = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 100, self.view.bounds.size.height  - 100, 100, 100)];
    [self.btnB setBackgroundColor:[UIColor redColor]];
    self.btnB.layer.masksToBounds = YES;
    self.btnB.layer.cornerRadius = 5;
    [self.btnB setTitle:@"轨道" forState: UIControlStateNormal];
    self.btnB.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    self.btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.btnB addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnB];
    
    self.btnC = ({
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 100, self.view.bounds.size.height  - 210, 100, 100)];
        [btn setBackgroundColor:[UIColor redColor]];
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 5;
        [btn setTitle:@"调试" forState: UIControlStateNormal];
        [btn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        
        btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self.view addSubview:btn];
        btn;

    });
}

- (void)onClick:(id)btn
{
    if(btn == self.btn)
    {
        [_arscnView onTap:btn];
    }else if(btn == self.btnB){
        [_arscnView onTapShowCircle:btn];
    }else if(btn == self.btnC){
        [_arscnView changeDebug];
    }
        
}
- (void)valueChange:(id)slider
{
    NSLog(@"self.slider:%@",@(self.slider.value));
  
}

- (void)viewDidAppear:(BOOL)animated
{
 
    
    [self.arSession runWithConfiguration:self.arconfiguration];
}

- (void)viewDidLayoutSubviews
{
   [ self.btn setFrame:CGRectMake(0, self.view.bounds.size.height  - 100, 100, 100)];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
