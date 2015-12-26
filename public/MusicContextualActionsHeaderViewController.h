
#import "SWCelloMediaEntityPreviewViewController.h"

@class MusicEntityValueContext;





@interface MusicContextualActionsHeaderViewController : UIViewController <SWCelloMediaEntityPreviewViewController>
{
    //MusicContextualActionsHeaderLockupView* _lockupView;
}

@property (nonatomic, readonly) MusicEntityValueContext *entityValueContext;

- (id)initWithEntityValueContext:(id)arg1 contextualActions:(id)arg2;

@end




