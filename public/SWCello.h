//
//  SWCello.h
//  Cello
//
//  Created by Pat Sluth on 2015-12-25.
//
//

#ifndef SWCello_h
#define SWCello_h

typedef enum {
    SWCello_UpNextActionType_PlayNext = 0,
    SWCello_UpNextActionType_AddToUpNext = 1
} SWCello_UpNextActionType;

typedef enum {
    SWCello_ActionType_PushViewController = 0,
    SWCello_ActionType_ShowInStore = 1,
    SWCello_ActionType_StartRadioStation = 2,
    SWCello_ActionType_PlayNext = 3,
    SWCello_ActionType_AddToUpNext = 4,
    SWCello_ActionType_AddToPlaylist = 5,
    SWCello_ActionType_ToggleKeepLocal = 6, // make available offline / remove download
    SWCello_ActionType_Delete = 7
} SWCello_ActionType;

#endif /* SWCello_h */




