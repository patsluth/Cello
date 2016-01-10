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
    NSDictionary *prefDefaults = [NSDictionary dictionaryWithContentsOfFile:[self.bundle pathForResource:@"prefsDefaults" ofType:@".plist"]];
    
    for (NSString *key in prefDefaults) {
        
        CFPreferencesSetAppValue((__bridge CFStringRef)key,
                                 (__bridge CFPropertyListRef)[prefDefaults valueForKey:key],
                                 CFSTR("com.apple.Music"));
        
    }
    
    //syncronize so we can read right away
    CFPreferencesAppSynchronize(CFSTR("com.apple.Music"));
    
    [self reloadSpecifiers];
}

@end




