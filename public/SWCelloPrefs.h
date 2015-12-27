//
//  SWCelloPrefs.h
//  Cello
//
//  Created by Pat Sluth on 2015-12-27.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    SWCelloPrefs_ActionType_PushViewController = 0,
    SWCelloPrefs_ActionType_ShowInStore = 1,
    SWCelloPrefs_ActionType_StartRadioStation = 2,
    SWCelloPrefs_ActionType_PlayNext = 3,
    SWCelloPrefs_ActionType_AddToUpNext = 4,
    SWCelloPrefs_ActionType_AddToPlaylist = 5,
    SWCelloPrefs_ActionType_ToggleKeepLocal = 6, // make available offline / remove download
    SWCelloPrefs_ActionType_Delete = 7
} SWCelloPrefs_ActionType;





@interface SWCelloPrefs : NSObject
{
}

@property (nonatomic, readonly) SWCelloPrefs_ActionType popActionType;

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




