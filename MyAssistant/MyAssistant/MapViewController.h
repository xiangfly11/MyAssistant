//
//  MapViewController.h
//  MyAssistant
//
//  Created by Jiaxiang Li on 15/8/23.
//  Copyright (c) 2015年 Jiaxiang Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *slideMenuBar;

@property (weak, nonatomic) IBOutlet UITextField *startStreet;


@property (weak, nonatomic) IBOutlet UITextField *startCity;

@property (weak, nonatomic) IBOutlet UITextField *startState;
@property (weak, nonatomic) IBOutlet UITextField *startZip;

@property (weak, nonatomic) IBOutlet UITextField *endStreet;

@property (weak, nonatomic) IBOutlet UITextField *endCity;


@property (weak, nonatomic) IBOutlet UITextField *endState;

@property (weak, nonatomic) IBOutlet UITextField *endZip;

@end
