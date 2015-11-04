//
//  GameView.m
//  One Dreamer Company
//  www.one-dreamer.com
//  Copyright (c) 2014 One Dreamer Company. All rights reserved.


/*  The Game has 3 Stages or 'Phases'
     ----------------------------------
    | Main Menu --> Game --> Game Over |
     ----------------------------------
 */


//-- Import Required Frameworks/Headers
#import "GameView.h"
#import "Object.h"
#import "Settings.h"

@import GoogleMobileAds;

@interface GameView ()
@end

@implementation GameView

//-- Synthesize Game Properties
@synthesize Floor, Flash;

//-- Synthesize UI Properties
@synthesize Brief, ScoreLabel, GameTimerLabel, GameCenterButton, RateButton, FacebookButton, TwitterButton, BestImg, MusicButton;

//-- Synthesize Other
@synthesize player;



//---- ViewDidLoad - Called when app starts ----
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //ADMOB INTEGRATION!!!  FOR BANNER
    NSLog(@"Google Mobile Ads SDK version: %@", [GADRequest sdkVersion]);
    self.bannerView.adUnitID = @"ca-app-pub-3608073587678030/1807463907";
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
    
    self.iPadBannerView.adUnitID = @"ca-app-pub-3608073587678030/1807463907";
    self.iPadBannerView.rootViewController = self;
    [self.iPadBannerView loadRequest:[GADRequest request]];
    
    //ADMOB INTEGRATION!!! FOR INTERSTITIAL ADS
    self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-3608073587678030/1845673103"];
    
    GADRequest *request = [GADRequest request];
    // Requests test ads on test devices.
    request.testDevices = @[@"2077ef9a63d2b398840261c8221a0c9b"];
    [self.interstitial loadRequest:request];
    
    
    //-- Load the settings.plist file
    self.Settings = [[Settings alloc] init];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Settings"]
                                                         ofType:@"plist"];
    
    self.Settings = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    
    //-- Prepare UILabels with correct fonts/sizes
    [self prepareFonts];
    
    //-- Save the Screen Bounds
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    screenSize = screenBound.size;
    
    //-- Init the Audio Player
    [self InitAudioPlayer];
    
    MusicButton.hidden = true;
    GameTimerLabel.hidden = true;
    
    //-- Set up *Game Center if user has enabled it
    if ([self.Settings.GameCenterEnabled intValue] == 0){
        
        GameCenterButton.hidden = true;
    }else{
        
        //Authenticate The Player
        [self AuthPlayer];
    }
    
    //-- Prepare Game
    ObjectArray = [[NSMutableArray alloc] init];
    Phase = 2;
    
    //-- Prepare Textfield's
    int BestScore = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"BestScore"];
    ScoreLabel.text = [NSString stringWithFormat:@"%d", BestScore];

    GameTimeCount = (int)[self.Settings.GameDuration integerValue];
    GameTimerLabel.text = [NSString stringWithFormat:@"%d", GameTimeCount];
    
    //-- NS Timers, Loop the Objects
    objTimer = [NSTimer scheduledTimerWithTimeInterval:(.009) target:self selector:@selector(updateObj) userInfo:nil repeats:YES];
}



//---- Phases ----
/*  This function controls the different game stages
     ----------------------------------
    | Main Menu --> Game --> Game Over |
     ----------------------------------
 */
