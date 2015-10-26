//
//  EditNotesViewController.m
//  MyAssistant
//
//  Created by Jiaxiang Li on 9/7/15.
//  Copyright (c) 2015 Jiaxiang Li. All rights reserved.
//

#import "EditNotesViewController.h"
#import "CoreDataStack.h"
//#import "NotesEntry.h"

@interface EditNotesViewController ()

@end

@implementation EditNotesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.textView.textAlignment = NSTextAlignmentNatural;
    
    self.textView.layer.cornerRadius = 6.0f;
    
    self.textView.layer.borderWidth = 2;
    
    self.textView.layer.borderColor = [[UIColor colorWithRed:89.0/255.0 green:110.0/255.0 blue:100.0/255.0 alpha:1.0] CGColor];
    
    
    if (self.entry) {
        self.textView.text = self.entry.body;
    }
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



#pragma mark - Dismiss Presenting Viewe

-(void) dismissPresentingView {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - Button Action
- (IBAction)cancelWasPressed:(id)sender {
    [self dismissPresentingView];
    
}


- (IBAction)saveWasPressed:(id)sender {
    
    if (self.entry != nil) {
        [self updateInputEntry];
    }else{
        [self insertInputEntry];
    }
    
    
    
    [self dismissPresentingView];
    
    
}



#pragma mark - Manage Input Data

-(void) insertInputEntry {
    
    CoreDataStack *coreDataStack = [CoreDataStack defaultStack];
    
    NewNotesEntity *entry = [NSEntityDescription insertNewObjectForEntityForName:@"NewNotesEntity" inManagedObjectContext:coreDataStack.managedObjectContext];
    
    
    entry.body = self.textView.text;
    
    NSLog(@"%@",entry.body);
    
    
    //entry.date = [[NSDate date] timeIntervalSince1970];
    entry.date = [[NSDate date] timeIntervalSince1970];
    
    //entry.now = [[NSDate date] timeIntervalSince1970];
    NSLog(@"========%f",[[NSDate date] timeIntervalSince1970]);
    
    [coreDataStack saveContext];
}



-(void) updateInputEntry {
    self.entry.body = self.textView.text;
    CoreDataStack *coreDataStack = [CoreDataStack defaultStack];
    
    [coreDataStack saveContext];
    
}


@end
