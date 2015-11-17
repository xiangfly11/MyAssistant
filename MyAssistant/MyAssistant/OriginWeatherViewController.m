//
//  OriginWeatherViewController.m
//  MyAssistant
//
//  Created by Jiaxiang Li on 11/12/15.
//  Copyright © 2015 Jiaxiang Li. All rights reserved.
//

#import "OriginWeatherViewController.h"
#import "SWRevealViewController.h"
#import "WeatherPageViewController.h"
#import "WeatherViewController.h"
#import "LocationEntity.h"
#import "CoreDataStack.h"

@interface OriginWeatherViewController ()<UIPageViewControllerDataSource,NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *slideMenuButton;
@property (strong,nonatomic) WeatherPageViewController *pageViewController;
@property (strong,nonatomic) NSFetchedResultsController *fetchedResultController;
@property (strong,nonatomic) NSMutableArray *cityNames;
@end

@implementation OriginWeatherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if (revealViewController) {
        [self.slideMenuButton setTarget:self.revealViewController];
        
        [self.slideMenuButton setAction:@selector(revealToggle:)];
        
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    

    [self configurePageViewController];
}

-(void)viewWillAppear:(BOOL)animated {
    [self configurePageViewController];
}


-(void) configurePageViewController {
    [self.pageViewController.view removeFromSuperview];
    [self.pageViewController removeFromParentViewController];
    self.cityNames = [[NSMutableArray alloc] init];
    [self fetchLocations];
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    WeatherViewController *startViweController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startViweController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:nil completion:nil];
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 15);
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSFetchedResultsController *)fetchedResultController {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"LocationEntity"];
    if (_fetchedResultController) {
        return _fetchedResultController;
    }
    
    CoreDataStack *dataStack = [CoreDataStack defaultStack];
    _fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:dataStack.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    _fetchedResultController.delegate = self;
    
    return _fetchedResultController;
}

-(void) fetchLocations {
    
    CoreDataStack *dataStack = [CoreDataStack defaultStack];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LocationEntity" inManagedObjectContext:dataStack.managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPropertiesToFetch:@[@"cityName"] ];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    
    NSError *error = nil;
    
    NSArray *array = [dataStack.managedObjectContext executeFetchRequest:request error:&error];
    [self.cityNames setArray:array];
    
    NSLog(@"City:%@",self.cityNames);
    
    
}





//-(void) configurationCities {
//    self.cityNames = [[NSMutableArray alloc] initWithObjects:@"London",@"Beijing",@"NewYork", nil];
//}

-(WeatherViewController *) viewControllerAtIndex:(NSUInteger) index {
    if ([self.cityNames count] == 0){
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    
//    pageContentViewController.imageFile = self.pageImages[index];
//    pageContentViewController.titleText = self.pageTitles[index];
//    pageContentViewController.pageIndex = index;
   
    
    if (index == 0) {
        WeatherViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WeatherViewController"];
        pageContentViewController.pageIndex = index;
        return pageContentViewController;
    }else {
        WeatherViewController *pageContentVeiwController = [self.storyboard instantiateViewControllerWithIdentifier:@"WeatherViewController"];
        pageContentVeiwController.pageIndex = index;
        NSDictionary *dict = self.cityNames[index - 1];
        NSString *city = [dict objectForKey:@"cityName"];
        pageContentVeiwController.cityName = city;
        
        return pageContentVeiwController;
    }
}

#pragma mark - NSFetchedResultControllerDelegate







#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((WeatherViewController *) viewController).pageIndex;
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((WeatherViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.cityNames count] + 1) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.cityNames count]+1;
    //return 3;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
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