-(void)phases{
    
    //-- If Phase is |Start| --Change-to--> |Game|
    if (Phase == 0){
        
        // Lower background music volume
        player.volume = 0.45;
        
        // Hide/Reset varibles & properties
        MusicButton.hidden = false;
        GameTimerLabel.hidden = false;
        GameCenterButton.hidden = true;
        RateButton.hidden = true;
        FacebookButton.hidden = true;
        TwitterButton.hidden = true;
        BestImg.hidden = true;
        Points = 0;
        Difficulty = 1;
        GameTimeCount = [self.Settings.GameDuration intValue];
        GameTimerLabel.text = [NSString stringWithFormat:@"%d", GameTimeCount];
        ScoreLabel.text = [NSString stringWithFormat:@"%d", Points];
        
        // Animate the UI & Load Banner
        [self screenFlash];
        Brief.image = [UIImage imageNamed:@"UI_Stage1.png"];
        [self callBreifUI];
        
        // Start the Game Timer & Move to the next phase
        gameTimer = [NSTimer scheduledTimerWithTimeInterval:(.75) target:self selector:@selector(createObj) userInfo:nil repeats:YES];
        
        gameOverTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                     target:self
                                                   selector:@selector(gameProgress)
                                                   userInfo:nil
                                                    repeats:YES];
        Phase = 1;
        
        // Play Sound
        [self PlaySound:@"MenuClick"];
        
    //-- If Phase is |Game| --Change-to--> |Game Over|
    }else if (Phase == 1){
        
        /*This is the Game Phase
          Good Place to Add game customizations
        */
        
    //-- If Phase is |Game Over| --Change-to--> |Start|
    }else if (Phase == 2){
        
        // Increase background music to Normal
        player.volume = 1.0;
        
        // Flash Screen
        [self screenFlash];
        
        // Hide/Reset varibles & properties
        MusicButton.hidden = true;
        GameTimerLabel.hidden = true;
        if (![self.Settings.GameCenterEnabled intValue] == 0) GameCenterButton.hidden = false;
        RateButton.hidden = false;
        FacebookButton.hidden = false;
        TwitterButton.hidden = false;
        BestImg.hidden = false;
        Brief.image = [UIImage imageNamed:@"UI_Taptostart.png"];
        GameTimeCount = [self.Settings.GameDuration intValue];
        GameTimerLabel.text = [NSString stringWithFormat:@"%d", GameTimeCount];
        
        // Display best score
        int BestScore = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"BestScore"];
        ScoreLabel.text = [NSString stringWithFormat:@"%d", BestScore];
        
        // Remove/Reset Animations
        [Brief.layer removeAllAnimations];
        Brief.alpha = 1;
        Brief.frame = CGRectMake(Brief.frame.origin.x, Brief.frame.size.height/2, Brief.frame.size.width, Brief.frame.size.height);
        
        // Play Sound
        [self PlaySound:@"MenuClick"];
    }
}


// ---- Game Progress ----
-(void)gameProgress{
    /*  EXPLANED
        This function is called every second to update the game time, 
        check if rush is active or the player is out of time
    */
    
    // Update game timer
    GameTimeCount = GameTimeCount - 1;
    GameTimerLabel.text = [NSString stringWithFormat:@"%d", GameTimeCount];
    
    // If Rush Activated
    if (GameTimeCount == 10){
        
        // Animate the UI
        Brief.image = [UIImage imageNamed:@"UI_Stage2.png"];
        [self callBreifUI];
        
        // Change game settings
        ScoreLabel.text = [NSString stringWithFormat:@"%d", Points];
        [self PlaySound:@"Rush"];
        Difficulty = 2;
    }
    
    // If Game out of time
    if (GameTimeCount <= 0){
    /*
        Remove all objects
    */
        self.view.userInteractionEnabled = false;
        [self gameOver];
        [self removeObjects];
        
        [ObjectArray removeAllObjects];
    }
}



// ##  Objects  ####


// ---- Create Object ----
-(void)createObj{
/*
Type 1: Normal Object
*/
    // -- Create Objects
    /* 
       Create random number of object(s) in wave
       Difficulty increase chance of more objects
    */
    int noInWave = arc4random() % 1 + Difficulty;
    
    for (int i = 0;i < noInWave; i++){
    
        // Create the Object
        Object *obj;
        obj = [Object alloc];
        obj = [obj init];
    
        // Create Objects random X axis position
        /*  EXPLANED
            A random point anywhere from 0 to Screen width - (Objects width (IPhone & Ipad optimized))
        */
        int screenWidth = [[UIScreen mainScreen] bounds].size.width;
        int posX = arc4random() % (screenWidth - ((int)(40 * Ratio)));
    
        // Create Objects random Y axis position
        /*  EXPLANED
            A Point Just above the top of the screen (Out of view)
        */
        int posY = (-40 * Ratio);
    
        // Add the Object to the Subview
        [self.view insertSubview: [obj createObj:posX posy:posY]belowSubview:Flash ];

        // Add the Object Array of Objects
        [ObjectArray addObject:obj];
    }
}


