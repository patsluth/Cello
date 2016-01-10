//
//  SWCelloPrefs.m
//  Cello
//
//  Created by Pat Sluth on 2015-12-27.
//
//

#import "SWCelloPrefs.h"

#define PREFS_DEFAULTS_PATH @"/Library/PreferenceBundles/CelloPrefs.bundle"
#define PREFS_APPLICATION CFSTR("com.apple.Music")




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
    self.popActionType = (SWCello_ActionType)CFPreferencesGetAppIntegerValue(CFSTR("cello_popaction_type"), PREFS_APPLICATION, nil);
    
    
    NSDictionary *peekPrefs = CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("cello_contextual_actions_peek"), PREFS_APPLICATION));
    self.contextualActionsPeek = [peekPrefs valueForKey:@"enabled"];
    
    
    NSDictionary *slidePrefs = CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("cello_contextual_actions_slide"), PREFS_APPLICATION));
    self.contextualActionsSlide = [slidePrefs valueForKey:@"enabled"];
    
}

@end




%ctor //syncronize cello default prefs
{
    NSBundle *bundle = [NSBundle bundleWithPath:PREFS_DEFAULTS_PATH];
    NSDictionary *prefsDefaults = [NSDictionary dictionaryWithContentsOfFile:[bundle pathForResource:@"prefsDefaults" ofType:@".plist"]];
    
    for (NSString *key in prefsDefaults) {
        
        id currentValue = (id)CFBridgingRelease(CFPreferencesCopyAppValue((__bridge CFStringRef)key, PREFS_APPLICATION));
        
        if (currentValue == nil) { //dont overwrite
            CFPreferencesSetAppValue((__bridge CFStringRef)key,
                                     (__bridge CFPropertyListRef)[prefsDefaults valueForKey:key],
                                     PREFS_APPLICATION);
            
        }
        
        
    }
    
    //syncronize so we can read right away
    CFPreferencesAppSynchronize(PREFS_APPLICATION);
    
}




