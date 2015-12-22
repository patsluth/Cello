
#import "MusicContextualAlertAction.h"
@class MPPlaybackContext, MPAVController;





@interface MusicContextualUpNextAlertAction : MusicContextualAlertAction
{
	long long _insertionType;
	MPPlaybackContext* _playbackContext;
	MPAVController* _player;
}

+ (id)contextualUpNextActionWithEntityValueContext:(id)arg1 insertionType:(long long)arg2 didDismissHandler:(/*^block*/id)arg3;
- (void)_handleUpNextAction;

@end




