//
//  SWCelloPrefs.h
//  Cello
//
//  Created by Pat Sluth on 2015-12-27.
//
//

#import "SWCello.h"





@interface SWCelloPrefs : NSObject
{
}

@property (nonatomic, readonly) SWCello_ActionType popActionType;

@property (nonatomic, readonly) BOOL showInStore_peek;
@property (nonatomic, readonly) BOOL startRadioStation_peek;
@property (nonatomic, readonly) BOOL upNext_peek;
@property (nonatomic, readonly) BOOL addToPlaylist_peek;
@property (nonatomic, readonly) BOOL makeAvailableOffline_peek;
@property (nonatomic, readonly) BOOL deleteRemove_peek;

@property (nonatomic, readonly) BOOL upNext_slide;
@property (nonatomic, readonly) BOOL makeAvailableOffline_slide;
@property (nonatomic, readonly) BOOL deleteRemove_slide;

- (void)refreshPrefs;

@end