//---- Update Objects ----
-(void)updateObj{
    
    // Loop through all the objects in the Object Array
    for (int i=0;i<[ObjectArray count];i++){
        
        // Get the current Object
        Object *obj = [ObjectArray objectAtIndex:i];
        
        // Update the Object's position (Current Position Plus Speed)
        obj.frame = [obj updateObj:(CGRect)Floor.frame];
        
        
        //-- Object collides with the Floor
        /*
            (1) Stop the object, (2) Add points, (3) Fade out & Remove
        */
        if (CGRectIntersectsRect(obj.frame, Floor.frame)) {
            
            //-- If the Object is a Normal object
            if (obj.Type ==1){
                
                // Decrease score/update the score Label
                Points = Points - 2;
                [self addToScore:ScoreLabel];
            }
            
            // Stop the Object Moving
            obj.Vely = 0;
            
            // Stop the Object Rotating
            /*  EXPLANED
                Gets the rotating animation's current angle applied to the Object
                And applies it to the Object, then removes the animation
            */
            CALayer *currentLayer = (CALayer *)[obj.layer presentationLayer];
            float currentAngle = [(NSNumber *)[currentLayer valueForKeyPath:@"transform.rotation.z"] floatValue];
            obj.transform = CGAffineTransformMakeRotation(currentAngle);
            [obj.layer removeAnimationForKey:@"Rotate"];
            
            // Fade out aniamtion & Object removal on completion
            [UIView animateWithDuration:2.5
                animations:^{obj.alpha = 0;
                }completion:^(BOOL finished){
                    [obj removeFromSuperview];
            }];
            
            // Remove Object from array (Its no longer needed)
            [ObjectArray removeObjectAtIndex:i];
        }
    }
}



// ###  User Interaction  ###



// ---- User Taps ----
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
/*   EXPLANED
     If the User Taps the screen do the following:
     
     - (A) Check for Collisions with Objects
           (1) With Normal Object -> Add Points/Remove
     
     - (B) Check If user is in |Game Over| or |Main Menu| phase
*/

    // -- (A)
    if ([player isPlaying]){
    // Saves the users tap position
    CGPoint p = [[touches anyObject] locationInView:self.view];
    
    // Loop through all the objects in the Object Array
    for (int i=0;i<[ObjectArray count];i++){
        
        // Get the current Object
        Object *obj = [ObjectArray objectAtIndex:i];
        
        // Create a frame slightly larger then the Object to use for collision detection
        /*  EXPLANED
            This improves touch recognition in this App Template as we are using
            Pure Objective-C for learning purposes. No Game engines.
         
                             -Collision-
                            |   -----   |
                            |  | OBJ |  |
                            |  |     |  |
                            |   -----   |
                             ----Box----
        */
        CGRect frame = obj.frame;
        frame = CGRectMake(frame.origin.x - (7.5 * Ratio), frame.origin.y - (7.5 * Ratio), frame.size.width + (15 * Ratio), frame.size.height + (15 * Ratio));
        
        //-- If users Tap is inside the collision box, we have contact!
        if (CGRectContainsPoint(frame, p)){
    
            //-- (1) If Object is Type 1 (Normal Object)
            if (obj.Type ==1){
                
                // Play Tap Sound
                [self PlaySound:@"Tap"];
                
                // Increase Score/Update Score Label
                Points = Points + 5;
                [self addToScore:ScoreLabel];
                
                // Create Tap Animation  () ( ) (  )
                [self TapAnimation:obj.frame.origin.x and:obj.frame.origin.y];
        
                // Remove the Object from the Object Array (Not Needed)
                [ObjectArray removeObjectAtIndex:i];
                
                // Remove the Object from the View
                [obj removeFromSuperview];
                
            }
        }
    }
    
    // -- (B)
    
    //-- If User is in |Game Over| Phase Change to |Main Menu|
    if (Phase == 3){
        
        Phase = 2;
        [self phases];
        
    //-- If User is in |Main Menu| Phase Change to |Start Game|
    }else if (Phase == 2){
        
        Phase = 0;
        [self phases];
    }
    }
}



// ###  UI  ###



