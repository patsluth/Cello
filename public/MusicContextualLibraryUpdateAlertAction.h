
#import "MusicContextualAlertAction.h"





@interface MusicContextualLibraryUpdateAlertAction : MusicContextualAlertAction
{
}

@property (nonatomic,readonly) BOOL isAddAction;
@property (nonatomic,readonly) BOOL isDeleteLibraryUpdate;
@property (nonatomic,readonly) BOOL isKeepLocalAction;

+ (void)getContextualLibraryAddRemoveAction:(id*)arg1
                           keepLocalAction:(id*)arg2
                     forEntityValueContext:(id)arg3
                overrideItemEntityProvider:(id)arg4
                      shouldDismissHandler:(/*^block*/id)arg5
             additionalPresentationHandler:(/*^block*/id)arg6
                         didDismissHandler:(/*^block*/id)arg7;

+ (id)notificationTokenForOverrideItemEntityProvider:(id)arg1 queue:(id)arg2 usingBlock:(/*^block*/id)arg3;
+ (void)_showDeleteConfirmationActionAlertControllerWithTitle:(id)arg1
                                            deleteActionTitle:(id)arg2
                                additionalPresentationHandler:(/*^block*/id)arg3
                                              deletionHandler:(/*^block*/id)arg4
                                            didDismissHandler:(/*^block*/id)arg5;

@end




