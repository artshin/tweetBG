//
//  TweetsViewController.m
//  TweetBG
//
//  Created by Artur Shinkevich on 11-12-01.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TweetsViewController.h"
#import "MyImage.h"
#import "Tweet.h"
#import "SelectedTweetController.h"
#import "TweetComposeViewController.h"


@implementation TweetsViewController

@synthesize account = _account;
@synthesize timeline = _timeline;
@synthesize referringObject = _referringObject;
@synthesize fetchedResultsController = _fetchedResultsController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)fetchData
{
    TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.twitter.com/1/statuses/home_timeline.json"] parameters:nil requestMethod:TWRequestMethodGET];
    
    [postRequest setAccount:self.account];    
    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 200) {
            NSError *jsonError = nil;
            
            self.timeline = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *compose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose 
                                                                             target:self 
                                                                             action:@selector(composeTweet)];
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                                                             target:self 
                                                                             action:@selector(fetchData)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:compose, refresh, nil];
}

#pragma mark - Compose Tweet

- (void)composeTweet
{
    TweetComposeViewController *tweetComposeViewController = [[TweetComposeViewController alloc] init];
    tweetComposeViewController.account = self.account;
    tweetComposeViewController.tweetComposeDelegate = self;
    [self presentViewController:tweetComposeViewController animated:YES completion:nil];
    
    //    TWTweetComposeViewController *tweetComposeViewController = [[TWTweetComposeViewController alloc] init];
    //    [tweetComposeViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
    //        [self dismissModalViewControllerAnimated:YES];
    //    }];
    //    [self presentModalViewController:tweetComposeViewController animated:YES];
}

- (void)tweetComposeViewController:(TweetComposeViewController *)controller didFinishWithResult:(TweetComposeResult)result {
    [self dismissModalViewControllerAnimated:YES];
    [self fetchData];
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
    self.title = [NSString stringWithFormat:@"@%@", self.account.username];
    [self fetchData];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.timeline count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSManagedObjectContext *aContext = [self.fetchedResultsController managedObjectContext];
	NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
	Tweet *newTweetObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:aContext];
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    id tweet = [self.timeline objectAtIndex:[indexPath row]];
    // NSLog(@"Tweet at index %d is %@", [indexPath row], tweet);
    cell.detailTextLabel.text = [tweet objectForKey:@"text"];
    cell.textLabel.text = [tweet valueForKeyPath:@"user.name"];
    [newTweetObject setOwner:cell.textLabel.text];
    [newTweetObject setText:cell.detailTextLabel.text];
    
    NSError *error;
	if (![[self.referringObject managedObjectContext] save:&error]) {
		// Handle the error (and do it better in a production app)
	} 
//    NSLog(@"%@", [tweet valueForKeyPath:@"user.profile_image_url"]);
    
    UIImage *test = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[tweet valueForKeyPath:@"user.profile_image_url"]]]];
    
    test = [UIImage imageWithImage:test scaledToSize:CGSizeMake(30, 30)];
    cell.imageView.image = test;
                                
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SelectedTweetController *selectedTweet = (SelectedTweetController *)[[SelectedTweetController alloc] init];
    id tweet = [self.timeline objectAtIndex:[indexPath row]];
    selectedTweet.tempName = [tweet valueForKeyPath:@"user.name"];
    selectedTweet.tempTweet = [tweet objectForKey:@"text"];
    UIImage *test = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[tweet valueForKeyPath:@"user.profile_image_url"]]]];
    selectedTweet.tempImage = test;
    [self.navigationController pushViewController:selectedTweet animated:TRUE];

}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    // If the fetched results controller already exists, return it
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
	
	// Otherwise, create it, configure it, and return it
	
	// Configure the enitity, and attach it to a managed object context
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tweet" 
                                              inManagedObjectContext:[_referringObject managedObjectContext]];
	
	// Create the fetch request
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
	// Set the fetch request's entity property
	[fetchRequest setEntity:entity];
	
	// Create sort descriptor(s)
	NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"owner" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    
	// Set the fetch request's sortDescriptors property
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Predicate configuration - specify the relationship's property name "program" 
	// checks whether the value of the key "programs" is the same as the value of the object %@ 
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"account == %@", self.referringObject];
	[fetchRequest setPredicate:pred];
	
	// Clear the cache
	[NSFetchedResultsController deleteCacheWithName:@"Tweet"];
	
	// Create the fetched results controller
	// Edit the section name key path and cache name if appropriate; nil for section name key path means "no sections"
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[_referringObject managedObjectContext] sectionNameKeyPath:@"owner" cacheName:@"Tweet"];
    
	// Set the fetched results controller's delegate to self; it will call controllerDidChangeContent:
    aFetchedResultsController.delegate = self;
	// Assign this new fetched results controller to the property
	self.fetchedResultsController = aFetchedResultsController;
	
	// Memory manage
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor1 release];
	[sortDescriptors release];
	
	return _fetchedResultsController;
}    


/*
 
 http://tweetbg.me/builder/sample/500px/coffe
 ответ ссылка на файл
 */
@end