// ---- UI - Game Over ----
-(void)gameOver{
/*  EXPLANED
    Ends the Game by:
     
    (1) Flash Screen/Shake Screen
    (2) Play Breif UI Aniamtion
    (3) Reset Varibles
    (4) Save Best Score/play sound
*/
    
    // -- (1)
    
    // Remove Prevouis Animations
    [Brief.layer removeAllAnimations];
    
    // Flash the screen
    [self screenFlash];
    
    // Shake the screen
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
    [shake setDuration:0.1];
    [shake setRepeatCount:2];
    [shake setAutoreverses:YES];
    [shake setFromValue:[NSValue valueWithCGPoint:
                         CGPointMake(self.view.center.x - 5,self.view.center.y)]];
    [shake setToValue:[NSValue valueWithCGPoint:
                       CGPointMake(self.view.center.x + 5, self.view.center.y)]];
    [self.view.layer addAnimation:shake forKey:@"position"];
    
    // -- (2)
    
    // Move Brief UI to starting Position (Offscreen)
    Brief.frame = CGRectMake(Brief.frame.origin.x,-Brief.frame.size.height, Brief.frame.size.width, Brief.frame.size.height);
    Brief.image = [UIImage imageNamed:@"UI_Gameover.png"];
    
    // Disable user Taps (Stop quick, unexpected game restart)
    self.view.userInteractionEnabled = true;
    
    // Animate Onscreen - On Completion set Phase, Enable user interaction
    [UIView animateWithDuration:0.5
                     animations:^{
        Brief.frame = CGRectMake(Brief.frame.origin.x,(screenSize.width/2)-(Brief.frame.size.height/2), Brief.frame.size.width, Brief.frame.size.height);
    }completion:^(BOOL finished){
        [Brief.layer removeAllAnimations];
        Phase = 3;
        self.view.userInteractionEnabled = true;
     }];
    
    // -- (3)
    
    // Reset Varibles
    [gameTimer invalidate];
    [gameOverTimer invalidate];
        GameTimeCount = 0;
    
    // -- (4)
    
    //Load BestScores
    int BestScore = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"BestScore"];
    
    // Check to see if there was a new highscore & if there was display it
    if (BestScore < (Points)){
        
        Brief.image = [UIImage imageNamed:@"UI_HighScore.png"];
        
        // Play HighScore Sound
        [self PlaySound:@"Highscore"];
        
        // Display and save the new best score
        [[NSUserDefaults standardUserDefaults] setInteger:Points forKey:@"BestScore"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // Report the new Highscore to Game Center if Enabled
        if ([self.Settings.GameCenterEnabled intValue] == 1) [self reportScore:Points forLeaderboardID:@""];
    }else{
        
        // Play Sound
        [self PlaySound:@"Die"];
    }
    
    //ADMOB !__!#@$)@#($!@#$)_~~~~
    
    
    admob++;
    if(admob  % 2 == 0){
        if ([self.interstitial isReady]) {
            [self.interstitial presentFromRootViewController:self];
        }
    }
    
}


//---- UI - Load Animations ----
-(void)callBreifUI{
    /*  EXPLANED
        Calls the Breif Animation:
     
        (1) Animate Brief UI
     */

    // -- (1)
    
    // Move Brief UI to starting Position (Offscreen)
    Brief.frame = CGRectMake(Brief.frame.origin.x,-Brief.frame.size.height, Brief.frame.size.width, Brief.frame.size.height);
    
    // Animate Onscreen - Removes after 2 Seconds
    [UIView animateWithDuration:0.5
                     animations:^{
        Brief.frame = CGRectMake(Brief.frame.origin.x,(screenSize.width/2)-(Brief.frame.size.height/2), Brief.frame.size.width, Brief.frame.size.height);
    }completion:^(BOOL finished){
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            // Animate Offscreen
            [UIView animateWithDuration:0.5
                    animations:^{
                        Brief.frame = CGRectMake(Brief.frame.origin.x,-Brief.frame.size.height, Brief.frame.size.width, Brief.frame.size.height);
            }];
            
        });
    }];
}


//---- UI - Flash Screen ----
-(void)screenFlash{
    
    // Flash the screen
    [UIView animateWithDuration:0.25
                 animations:^{Flash.alpha = 1.0;
                 }completion:^(BOOL finished){
                     [UIView animateWithDuration:0.25
                                      animations:^{Flash.alpha = 0;
                                      }];
    }];
}



// ###  Misc  ###



//---- Misc - Add Tap Animation ----
-(void)TapAnimation:(int)x and :(int)y{
    
    // Create the Tap ImageView
    UIImageView *Tap = [[UIImageView alloc]initWithFrame:CGRectMake(x, y + 20, 40 * Ratio, 40 * Ratio)];
    
    // Add the Tap Imageview to the View
    [self.view addSubview:Tap];
    
    // ALoad the Tap Animation
    [self load_Animation:Tap filename:@"Tap_" frames:[self.Settings.SplashFrames intValue] duration:[self.Settings.SplashDur floatValue] repeat:FALSE];
    
    // Remove the Tap ImageView on completion
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, [self.Settings.SplashDur floatValue] * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [Tap removeFromSuperview];
    });
}


