//
//  SettingsViewController.m
//  TrackMyCash
//
//  Created by Raymond Tam on 10/1/12.
//
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
        
        //*** DROPSHADOW ***//
        UIImage *imgDropShadow = [UIImage imageNamed:@"dropshadow.png"];
        UIImageView *imgViewDropShadow = [[UIImageView alloc] initWithImage:imgDropShadow];
        imgViewDropShadow.frame = CGRectMake(0, 0 - imgDropShadow.size.height, imgDropShadow.size.width, imgDropShadow.size.height);
        [self.view addSubview:imgViewDropShadow];
        
        UINavigationBar *navBar = [[UINavigationBar alloc] init];
        navBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
        UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"Settings/Info"];
        [navBar pushNavigationItem:navItem animated:NO];
        UIBarButtonItem *btnClose = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonTapped:)];
        navItem.leftBarButtonItem = btnClose;
        [self.view addSubview:navBar];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIButton *btnClearData = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnClearData.frame = CGRectMake(75, 60, self.view.frame.size.width - 150, 40);
    [btnClearData.titleLabel setFont:DEFAULT_FONT(16)];
    [btnClearData setTitle:@"Clear All Data" forState:UIControlStateNormal];
    [btnClearData addTarget:self action:@selector(clearAllDataTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnClearData];

    UIView *blackBar = [[UIView alloc] initWithFrame:CGRectMake(10, 120, self.view.frame.size.width - 20, 1)];
    blackBar.backgroundColor = [UIColor blackColor];
    [self.view addSubview:blackBar];
    
    UIButton *btnLinkToSite = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLinkToSite.frame = CGRectMake(10, 130, self.view.frame.size.width - 20, 40);
    [btnLinkToSite.titleLabel setFont:DEFAULT_FONT_LIGHT(16)];
    [btnLinkToSite addTarget:self action:@selector(linkToSite:) forControlEvents:UIControlEventTouchUpInside];
    [btnLinkToSite setTitle:@"www.TrackMyCashApp.com" forState:UIControlStateNormal];
    [btnLinkToSite setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:btnLinkToSite];
    
    UILabel *lblDeveloper = [[UILabel alloc] initWithFrame:CGRectMake(10, 170, self.view.frame.size.width - 20, 30)];
    lblDeveloper.text = @"Developer";
    [lblDeveloper setFont:DEFAULT_FONT_BOLD(14)];
    lblDeveloper.backgroundColor = [UIColor clearColor];
    lblDeveloper.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:lblDeveloper];
    
    UILabel *lblDeveloperName = [[UILabel alloc] initWithFrame:CGRectMake(10, 190, self.view.frame.size.width - 20, 30)];
    lblDeveloperName.text = @"Ray Tam";
    [lblDeveloperName setFont:DEFAULT_FONT_LIGHT(14)];
    lblDeveloperName.backgroundColor = [UIColor clearColor];
    lblDeveloperName.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:lblDeveloperName];
    
    UILabel *lblDesigner = [[UILabel alloc] initWithFrame:CGRectMake(10, 220, self.view.frame.size.width - 20, 30)];
    lblDesigner.text = @"App icon and splash screen";
    [lblDesigner setFont:DEFAULT_FONT_BOLD(14)];
    lblDesigner.backgroundColor = [UIColor clearColor];
    lblDesigner.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:lblDesigner];
    
    UILabel *lblDesignerName = [[UILabel alloc] initWithFrame:CGRectMake(10, 240, self.view.frame.size.width - 20, 30)];
    lblDesignerName.text = @"Ethan Cantrell";
    [lblDesignerName setFont:DEFAULT_FONT_LIGHT(14)];
    lblDesignerName.backgroundColor = [UIColor clearColor];
    lblDesignerName.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:lblDesignerName];
    
    UILabel *lblSpecialThanks = [[UILabel alloc] initWithFrame:CGRectMake(10, 270, self.view.frame.size.width - 20, 30)];
    lblSpecialThanks.text = @"Special Thanks";
    [lblSpecialThanks setFont:DEFAULT_FONT_BOLD(14)];
    lblSpecialThanks.backgroundColor = [UIColor clearColor];
    lblSpecialThanks.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:lblSpecialThanks];
    
    UILabel *lblSpecialThanksName5 = [[UILabel alloc] initWithFrame:CGRectMake(10, 290, self.view.frame.size.width - 20, 30)];
    lblSpecialThanksName5.text = @"Leo “Psy” the Leon";
    [lblSpecialThanksName5 setFont:DEFAULT_FONT_LIGHT(14)];
    lblSpecialThanksName5.backgroundColor = [UIColor clearColor];
    lblSpecialThanksName5.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:lblSpecialThanksName5];
    
    UILabel *lblSpecialThanksName1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 310, self.view.frame.size.width - 20, 30)];
    lblSpecialThanksName1.text = @"Mark Guerra";
    [lblSpecialThanksName1 setFont:DEFAULT_FONT_LIGHT(14)];
    lblSpecialThanksName1.backgroundColor = [UIColor clearColor];
    lblSpecialThanksName1.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:lblSpecialThanksName1];
    
    UILabel *lblSpecialThanksName3 = [[UILabel alloc] initWithFrame:CGRectMake(10, 330, self.view.frame.size.width - 20, 30)];
    lblSpecialThanksName3.text = @"John Reed";
    [lblSpecialThanksName3 setFont:DEFAULT_FONT_LIGHT(14)];
    lblSpecialThanksName3.backgroundColor = [UIColor clearColor];
    lblSpecialThanksName3.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:lblSpecialThanksName3];
    
    UILabel *lblSpecialThanksName2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 350, self.view.frame.size.width - 20, 30)];
    lblSpecialThanksName2.text = @"Bobby “LafNBoy” Wong";
    [lblSpecialThanksName2 setFont:DEFAULT_FONT_LIGHT(14)];
    lblSpecialThanksName2.backgroundColor = [UIColor clearColor];
    lblSpecialThanksName2.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:lblSpecialThanksName2];
    
    UILabel *lblSpecialThanksName4 = [[UILabel alloc] initWithFrame:CGRectMake(10, 370, self.view.frame.size.width - 20, 30)];
    lblSpecialThanksName4.text = @"Paul Yang";
    [lblSpecialThanksName4 setFont:DEFAULT_FONT_LIGHT(14)];
    lblSpecialThanksName4.backgroundColor = [UIColor clearColor];
    lblSpecialThanksName4.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:lblSpecialThanksName4];
}

- (void)linkToSite:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.trackmycashapp.com"]];
}

- (void)closeButtonTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)clearAllDataTapped:(id)sender {
    UIAlertView *alrtConfirmClear = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to clear all app data? This action is cannot be undone!" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alrtConfirmClear.tag = 0;
    [alrtConfirmClear show];
}

#pragma mark - AlertViewDelegate functions
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 0) {        
        if(buttonIndex == 0) { // confirmed clear database
            [[DataService sharedDataService] clearDatabase];
            
            UIAlertView *alrtDataCleared = [[UIAlertView alloc] initWithTitle:@"Info" message:@"App data has been successfully cleared" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alrtDataCleared.tag = 1;
            [alrtDataCleared show];
        }
    }
    else if(alertView.tag == 1) {
        [self dismissModalViewControllerAnimated:YES];
    }
}

@end
