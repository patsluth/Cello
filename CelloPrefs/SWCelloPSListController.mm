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
#import "libsw/SWPSTwitterCell.h"





@interface SWCelloPSListController : SWPSListController
{
}

@end





@implementation SWCelloPSListController

#pragma mark Twitter

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
    [super setPreferenceValue:value specifier:specifier];
    
    NSString *key = specifier.properties[@"key"];
    
    if (key) {
        
        NSString *defaults = specifier.properties[@"defaults"];
        
        if (defaults) {
            
            //update the CFPreferences so we can read them right away
            CFPreferencesSetAppValue((__bridge CFStringRef)key, (__bridge CFPropertyListRef)value, (__bridge CFStringRef)defaults);
            CFPreferencesAppSynchronize((__bridge CFStringRef)defaults);
            
        }
        
    }
}

- (void)viewTwitterProfile:(PSSpecifier *)specifier
{
    [SWPSTwitterCell performActionWithSpecifier:specifier];
}

@end




