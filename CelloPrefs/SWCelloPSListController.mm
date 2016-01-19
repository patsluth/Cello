//
//  SWCelloPSListController.mm
//  CelloPrefs
//
//  Created by Pat Sluth on 2015-04-25.
//
//

#import <Preferences/Preferences.h>

#import "libsw/libSluthware/libSluthware.h"
#import "libsw/SWPSListController.h"





@interface SWCelloPSListController : SWPSListController
{
}

@end





@implementation SWCelloPSListController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadSpecifiers];
}

- (void)resetAllSettings:(PSSpecifier *)specifier
{
    NSString *prefsDefaultsPath = [self.bundle pathForResource:@"prefsDefaults" ofType:@".plist"];
    NSString *prefsPath = @"/User/Library/Preferences/com.patsluth.cello.plist";
    
    NSDictionary *prefsDefaults = [NSDictionary dictionaryWithContentsOfFile:prefsDefaultsPath];
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithDictionary:[NSDictionary dictionaryWithContentsOfFile:prefsPath]];
    
    for (NSString *key in prefsDefaults) {
        
        [prefs setValue:[prefsDefaults valueForKey:key] forKey:key];
        CFPreferencesSetAppValue((__bridge CFStringRef)key,
                                 (__bridge CFPropertyListRef)[prefsDefaults valueForKey:key],
                                 CFSTR("com.patsluth.cello"));
        
    }
    
    // syncronize so we can read right away
    [prefs writeToFile:prefsPath atomically:YES];
    CFPreferencesAppSynchronize(CFSTR("com.patsluth.cello"));
    
    [self reloadSpecifiers];
}

@end




