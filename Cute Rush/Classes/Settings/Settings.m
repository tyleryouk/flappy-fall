#import "Settings.h"

@implementation Settings

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        
        //--- Edit Settings
        
        self.GameCenterEnabled = [decoder decodeObjectForKey:@"GameCenterEnabled"];
        self.LeaderboardId = [decoder decodeObjectForKey:@"LeaderboardId"];
        self.SocialMessage = [decoder decodeObjectForKey:@"SocialMessageD"];

        self.AppId = [decoder decodeObjectForKey:@"AppId"];
        
        //--- Edit Animations
        
        self.SplashFrames = [decoder decodeObjectForKey:@"SplashFrames"];
        self.SplashDur = [decoder decodeObjectForKey:@"SplashDur"];        
        
        
        //--- Game Customisation
        
        self.GameDuration = [decoder decodeObjectForKey:@"GameDuration"];
        self.RushActive = [decoder decodeObjectForKey:@"RushActive"];

        self.FontName = [decoder decodeObjectForKey:@"FontName"];
        self.FontSize = [decoder decodeObjectForKey:@"FontSize"];
        self.FontSizeTime = [decoder decodeObjectForKey:@"FontSizeTime"];


    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    //--- Edit Settings
    
    [encoder encodeObject:self.GameCenterEnabled forKey:@"GameCenterEnabled"];
    [encoder encodeObject:self.LeaderboardId forKey:@"LeaderboardId"];
    [encoder encodeObject:self.SocialMessage forKey:@"SocialMessageD"];
    
    [encoder encodeObject:self.AppId forKey:@"AppId"];

    //--- Edit Animations
    
    [encoder encodeObject:self.SplashFrames forKey:@"SplashFrames"];
    [encoder encodeObject:self.SplashDur forKey:@"SplashDur"];

     //--- Game Customisation

    [encoder encodeObject:self.GameDuration forKey:@"GameDuration"];
    [encoder encodeObject:self.RushActive forKey:@"RushActive"];
    
    [encoder encodeObject:self.FontName forKey:@"FontName"];
    [encoder encodeObject:self.FontSize forKey:@"FontSize"];
    [encoder encodeObject:self.FontSizeTime forKey:@"FontSizeTime"];
    

}

@end