//
//  ViewController.h
//  TweetBG
//
//  Created by Artur Shinkevich on 11-12-01.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TweetsViewController.h"
#import "Reachability.h"
#import "Account.h"

@class Reachability;

@interface FirstViewController : UITableViewController <NSFetchedResultsControllerDelegate>{
    Reachability* internetReachable;
    Reachability* hostReachable;
    BOOL internetActive;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


@property (strong, nonatomic) ACAccountStore *accountStore; 
@property (strong, nonatomic) NSArray *accounts;

-(void)fetchData;
-(BOOL) connectedToTheInternet;

@end
