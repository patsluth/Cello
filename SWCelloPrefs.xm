//
//  SWCelloPrefs.m
//  Cello
//
//  Created by Pat Sluth on 2015-12-27.
//
//

#import "SWCelloPrefs.h"




@interface SWCelloPrefs()
{
}

@property (nonatomic, readwrite) SWCello_ActionType popActionType;

@property (strong, nonatomic, readwrite) NSArray *contextualActionsPeek;
@property (strong, nonatomic, readwrite) NSArray *contextualActionsSlide;
//@property (strong, nonatomic, readwrite) NSArray *contextualActionsSlideLeft;
//@property (strong, nonatomic, readwrite) NSArray *contextualActionsSlideRight;

@end





@implementation SWCelloPrefs

- (id)init
{
    self = [super init];
    
    if (self) {
        [self refreshPrefs];
    }
    
    return self;
}

- (void)refreshPrefs
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.patsluth.cello.plist"];
    
    
    self.popActionType = (SWCello_ActionType)[[prefs valueForKey:@"cello_popaction_type"] integerValue];
    
    
    NSDictionary *peekPrefs = [prefs valueForKey:@"cello_contextual_actions_peek"];
    self.contextualActionsPeek = [peekPrefs valueForKey:@"enabled"];
    
    
    NSDictionary *slidePrefs = [prefs valueForKey:@"cello_contextual_actions_slide"];
    self.contextualActionsSlide = [slidePrefs valueForKey:@"enabled"];
    
}

@end




%ctor //syncronize cello default prefs
{
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/CelloPrefs.bundle"];
    
    NSString *prefsDefaultsPath = [bundle pathForResource:@"prefsDefaults" ofType:@".plist"];
    NSString *prefsPath = @"/User/Library/Preferences/com.patsluth.cello.plist";
    
    NSDictionary *prefsDefaults = [NSDictionary dictionaryWithContentsOfFile:prefsDefaultsPath];
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithDictionary:[NSDictionary dictionaryWithContentsOfFile:prefsPath]];
    
    for (NSString *key in prefsDefaults) {
        
        if ([prefs valueForKey:key] == nil) { // update value, dont overwrite
            
            [prefs setValue:[prefsDefaults valueForKey:key] forKey:key];
            CFPreferencesSetAppValue((__bridge CFStringRef)key,
                                     (__bridge CFPropertyListRef)[prefsDefaults valueForKey:key],
                                     CFSTR("com.patsluth.cello"));
            
        }
        
    }
    
    // syncronize so we can read right away
    [prefs writeToFile:prefsPath atomically:NO];
    CFPreferencesAppSynchronize(CFSTR("com.patsluth.cello"));
}