//---- Misc - Load Animations ----
-(void)load_Animation:(UIImageView*) img filename:(NSString*)filename frames:(int)frames duration:(float)dur repeat:(BOOL)repeat{
    
    // Create an Array to Hold image frames
    NSMutableArray *Images = [[NSMutableArray alloc]init];
    
    // Add the frames to the Array
    for (int i = 0;i < frames;i++){
        [Images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%@%d.png", filename, (i+1)]]];
    }
    
    // Set up the animation properties
    img.animationImages = Images;
    img.animationDuration = dur;
    
    if (repeat){
        img.animationRepeatCount = HUGE_VAL;
    }else{
        img.animationRepeatCount = 1;
    }
    
    // Start the Animation
    [img startAnimating];
}


//---- Misc - Remove Objects ----
-(void)removeObjects{
/*   
    Loop through all the objects and remove them from the Array and view
*/
    
    for (int i=0;i<[ObjectArray count];i++){
        Object *obj = [ObjectArray objectAtIndex:i];
        [obj removeFromSuperview];
    }
    [ObjectArray removeAllObjects];
}


//---- Misc - Handle Score Label animation ----
-(void)addToScore:(UILabel*)label{
    
    // Dont Let the score equal less then 0
    if (Points < 0) Points = 0;
    
    // Update Score Label
    ScoreLabel.text = [NSString stringWithFormat:@"%d", Points];
    
    //-- If score animation is not already Playing
    if (ScoreAnimation == FALSE){
        
        [UIView animateWithDuration:.15                                     animations:^{
            ScoreAnimation = TRUE;
            
        // Block 1 : Label bounces up
            label.frame = CGRectMake(label.frame.origin.x,label.frame.origin.y-7.5,label.frame.size.width,label.frame.size.height);
            
        }completion:^(BOOL finished){

        // Block 2 : Label bounces down
            [UIView animateWithDuration:.05                                     animations:^{
                label.frame = CGRectMake(label.frame.origin.x,label.frame.origin.y+7.5,label.frame.size.width,label.frame.size.height);
            }completion:^(BOOL finished){
                ScoreAnimation = FALSE;
            }];
        }];
    }
}


//---- Misc - Play sounds ----
-(void)PlaySound:(NSString*)Type{
    
    // Play Die the Sound
    SystemSoundID sound_letter;
    
    NSString *soundString = [[NSBundle mainBundle]
                             pathForResource:Type ofType:@"wav"];

    if (soundString!=nil){
        NSURL *soundUrl = [NSURL fileURLWithPath:soundString];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)(soundUrl), &sound_letter);
        AudioServicesPlaySystemSound(sound_letter);
    }
}


//---- Misc - Set up the Audio Player ----
-(void)InitAudioPlayer{
    
    // Initiate Background Music
    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    resourcePath = [resourcePath stringByAppendingString:@"/BackgroundMusic.mp3"];
    NSError* err;
    
    // Initialize our Audio player pointing to the path to our resource
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:
              [NSURL fileURLWithPath:resourcePath] error:&err];
    
    // set our delegate and begin playback
    player.delegate = self;
    player.numberOfLoops = -1;
    player.currentTime = 0;
    player.volume = 1.0;
    
    // Set up a background thread to play the Audio (more efficient)
    playQueue = dispatch_queue_create("com.example.playqueue", NULL);
    
    // Start playing
    dispatch_async(playQueue, ^{
        [player play];
    });
}


//---- Play/Pause the Game Music ----
- (IBAction)PlayerPause:(id)sender {
    
    if ([player isPlaying]){
        
        for (int i=0;i<[ObjectArray count];i++){
            Object *obj = [ObjectArray objectAtIndex:i];
            [obj.layer removeAllAnimations];
        }
        [objTimer invalidate];
        [gameTimer invalidate];
        [gameOverTimer invalidate];
        
        [player pause];
        [MusicButton setImage:[UIImage imageNamed:@"Button_Music_2.png"] forState:UIControlStateNormal];
    }else{
        
        objTimer = [NSTimer scheduledTimerWithTimeInterval:(.009) target:self selector:@selector(updateObj) userInfo:nil repeats:YES];
        
        gameOverTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                         target:self
                                                       selector:@selector(gameProgress)
                                                       userInfo:nil
                                                        repeats:YES];
        
        gameTimer = [NSTimer scheduledTimerWithTimeInterval:(.75) target:self selector:@selector(createObj) userInfo:nil repeats:YES];
        
        [player play];
        [MusicButton setImage:[UIImage imageNamed:@"Button_Music_1.png"] forState:UIControlStateNormal];
    }

}


