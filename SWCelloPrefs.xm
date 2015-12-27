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

@property (nonatomic, readwrite) SWCelloPrefs_ActionType popActionType;

@property (nonatomic, readwrite) BOOL showInStore_peek;
@property (nonatomic, readwrite) BOOL startRadioStation_peek;
@property (nonatomic, readwrite) BOOL upNext_peek;
@property (nonatomic, readwrite) BOOL addToPlaylist_peek;
@property (nonatomic, readwrite) BOOL makeAvailableOffline_peek;
@property (nonatomic, readwrite) BOOL deleteRemove_peek;

@property (nonatomic, readwrite) BOOL upNext_slide;
@property (nonatomic, readwrite) BOOL makeAvailableOffline_slide;
@property (nonatomic, readwrite) BOOL deleteRemove_slide;

@end





@implementation SWCelloPrefs

- (id)init
{
    self = [super init];
    
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshPrefs)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        
        [self refreshPrefs];
        
    }
    
    return self;
}

- (void)refreshPrefs
{
    self.popActionType = (SWCelloPrefs_ActionType)CFPreferencesGetAppIntegerValue(CFSTR("cello_popaction_type"), PREFS_APPLICATION, nil);
    
    self.showInStore_peek = CFPreferencesGetAppBooleanValue(CFSTR("cello_showinstore_peek_enabled"), PREFS_APPLICATION, nil);
    self.startRadioStation_peek = CFPreferencesGetAppBooleanValue(CFSTR("cello_startradiostation_peek_enabled"), PREFS_APPLICATION, nil);
    self.upNext_peek = CFPreferencesGetAppBooleanValue(CFSTR("cello_upnext_peek_enabled"), PREFS_APPLICATION, nil);
    self.addToPlaylist_peek = CFPreferencesGetAppBooleanValue(CFSTR("cello_addtoplaylist_peek_enabled"), PREFS_APPLICATION, nil);
    self.makeAvailableOffline_peek = CFPreferencesGetAppBooleanValue(CFSTR("cello_makeavailableoffline_peek_enabled"), PREFS_APPLICATION, nil);
    self.deleteRemove_peek = CFPreferencesGetAppBooleanValue(CFSTR("cello_deleteremove_peek_enabled"), PREFS_APPLICATION, nil);
    
    self.upNext_slide = CFPreferencesGetAppBooleanValue(CFSTR("cello_upnext_slide_enabled"), PREFS_APPLICATION, nil);
    self.makeAvailableOffline_slide = CFPreferencesGetAppBooleanValue(CFSTR("cello_makeavailableoffline_slide_enabled"), PREFS_APPLICATION, nil);
    self.deleteRemove_slide = CFPreferencesGetAppBooleanValue(CFSTR("cello_deleteremove_slide_enabled"), PREFS_APPLICATION, nil);
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




