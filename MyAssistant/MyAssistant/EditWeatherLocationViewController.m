//
//  EditWeatherLocationViewController.m
//  MyAssistant
//
//  Created by Jiaxiang Li on 10/24/15.
//  Copyright © 2015 Jiaxiang Li. All rights reserved.
//

#import "EditWeatherLocationViewController.h"
#import <CoreData/CoreData.h>
#import "CoreDataStack.h"
#import "LocationEntity.h"

@interface EditWeatherLocationViewController ()
@property (weak, nonatomic) IBOutlet UITextField *cityNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *countryCodeTextField;

@property (strong,nonatomic) LocationEntity *locationEntity;

@end

@implementation EditWeatherLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
- (IBAction)saveWasPressed:(id)sender {
    
    [self insertInputEntity];
    [self dismissPresentingView];
    
    
}
- (IBAction)cancelWasPressed:(id)sender {
    
    [self
     dismissPresentingView];
}


-(void) insertInputEntity {
    CoreDataStack *coreDataStack = [CoreDataStack defaultStack];
    
    LocationEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:@"LocationEntity" inManagedObjectContext:coreDataStack.managedObjectContext];
    
    entity.cityName = self.cityNameTextField.text;
    
    entity.countryCode = self.countryCodeTextField.text;
    
    [coreDataStack saveContext];
}


-(void) dismissPresentingView {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