//---- Set Up Game Fonts ----
- (void)prepareFonts{
    
    //-- If IPhone
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        
        // Set Device Ratio
        Ratio = 1;
        
        // Set up the font
        ScoreLabel.font = [UIFont fontWithName:self.Settings.FontName size:[self.Settings.FontSize intValue]];
        GameTimerLabel.font = [UIFont fontWithName:self.Settings.FontName size:[self.Settings.FontSizeTime intValue]];
        
    //-- If IPad
    }else{
        
        // Set Device Ratio
        Ratio = 2;
        
        // Set up the font
        ScoreLabel.font = [UIFont fontWithName:self.Settings.FontName size:([self.Settings.FontSize intValue]*2)];
        GameTimerLabel.font = [UIFont fontWithName:self.Settings.FontName size:([self.Settings.FontSizeTime intValue]*2)];
        
    }
}



//    ## Game Center  ##



//---- Authenticating Player ----
-(void)AuthPlayer{
    
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    if (localPlayer.authenticated == NO) {
        
        localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
            if (viewController != nil) {
                NSLog(@"Please Sign In ");
                [self presentViewController:viewController animated:YES completion:^{
                }];
            } else if ([GKLocalPlayer localPlayer].isAuthenticated) {
                NSLog(@"Player Authenticated");
            } else if (error != nil) {
                NSLog(@"Authentication Failed, %ld", (long)[error code]);
                NSLog(@"Please note under IOS 7 & 8 you may need to log out off your game center account and log back in using the game center app if you have cancelled the game center prompt over 3 times");
            }
        };
    } else {
        NSLog(@"Already authenticated!");
    }
}


//---- Report score ----
- (void) reportScore: (int64_t) score forLeaderboardID: (NSString*) category
{
/*
    Report users Score to the Game Center Leaderboard
*/
    GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:self.Settings.LeaderboardId];
    scoreReporter.value = score;
    scoreReporter.context = 0;
    
    NSArray *scores = @[scoreReporter];
    [GKScore reportScores:scores withCompletionHandler:^(NSError *error) {
    }];

}


//---- Game Center Button Pressed ----
- (IBAction)ShowGameCenterButtonPressed:(id)sender {
/*
    If the user is Logged into Game Center show Leaderboard
    Otherwise a UIMessage Alert
 */
    // Not Signed In
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"You must enable Game Center!"
                                                          message:@"Sign in through the Game Center app to enable all features"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
        
    // Signed In
    } else {
        GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
        if (gameCenterController != nil)
        {
            gameCenterController.gameCenterDelegate = self;
            gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
            vc = self.view.window.rootViewController;
            [vc presentViewController: gameCenterController animated: YES completion:nil];
        }
    }
}


//---- Game Center Return Button Pressed ----
- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController*)gameCenterViewController {
/*
    Remove Game Center Leaderboard
*/
    
    [vc.view.superview removeFromSuperview];
    [vc dismissViewControllerAnimated:YES completion:nil];
}



//    ##  Social  ##



//---- Appstore Rate Button ----
- (IBAction)ButtonRate:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat: @"itms-apps://itunes.apple.com/app/id%@", self.Settings.AppId]]];
}


//---- Facebook Posting ----
- (IBAction)PostToFb:(id)sender {
/* 
    Load the Best Score & Display Message
*/
    int BestScore = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"BestScore"];

    SLComposeViewController *fbSheetOBJ = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [fbSheetOBJ setInitialText:[NSString stringWithFormat:self.Settings.SocialMessage, BestScore]];
    [self presentViewController:fbSheetOBJ animated:YES completion:Nil];
}


//---- Twitter Posting ----
- (IBAction)PostToTwitter:(id)sender {
/*
    Load the Best Score & Display Message
*/
    int BestScore = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"BestScore"];
    
    SLComposeViewController *tweetSheetOBJ = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [tweetSheetOBJ setInitialText:[NSString stringWithFormat:self.Settings.SocialMessage, BestScore]];
    [self presentViewController:tweetSheetOBJ animated:YES completion:nil];
}



// Hide the Status Bar
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
