//
//  HighScoresViewController.m
//  Colour Memory
//
//  Created by gio on 28-11-15.
//  Copyright © 2015 giosalinas. All rights reserved.
//

#import "HighScoresViewController.h"
#import "AppDelegate.h"

@interface HighScoresViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end

@implementation HighScoresViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"High Scores";

    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [self fetchRanking];
}

- (void)fetchRanking
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Ranking"];
    
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"points" ascending:NO]]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [self.fetchedResultsController setDelegate:self];
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    
    if (error) {
        NSLog(@"Unable to perform fetch.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
}

- (void)savePlayerWithName:(NSString *)name andPoints:(NSString *)points
{
    if (!self.managedObjectContext)
    {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        self.managedObjectContext = appDelegate.managedObjectContext;
    }
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ranking" inManagedObjectContext:self.managedObjectContext];
    
    NSManagedObject *record = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    
    [record setValue:name forKey:@"name"];
    [record setValue:[NSNumber numberWithInt:[points intValue]] forKey:@"points"];
    
    NSError *error = nil;
    
    if (![self.managedObjectContext save:&error])
    {
        if (error)
        {
            NSLog(@"Unable to save record.");
            NSLog(@"%@, %@", error, error.localizedDescription);
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"playerCell" forIndexPath:indexPath];
    
    NSManagedObject *player = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *name = [player valueForKey:@"name"];
    NSString *points = [[player valueForKey:@"points"] stringValue];

    UILabel *positionLabel = [cell viewWithTag:10];
    UILabel *nameLabel = [cell viewWithTag:11];
    UILabel *pointsLabel = [cell viewWithTag:12];
    
    positionLabel.text = [NSString stringWithFormat:@"%ld-", (indexPath.item+1)];
    nameLabel.text = name;
    pointsLabel.text = points;
    
    return cell;
}

#pragma mark - Core Data methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableview beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableview endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
   // nothing yet
}

@end
