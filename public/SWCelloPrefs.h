//
//  SWCelloPrefs.h
//  Cello
//
//  Created by Pat Sluth on 2015-12-27.
//
//

#import "SWCello.h"

#import "libsw/libSluthware/SWPrefs.h"





@interface SWCelloPrefs : SWPrefs
{
}

@property (nonatomic, readonly) SWCello_ActionType popActionType;

@property (strong, nonatomic, readonly) NSArray *contextualActionsPeek;
@property (strong, nonatomic, readonly) NSArray *contextualActionsSlide;
//FUTURE
//@property (strong, nonatomic, readonly) NSArray *contextualActionsSlideLeft;
//@property (strong, nonatomic, readonly) NSArray *contextualActionsSlideRight;

@end




