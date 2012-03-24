//
//  ViewController.m
//  TweetBG
//
//  Created by Artur Shinkevich on 11-12-01.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"
#import "MyImage.h"

@implementation FirstViewController

@synthesize accounts = _accounts;
@synthesize accountStore = _accountStore;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    self.title = @"TweetBG";
    if (self) {
        [self fetchData];
    }
    return self;
}

#pragma mark - Data handling

- (void)fetchData
{
    if (_accounts == nil) {
        if (_accountStore == nil) {
            self.accountStore = [[ACAccountStore alloc] init];
        }
        ACAccountType *accountTypeTwitter = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [self.accountStore requestAccessToAccountsWithType:accountTypeTwitter withCompletionHandler:^(BOOL granted, NSError *error) {
            if(granted) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.accounts = [self.accountStore accountsWithAccountType:accountTypeTwitter];
                    [self.tableView reloadData]; 
                });
            }
        }];
    }
//    NSLog(@"%@ %@", _accounts, _accountStore);
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.accounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
	NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    Account *newAccount = (Account *)
    [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // Configure the cell...
    ACAccount *account = [self.accounts objectAtIndex:[indexPath row]];
    cell.textLabel.text = account.username;
    newAccount.name = cell.textLabel.text; 
    cell.detailTextLabel.text = account.accountDescription;
    newAccount.accountDescription = account.accountDescription;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    TWRequest *fetchAdvancedUserProperties = [[TWRequest alloc] 
                                              initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1/users/show.json"] 
                                              parameters:[NSDictionary dictionaryWithObjectsAndKeys:account.username, @"screen_name", nil]
                                              requestMethod:TWRequestMethodGET];
    [fetchAdvancedUserProperties performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 200) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSError *error;
                id userInfo = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
                cell.textLabel.text = [userInfo valueForKey:@"name"];
                newAccount.name = cell.textLabel.text; 
                //hope that the above line works
            });
        }
    }];
    
    TWRequest *fetchUserImageRequest = [[TWRequest alloc] 
                                        initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.twitter.com/1/users/profile_image/%@", account.username]] 
                                        parameters:nil
                                        requestMethod:TWRequestMethodGET];
    [fetchUserImageRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 200) {
            UIImage *image = [UIImage imageWithData:responseData];
            image = [UIImage imageWithImage:image scaledToSize:CGSizeMake(30, 30)];
            dispatch_sync(dispatch_get_main_queue(), ^{
                
            cell.imageView.image = image;
            [cell setNeedsLayout];
        });
    }
}];
    
    
    
    NSError *error;
    if (![[newAccount managedObjectContext] save:&error]) {
		// Handle the error (and do it better in a production app)
    }
    
    
   // NSFileManager *file_manager = [NSFileManager defaultManager];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self connectedToTheInternet]){
        TweetsViewController *tweetsListViewController = [[TweetsViewController alloc] init];
        tweetsListViewController.account = [self.accounts objectAtIndex:[indexPath row]];
        tweetsListViewController.referringObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.navigationController pushViewController:tweetsListViewController animated:TRUE];
       }
    else
        [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

       
#pragma mark Reachability methods
       
       
- (BOOL) connectedToTheInternet
{
    // called after network status changes
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    hostReachable = [Reachability reachabilityWithHostName: @"http://twitter.com"];
    [hostReachable startNotifier];
    
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    if (internetStatus == NotReachable){
        internetActive = NO;
        UIAlertView *internetDownAlert = [[UIAlertView alloc] 
                                          initWithTitle:@"Internet is down" 
                                          message:@"Please make sure you're connected to the internet and then proceed to game" 
                                          delegate:self 
                                          cancelButtonTitle:@"Okay..." 
                                          otherButtonTitles:nil, nil];
        [internetDownAlert show];
        [internetDownAlert release];
        
    }
    else
        internetActive = YES;
    return internetActive;
}

#pragma mark - Fetched results controller

 - (NSFetchedResultsController *)fetchedResultsController
 {
 // If the fetched results controller already exists, return it
     if (_fetchedResultsController != nil)
     {
     return _fetchedResultsController;
     }
 
     // Otherwise, create and configure it...
     
     // Create the fetch request
     // Then, in later statements, we will configure the fetch request
     NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
 
     // Set the entity name
     NSEntityDescription *entity = [NSEntityDescription entityForName:@"Account" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
 
     // Set the batch size to a suitable number (optional)
     [fetchRequest setFetchBatchSize:20];
 
     // Edit the desired sort key(s)
     NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
     NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
 
     // Note that there is no predicate in this root view controller
     // All objects (for the named entity) will be fetched 
 
     // At this point in time, the fetch request has been configured
 
     // Best practice... clear the cache before creating the fetched results controller
     [NSFetchedResultsController deleteCacheWithName:@"Account"];
 
     // Now, create and configure the fetched results ocontroller
     NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Account"];
     aFetchedResultsController.delegate = self;
 
     // Set the property
     self.fetchedResultsController = aFetchedResultsController;
 
     // Clean up
     [aFetchedResultsController release];
     [fetchRequest release];
     [sortDescriptor release];
     [sortDescriptors release];
 
     // Perform the fetch
     NSError *error = nil;
     if (![self.fetchedResultsController performFetch:&error])
     {
         /*
          Replace this implementation with code to handle the error appropriately.
    
          abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
          */
       NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
       abort();
       }
       
       return _fetchedResultsController;
}    
       
     
@end
