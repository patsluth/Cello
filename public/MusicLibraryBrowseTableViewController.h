
#import "SWCelloMediaEntityPreviewViewController.h"

@class MusicLibraryViewConfiguration, MusicMediaDetailViewController, MusicEntityValueContext;

typedef enum {
    UpNextAlertAction_PlayNext = 0,
    UpNextAlertAction_AddToUpNext = 1
} UpNextAlertAction_Type;





@interface MusicLibraryBrowseTableViewController : UITableViewController <UIViewControllerPreviewingDelegate>
{
}

@property (nonatomic,readonly) MusicLibraryViewConfiguration *libraryViewConfiguration;

@property (strong, nonatomic) /*MusicClientContext*/ id clientContext;
@property (strong, nonatomic) /*MusicTableView*/ UITableView *tableView;

- (id)initWithLibraryViewConfiguration:(MusicLibraryViewConfiguration *)arg1;

- (id)_entityValueContextAtIndexPath:(id)arg1;
- (void)_configureEntityValueContextOutput:(id)arg1 forIndexPath:(id)arg2;


- (UIViewController *)cello_previewingContext:(id<UIViewControllerPreviewing>)previewingContext
                    viewControllerForLocation:(CGPoint)location;
- (void)cello_previewingContext:(id<UIViewControllerPreviewing>)previewingContext
           commitViewController:(UIViewController *)viewControllerToCommit;

// initilize and return the correct view controller for specified MusicEntityValueContext
- (UIViewController<SWCelloMediaEntityPreviewViewController> *)cello_previewViewControllerForEntityValueContext:(MusicEntityValueContext *)valueContext;

// handles configuring required fields
- (id)cello_entityValueContextAtIndexPath:(NSIndexPath *)indexPath;

//actions
- (void)cello_performShowInStoreActionForIndexPath:(NSIndexPath *)indexPath;
- (void)cello_performStartStationActionForIndexPath:(NSIndexPath *)indexPath;
- (void)cello_performUpNextAction:(UpNextAlertAction_Type)actionType forIndexPath:(NSIndexPath *)indexPath;
- (void)cello_performAddToPlaylistActionForIndexPath:(NSIndexPath *)indexPath;
- (void)cello_performDownloadActionForIndexPath:(NSIndexPath *)indexPath;
- (void)cello_performRemoveFromPlaylistActionForIndexPath:(NSIndexPath *)indexPath;
- (void)cello_performDeleteFromLibraryActionForValueContext:(MusicEntityValueContext *)valueContext;
- (UIAlertController *)cello_deleteConfirmationAlertController:(NSIndexPath *)indexPath;

@end


