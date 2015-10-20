//
//  ForcastViewController.m
//  MyAssistant
//
//  Created by Jiaxiang Li on 15/8/23.
//  Copyright (c) 2015年 Jiaxiang Li. All rights reserved.
//

#import "ForcastViewController.h"

#import "SWRevealViewController.h"

@interface ForcastViewController ()
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *CountryTextField;
@property (weak, nonatomic) IBOutlet UIButton *getWeathrBtn;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@end

@implementation ForcastViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if (revealViewController) {
        [self.slideMenuButton setTarget:self.revealViewController];
        
        [self.slideMenuButton setAction:@selector(revealToggle:)];
        
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
//    self.getWeathrBtn.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor greenColor]);
//    

    self.getWeathrBtn.layer.borderWidth = 2.0f;
    
    
    self.getWeathrBtn.layer.cornerRadius = 5.0f;
    
    
    
    
    self.getWeathrBtn.backgroundColor = [UIColor purpleColor];
//    
//    self.getWeathrBtn.layer.backgroundColor = (__bridge CGColorRef _Nullable)([UIColor grayColor]);
//    
    
    
    
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

- (IBAction)getWeatherAction:(id)sender {
    
    NSString *cityName = self.cityTextField.text;
    
    NSString *countryName = self.CountryTextField.text;
    
    
    if ([cityName isEqualToString:@""]) {
        [self alertNow];
    }
    
    
    NSString *urlStr;
    
    if (![countryName isEqualToString:@""]) {
        urlStr = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?q=%@,%@",cityName,countryName];
    }else {
        urlStr = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?q=%@",cityName];
    }
    
    
    [self getWeatherInfo:urlStr];
    
    
}


-(void) getWeatherInfo:(NSString *) urlStr {
    
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *) response;
            
            if (httpResp.statusCode == 200) {
                NSError *convertError;
                
                NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&convertError];
                
                
                
                if (!convertError) {
                    //NSLog(@"dataDict:%@",dataDict);
                    NSDictionary *mainDict = [dataDict objectForKey:@"main"];
                    
                    NSNumber *temp = [mainDict objectForKey:@"temp"];
                    
                    NSInteger intTemp = [temp integerValue];
                    
                    NSNumber *tempInCelsius = [NSNumber numberWithInteger:intTemp-273.15];
                    
                    NSDictionary *sysDict = [dataDict objectForKey:@"sys"];
                    
                    NSString *countryCode = [sysDict objectForKey:@"country"];
                    
                    NSString *cityName = [dataDict objectForKey:@"name"];
                    
                    
                    //It is necessay to use asynchronous to update the UIView which is related to the main thread, otherwise there is no change for any UIView
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        
                        self.tempLabel.text = [NSString stringWithFormat:@"%@ ℃",[tempInCelsius stringValue]];
                        
                        
                        self.locationLabel.text = [NSString stringWithFormat:@"City:%@    Country Code:%@",cityName,countryCode];
                        
                        
                        NSLog(@"Temp:%@",self.tempLabel.text);
                    });

                }else {
                    NSLog(@"Convert Error:%@",[convertError localizedDescription]);
                }
                
            }
        }else{
            [self alertNow];
        }
    }];
    
    
    [dataTask resume];
    
}


-(void) alertNow {
    
    UIAlertController *alertController = [[UIAlertController alloc] init];
    
    
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"INVALID INPUT" style:UIAlertActionStyleDefault handler:nil];
    
    
    [alertController addAction:alertAction];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    
    
    
}




@end
