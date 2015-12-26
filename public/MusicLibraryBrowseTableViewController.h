
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


- (UIViewController *)cello_previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location;
// handles configuring required fields
- (id)cello_entityValueContextAtIndexPath:(NSIndexPath *)indexPath;
// initilize and return the correct view controller for specified MusicEntityValueContext
- (UIViewController<SWCelloMediaEntityPreviewViewController> *)cello_previewViewControllerForEntityValueContext:(MusicEntityValueContext *)valueContext;

- (void)cello_performShowInStoreActionForValueContext:(MusicEntityValueContext *)valueContext;
- (void)cello_performStartStationActionForValueContext:(MusicEntityValueContext *)valueContext;
- (void)cello_performUpNextAction:(UpNextAlertAction_Type)actionType forValueContext:(MusicEntityValueContext *)valueContext;
- (void)cello_performAddToPlaylistActionForValueContext:(MusicEntityValueContext *)valueContext;
- (void)cello_performDownloadActionForValueContext:(MusicEntityValueContext *)valueContext;
- (void)cello_performRemoveFromPlaylistActionForValueContext:(MusicEntityValueContext *)valueContext;
- (UIAlertController *)cello_deleteConfirmationAlertController:(NSIndexPath *)indexPath;

@end


