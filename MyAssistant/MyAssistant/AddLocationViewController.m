//
//  AddLocationViewController.m
//  MyAssistant
//
//  Created by Jiaxiang Li on 11/16/15.
//  Copyright © 2015 Jiaxiang Li. All rights reserved.
//

#import "AddLocationViewController.h"
#import "LocationEntity.h"
#import "CoreDataStack.h"

@interface AddLocationViewController ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;
@property (strong,nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong,nonatomic) UITableView *tableView;

@end

@implementation AddLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect viewFrame = self.view.frame;
    float Y_Offset = 530;
    float tableViewHeight = Y_Offset;
    NSLog(@"%f,%f",viewFrame.size.width,viewFrame.size.height);
    CGRect tableViewFrame = CGRectMake(viewFrame.origin.x, viewFrame.size.height - Y_Offset,viewFrame.size.width, tableViewHeight);
    self.tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.7 alpha:0.2];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.blurView addSubview:self.tableView];
    
    [self.fetchedResultsController performFetch:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)textFieldDone:(id)sender {
    
    
}

-(NSFetchedResultsController *)fetchedResultsController {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"LocationEntity"];
    
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"cityName""" ascending:YES]];
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    CoreDataStack *dataStack = [CoreDataStack defaultStack];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:dataStack.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}




- (IBAction)saveWasPressed:(id)sender {
    
    if (self.textField.text.length != 0) {
        CoreDataStack *dataStack = [CoreDataStack defaultStack];
        LocationEntity *location = [NSEntityDescription insertNewObjectForEntityForName:@"LocationEntity" inManagedObjectContext:dataStack.managedObjectContext];
        location.cityName = self.textField.text;
        [dataStack saveContext];
    }else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Input" message:@"Please Enter City Name On Text Field" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [alert addAction: action];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    
}
- (IBAction)cancelWasPressed:(id)sender {
    self.textField.text = @"";
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id<NSFetchedResultsSectionInfo>
    sectionInfo = [self.fetchedResultsController sections] [section];
    
    return [sectionInfo numberOfObjects];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    
    LocationEntity *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = location.cityName;
    
    return cell;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    LocationEntity *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    CoreDataStack *dataStack = [CoreDataStack defaultStack];
    
    [[dataStack managedObjectContext] deleteObject:location];
    
    
    [dataStack saveContext];
    
}



#pragma mark - NSFetchedResultDelegate

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView beginUpdates];
}





-(void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    //LocationEntity *location;
    switch (type) {
        case NSFetchedResultsChangeInsert:
            //location = [self.fetchedResultsController objectAtIndexPath:indexPath];
            //if (location.cityName.length != 0) {
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            //}
            //break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        default:
            break;
    }
    
}


-(void) controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
    
}


-(void) controllerDidChangeContent: (NSFetchedResultsController *) controller {
    
    //NSLog(@"controllerDidChangeContent===============");
    [self.tableView endUpdates];
}


@end
