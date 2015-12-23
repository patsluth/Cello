
@class MusicEntityValueContext;





@interface MusicContextualActionsHeaderViewController : UIViewController
{
    //MusicContextualActionsHeaderLockupView* _lockupView;
}

@property (nonatomic, readonly) MusicEntityValueContext *entityValueContext;

// new
@property (strong, nonatomic) NSArray<id<UIPreviewActionItem>> *celloPreviewActionItems;

- (id)initWithEntityValueContext:(id)arg1 contextualActions:(id)arg2;

@end




