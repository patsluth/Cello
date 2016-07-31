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

#pragma mark - Init

- (id)init
{
	NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/CelloPrefs.bundle"];
	NSString *preferencePath = @"/var/mobile/Library/Preferences/com.patsluth.cello.plist";
	NSString *defaultsPath = [bundle pathForResource:@"prefsDefaults" ofType:@".plist"];
	
	self = [super initWithPreferenceFilePath:preferencePath
								defaultsPath:defaultsPath
								 application:@"com.patsluth.cello"];
	
	if (self) {
	}
	
	return self;
}

- (void)initialize
{
	self.popActionType = SWCello_ActionType_PushViewController;
	
	self.contextualActionsPeek = @[];
	self.contextualActionsSlide = @[];
}

#pragma mark - SWPrefs

- (void)refreshPrefs
{
	[super refreshPrefs];
	
    self.popActionType = (SWCello_ActionType)[[self.preferences valueForKey:@"cello_popaction_type"] integerValue];
    
    
    NSDictionary *peekPrefs = [self.preferences valueForKey:@"cello_contextual_actions_peek"];
    self.contextualActionsPeek = [peekPrefs valueForKey:@"enabled"];
    
    
    NSDictionary *slidePrefs = [self.preferences valueForKey:@"cello_contextual_actions_slide"];
    self.contextualActionsSlide = [slidePrefs valueForKey:@"enabled"];
    
}

@end




