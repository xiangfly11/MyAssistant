//
//  NotesViewController.m
//  MyAssistant
//
//  Created by Jiaxiang Li on 15/8/23.
//  Copyright (c) 2015年 Jiaxiang Li. All rights reserved.
//

#import "NotesViewController.h"
#import "SWRevealViewController.h"
#import <CoreData/CoreData.h>
//#import "NotesEntry.h"
#import "NotesCoreDataStack.h"
#import "NewNotesEntity.h"

@interface NotesViewController () <UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate>

@property (strong,nonatomic) NSFetchedResultsController *fetchedRequestController;


@end

@implementation NotesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if (revealViewController) {
        [self.slideMenuButton setTarget:self.revealViewController];
        
        [self.slideMenuButton setAction:@selector(revealToggle:)];
        
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    
    [self.fetchedRequestController performFetch:nil];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
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



-(NSFetchRequest *) entryListFetchRequest {
    
    NSLog(@"entryListFetchRequest");
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"NewNotesEntity"];
    
    
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    
    
    
    return fetchRequest;
}



-(NSFetchedResultsController *) fetchedRequestController {
    
    //Lazy loading technique - wait till the last minute when this property is accessed only create one if it is not nil
    
    NSLog(@"fetchRequestController");
    
    if (_fetchedRequestController != nil) {
        return  _fetchedRequestController;
    }
    
    
    NotesCoreDataStack *coreDataStack = [NotesCoreDataStack defaultStack];
    
    NSFetchRequest *fetchRequest = [self entryListFetchRequest];
    
    
    //Passing the sectionName property of diaryEntrty in the sectionNameKeyPath argument
    
    _fetchedRequestController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:coreDataStack.managedObjectContext sectionNameKeyPath:@"sectionName" cacheName:nil];
    
    _fetchedRequestController.delegate = self;
    
    return _fetchedRequestController;
}



-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedRequestController sections] [section];
    
    return [sectionInfo name];
}

-(UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NewNotesEntity *entry = [self.fetchedRequestController objectAtIndexPath:indexPath];
    
    NotesCoreDataStack *coreDataStack = [NotesCoreDataStack defaultStack];
    
    [[coreDataStack managedObjectContext] deleteObject:entry];
    
    [coreDataStack saveContext];
}


-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView beginUpdates];
}





-(void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    
    NSLog(@"numberOfSectionsInTableView");
    return self.fetchedRequestController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    NSLog(@"tableView,numberOfRowInSection");
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedRequestController sections] [section];
    
    
    
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"tableView,cellForRowAtIndexPath");
    static NSString *identifier = @"NotesViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    
    
    // Configure the cell...
    
    NewNotesEntity *entry = [self.fetchedRequestController objectAtIndexPath:indexPath];
    
    
    
    
    //cell.textLabel.text = entry.body;
    
    //[cell configureCellForEntry: entry];
    
    cell.textLabel.text =entry.body;
    
    return cell;
}







@end
