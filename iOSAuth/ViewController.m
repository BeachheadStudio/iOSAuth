//
//  ViewController.m
//  iOSAuth
//
//  Created by SingleMalt on 3/30/16.
//  Copyright © 2016 SingleMalt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ViewController.h"
#import "AuthService.h"
#import "HTTPHelper.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITextView *fppiTextView;
@property (strong, nonatomic) IBOutlet UITextView *gtTextView;
@property (strong, nonatomic) IBOutlet UITextView *aTextView;
@property (strong, nonatomic) IBOutlet UITextView *piTextView;
@property (strong, nonatomic) IBOutlet UITextView *errorTextView;
@property (strong, nonatomic) IBOutlet UITextView *stTextView;

@end

@implementation ViewController

@synthesize fppiTextView;
@synthesize gtTextView;
@synthesize aTextView;
@synthesize piTextView;
@synthesize errorTextView;
@synthesize stTextView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(showAuthViewController)
     name:PresentAuthViewController object:nil];
    
    [self addTextViews];
    
    [[AuthService sharedAuthService] setRootViewController:self];
    
    [[AuthService sharedAuthService] authLocalPlayer:@"http://192.168.1.154:8080/auth" serverPlayerId:nil];
}

-(void)showAuthViewController
{
    NSLog(@"showAuthViewController");
    
    [self.topViewController presentViewController:[AuthService sharedAuthService].authViewController
                                         animated:YES
                                       completion:nil
     ];
}

-(void)addTextViews {
    UIColor *blackColor = [[UIColor alloc]initWithRed:0.0
                                                green:0.0
                                                 blue:0.0
                                                alpha:1.0];
    
    fppiTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, 100, 300, 80)];
    fppiTextView.text = @"First Party Player Id: ";
    [fppiTextView setTextColor:blackColor];
    [self.view addSubview:fppiTextView];

    gtTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, 180, 300, 80)];
    gtTextView.text = @"Gamer Tag: ";
    [gtTextView setTextColor:blackColor];
    [self.view addSubview:gtTextView];

    aTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, 260, 300, 80)];
    aTextView.text = @"Is Anonymous: ";
    [aTextView setTextColor:blackColor];
    [self.view addSubview:aTextView];

    piTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, 340, 300, 80)];
    piTextView.text = @"PlayerId: ";
    [piTextView setTextColor:blackColor];
    [self.view addSubview:piTextView];

    stTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, 420, 300, 80)];
    stTextView.text = @"Session Token: ";
    [stTextView setTextColor:blackColor];
    [self.view addSubview:stTextView];
    
    errorTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, 500, 300, 80)];
    errorTextView.text = @"Error: ";
    [errorTextView setTextColor:blackColor];
    [self.view addSubview:errorTextView];
}

-(void)updateTextViews {
    NSLog(@"updating text views");
    dispatch_block_t block = ^{
        [fppiTextView setText:[@"First Party Player Id: " stringByAppendingString:[[AuthService sharedAuthService] getPlayerId]]];
        [gtTextView setText:[@"Gamer Tag: " stringByAppendingString: [[AuthService sharedAuthService] getPlayerName]]];
        [aTextView setText:[@"Is Anonymous: " stringByAppendingString: [[AuthService sharedAuthService] isAnonymous] ? @"YES" : @"NO"]];
        [piTextView setText:[@"Player Id: " stringByAppendingString: [[AuthService sharedAuthService] getServerPlayerId]]];
        [stTextView setText:[@"Session Token: " stringByAppendingString: [[AuthService sharedAuthService] getSessionToken]]];
        [errorTextView setText:[@"Error: " stringByAppendingString: [[AuthService sharedAuthService] getFailureError]]];
    };
    
    
    if([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
