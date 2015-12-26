
@class UIAlertAction;





@interface MusicContextualAlertAction : UIAlertAction
{
}

@property (nonatomic,copy,readonly) id contextualHandler;
@property (nonatomic,copy,readonly) id contextualShouldDismissHandler;

+ (id)_actionWithTitle:(id)arg1
       descriptiveText:(id)arg2
                image:(id)arg3 style:(long long)arg4
              handler:(/*^block*/id)arg5
  shouldDismissHandler:(/*^block*/id)arg6;

- (BOOL)performShouldDismiss;
- (void)performContextualAction;
- (id)contextualHandler;
- (id)contextualShouldDismissHandler;

@end




