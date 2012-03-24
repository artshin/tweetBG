//
//  SelectedTweetController.m
//  TweetBG
//
//  Created by Artur Shinkevich on 11-12-02.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SelectedTweetController.h"

@implementation SelectedTweetController
@synthesize UserImage;
@synthesize UserName;
@synthesize UserTweet;
@synthesize referringObject = _referringObject;
@synthesize tempImage = _tempImage;
@synthesize tempName = _tempName;
@synthesize tempTweet = _tempTweet;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    [UserImage setImage:_tempImage];
    [UserName setText:_tempName];
    [UserTweet setText:_tempTweet];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setUserImage:nil];
    [self setUserName:nil];
    [self setUserTweet:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [UserImage release];
    [UserName release];
    [UserTweet release];
    [super dealloc];
}
@end
