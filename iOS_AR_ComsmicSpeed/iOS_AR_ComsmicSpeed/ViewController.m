//
//  ViewController.m
//  iOS_AR_ComsmicSpeed
//
//  Created by fatboyli on 2017/9/7.
//  Copyright © 2017年 ventureli. All rights reserved.
//

#import "ViewController.h"
#import "MyEarthViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
 
}

- (void)viewDidAppear:(BOOL)animated
{
    MyEarthViewController *controller= [MyEarthViewController new];
    controller.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self presentViewController:controller animated:NO completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
