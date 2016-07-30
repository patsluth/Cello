//
//  SWCelloDataSource.h
//  Cello
//
//  Created by Pat Sluth on 2015-12-27.
//
//

#import "SWCello.h"

#import "SWCelloMusicLibraryBrowseDelegate.h"
#import "SWCelloMediaEntityPreviewViewController.h"

@class SWCelloPrefs;





@interface SWCelloDataSource : NSObject
{
}

@property (weak, nonatomic, readonly) UIViewController<SWCelloMusicLibraryBrowseDelegate> *delegate;
@property (strong, nonatomic, readonly) SWCelloPrefs *celloPrefs;

- (id)initWithDelegate:(UIViewController<SWCelloMusicLibraryBrowseDelegate> *)delegate;

- (UIViewController<SWCelloMediaEntityPreviewViewController> *)previewViewControllerForIndexPath:(NSIndexPath *)indexPath;
- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
     commitViewController:(UIViewController<SWCelloMediaEntityPreviewViewController> *)viewControllerToCommit;


- (NSArray *)availableActionsForIndexPath:(NSIndexPath *)indexPath;
- (UIPreviewAction *)uipreviewActionForKey:(NSString *)key title:(NSString *)title;

- (void)performShowDetailViewControllerActionForIndexPath:(NSIndexPath *)indexPath;
- (void)performShowInStoreActionForIndexPath:(NSIndexPath *)indexPath;
- (void)performStartStationActionForIndexPath:(NSIndexPath *)indexPath;
- (void)performUpNextAction:(SWCello_UpNextActionType)actionType forIndexPath:(NSIndexPath *)indexPath;
- (void)performAddToPlaylistActionForIndexPath:(NSIndexPath *)indexPath;
- (void)performDownloadActionForIndexPath:(NSIndexPath *)indexPath;
- (void)performRemoveFromPlaylistActionForIndexPath:(NSIndexPath *)indexPath;
- (void)performDeleteFromLibraryActionForValueContext:(MusicEntityValueContext *)valueContext;
- (UIAlertController *)deleteConfirmationAlertControllerForIndexPath:(NSIndexPath *)indexPath;

@end




