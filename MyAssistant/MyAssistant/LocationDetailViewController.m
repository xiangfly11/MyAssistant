//
//  LocationDetailViewController.m
//  MyAssistant
//
//  Created by Jiaxiang Li on 10/28/15.
//  Copyright © 2015 Jiaxiang Li. All rights reserved.
//

#import "LocationDetailViewController.h"
#import "MapViewController.h"

@interface LocationDetailViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *webURLLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressInfoLabel;


@end

@implementation LocationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.mapItem.url) {
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.mapItem.url];
        [self.webView loadRequest:urlRequest];
        self.webURLLabel.text = [NSString stringWithFormat:@"%@",self.mapItem.url];
        self.webURLLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tabGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(urlWasClicked)];
        [self.webURLLabel addGestureRecognizer:tabGesture];
    }else {
        NSURL *url = [NSURL URLWithString:@"https://www.google.com"];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:urlRequest];
        self.webURLLabel.text = @"";
    }
    
    
    if (self.mapItem.phoneNumber) {
        self.phoneNumberLabel.text = self.mapItem.phoneNumber;
        self.phoneNumberLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tabGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(phoneNumberWasClicked)];
        [self.phoneNumberLabel addGestureRecognizer:tabGesture];
        
    }else {
        self.phoneNumberLabel.text = @"";
    }
    
    self.nameLabel.text = self.mapItem.name;
    
    MKPlacemark *placeMark = self.mapItem.placemark;
    
    self.addressInfoLabel.text = [NSString stringWithFormat:@"%@,%@,%@,%@,%@",placeMark.subThoroughfare,placeMark.thoroughfare,placeMark.locality,placeMark.administrativeArea,placeMark.postalCode];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)urlWasClicked {
    if (![[UIApplication sharedApplication] openURL:self.mapItem.url]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Invalid URL" message:@"This URL link is invalid,please click OK to return." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:alert];
        
        [self.presentingViewController presentViewController:alertController animated:YES completion:nil];
    }
}

-(void) phoneNumberWasClicked {
    NSString *phonStr = [self.mapItem.phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableString *phoneNumber = [[NSMutableString alloc] initWithString:phonStr];
    [phoneNumber setString:[phoneNumber stringByReplacingOccurrencesOfString:@"(" withString:@""]];
    [phoneNumber setString:[phoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""]];
    [phoneNumber setString:[phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    
    //[phoneNumber setString:[@"telprompt://" stringByAppendingString:phoneNumber]];
    
    [phoneNumber setString:[phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""]];
    [phoneNumber setString:[phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    
    NSLog(@"%@====",phoneNumber);
    
    //NSMutableString *phoneNumber = [NSMutableString stringWithString:@"+17324694422"];
    [phoneNumber  setString:[@"telprompt://" stringByAppendingString:phoneNumber]];
    [phoneNumber setString:[phoneNumber stringByReplacingOccurrencesOfString:@"\U0000200e" withString:@""]];
    //[phoneNumber setString:[ph]]
    NSLog(@"%@=====??????",phoneNumber);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
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
