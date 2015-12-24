
@class MusicViewControllerPresenter, MusicEntityValueContext;





@interface MusicContextualActionsConfiguration : NSObject
{
}

@property (nonatomic, retain) MusicEntityValueContext *entityValueContext;
@property (nonatomic, readonly) MusicViewControllerPresenter *presenter;


+ (id)defaultEntityValueContext;

- (void)configureWithPresentationViewController:(id)arg1 popoverTarget:(id)arg2;
- (id)newViewController;

- (void)_didSelectHeaderFromAlertController:(id)arg1;



@end




