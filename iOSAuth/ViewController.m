//
//  ViewController.m
//  iOSAuth
//
//  Created by SingleMalt on 3/30/16.
//  Copyright © 2016 SingleMalt. All rights reserved.
//

#import "ViewController.h"
#import "AuthService.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *fppiTextView;
@property (weak, nonatomic) IBOutlet UITextView *gtTextView;
@property (weak, nonatomic) IBOutlet UITextView *aTextView;
@property (weak, nonatomic) IBOutlet UITextView *piTextView;

@end

@implementation ViewController

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
    
    [[AuthService sharedAuthService] authLocalPlayer];
}

-(void)showAuthViewController
{
    AuthService *authService = [AuthService sharedAuthService];
    
    [self.topViewController presentViewController:
                    authService.authViewController
                                         animated:YES
                                       completion:nil
     ];

    _fppiTextView.text = [@"First Party PlayerId: " stringByAppendingString: [[AuthService sharedAuthService] getFirstPartyPlayerId]];
    _gtTextView.text   = [@"Gamer Tag: " stringByAppendingString: [[AuthService sharedAuthService] getPlayerName]];
    _aTextView.text    = [@"Is Anonymous: " stringByAppendingString: [[AuthService sharedAuthService] isAnonymous] ? @"YES" : @"NO"];
    _piTextView.text   = [@"PlayerId: " stringByAppendingString: [[AuthService sharedAuthService] getPlayerId]];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
