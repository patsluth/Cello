//
//  SWCelloPSListController.mm
//  CelloPrefs
//
//  Created by Pat Sluth on 2015-04-25.
//
//

#import <Preferences/Preferences.h>

#import "libsw/libSluthware/libSluthware.h"
#import "libsw/libSluthware/SWPrefs.h"
#import "libsw/SWPSListController.h"





@interface SWCelloPSListController : SWPSListController
{
}

@end





@implementation SWCelloPSListController

/**
 *  Lazy Load prefs
 *
 *  @return prefs
 */
- (SWPrefs *)prefs
{
	if (![super prefs]) {
		
		NSString *preferencePath = @"/var/mobile/Library/Preferences/com.patsluth.cello.plist";
		NSString *defaultsPath = [self.bundle pathForResource:@"prefsDefaults" ofType:@".plist"];
		
		self.prefs = [[SWPrefs alloc] initWithPreferenceFilePath:preferencePath
													defaultsPath:defaultsPath
													 application:@"com.patsluth.cello"];
	}
	
	return [super prefs];
}

@end




