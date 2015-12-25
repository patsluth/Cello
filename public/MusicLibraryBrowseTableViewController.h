
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

// handles configuring required fields
- (id)cello_entityValueContextAtIndexPath:(NSIndexPath *)indexPath;
// initilize and return the correct view controller for specified MusicEntityValueContext
- (MusicMediaDetailViewController *)cello_previewViewControllerForEntityValueContext:(MusicEntityValueContext *)entityValueContext;
- (void)cello_performUpNextAction:(UpNextAlertAction_Type)actionType forIndexPath:(NSIndexPath *)indexPath;
- (void)cello_performDownloadActionForIndexPath:(NSIndexPath *)indexPath;
- (void)cello_performRemoveFromPlaylistActionForIndexPath:(NSIndexPath *)indexPath;
- (UIAlertController *)cello_deleteConfirmationAlertController:(NSIndexPath *)indexPath;

@end


