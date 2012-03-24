//
//  TweetComposeViewController.m
//  TweetBG
//
//  Created by Artur Shinkevich on 11-12-02.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TweetComposeViewController.h"
#import <Twitter/Twitter.h>

@implementation TweetComposeViewController

@synthesize account = _account;
@synthesize tweetComposeDelegate = _tweetComposeDelegate;

@synthesize closeButton;
@synthesize sendButton;
@synthesize textView;
@synthesize titleView;
@synthesize shiftForKeyboard;

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

- (void)viewWillAppear:(BOOL)animated
{
    self.titleView.title = [NSString stringWithFormat:@"@%@", self.account.username];    
    [textView setKeyboardType:UIKeyboardTypeTwitter];
    [textView becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setCloseButton:nil];
    [self setSendButton:nil];
    [self setTextView:nil];
    [self setTitleView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (IBAction)sendTweet:(id)sender 
{
    NSString *status = self.textView.text;
    
    TWRequest *sendTweet = [[TWRequest alloc] 
                            initWithURL:[NSURL URLWithString:@"https://api.twitter.com/1/statuses/update.json"] 
                            parameters:[NSDictionary dictionaryWithObjectsAndKeys:status, @"status", nil]
                            requestMethod:TWRequestMethodPOST];
    sendTweet.account = self.account;
    [sendTweet performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 200) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.tweetComposeDelegate tweetComposeViewController:self didFinishWithResult:TweetComposeResultSent];
            });
            [self.tweetComposeDelegate tweetComposeViewController:self didFinishWithResult:TweetComposeResultCancelled];

        }
        else {
            NSLog(@"Problem sending tweet: %@", error);
        }
    }];

}

- (IBAction)cancel:(id)sender
{
    [self.tweetComposeDelegate tweetComposeViewController:self didFinishWithResult:TweetComposeResultCancelled];
}

#pragma mark -
#pragma mark Delegate methods

// DELEGATE METHOD - Dismiss the keyboard
- (BOOL) textFieldShouldReturn:(UITextView*)TextF{
	NSLog(@"pressed return in text field number... %d", [TextF tag]);
	[TextF resignFirstResponder];
	return YES;
}

// DELEGATE METHOD - Shift view up from under the keyboard
- (void) textFieldDidBeginEditing:(UITextView *)TextF {
	
	NSLog(@"text field number... %d", [TextF tag]);
    
	// General approach...
	// Get the position of the UITextField rectangle
	// If its bottom edge is 250 or greater, then move it up
	// FYI - the portrait keyboard is 216 pixels in height
    
	// Make a CGRect so we can get the textField dimensions and position
	// The following statement gets the rectangle
	CGRect textFieldRect = [self.view.window convertRect:TextF.bounds fromView:TextF];
	// Find out what the bottom edge value is
	CGFloat bottomEdge = textFieldRect.origin.y + textFieldRect.size.height;
	
	// If the bottom edge is 250 or more, we want to shift the view up
	// We chose 250 here instead of 264, so that we would have some visual buffer space
	if (bottomEdge >= 250) {
		
		// Make a CGRect for the view (which should be positioned at 0,0 and be 320px wide and 480px tall)
		CGRect viewFrame = self.view.frame;
		
		// Determine the amount of the shift
		self.shiftForKeyboard = bottomEdge - 250.0f;
		NSLog(@"shifted the view up %1.0f px", self.shiftForKeyboard);
        
		// Adjust the origin for the viewFrame CGRect
		viewFrame.origin.y -= self.shiftForKeyboard;
		
		// The following animation setup just makes it look nice when shifting
		// We don't really need the animation code, but we'll leave it in here
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:0.3];
        
		// Apply the new shifted vewFrame to the view
		[self.view setFrame:viewFrame];
		
		// More animation code
		[UIView commitAnimations];
		
	} else {
		// No view shifting required; set the value accordingly
		self.shiftForKeyboard = 0.0f;
	}
}

// DELEGATE METHOD - Shift view back down after we're done with the keyboard
- (void) textFieldDidEndEditing:(UITextView *)TextF {
    
	// Make a CGRect for the view (which should be positioned at 0,0 and be 320px wide and 480px tall)
	CGRect viewFrame = self.view.frame;
    
	// Adjust the origin back for the viewFrame CGRect
	viewFrame.origin.y += self.shiftForKeyboard;
	NSLog(@"shifted the view down %1.0f px", self.shiftForKeyboard);
    
	// Set the shift value back to zero
	self.shiftForKeyboard = 0.0f;
	
	// As above, the following animation setup just makes it look nice when shifting
	// Again, we don't really need the animation code, but we'll leave it in here
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3];
	
	// Apply the new shifted vewFrame to the view
	[self.view setFrame:viewFrame];
    
	// More animation code
	[UIView commitAnimations];
}


@end
