
#import "SWCelloMediaEntityPreviewViewController.h"
#import "MusicLibraryBrowseCollectionViewConfiguration.h"
//TODO: CONSOLIDATE (THIS IS FOR UPNEXTACTIONTYPE)
#import "MusicLibraryBrowseTableViewController.h"

@class SWCelloPrefs;
@class MusicEntityValueContext;





@interface MusicLibraryBrowseCollectionViewController : UICollectionViewController <UIViewControllerPreviewingDelegate>
{
}

@property (nonatomic,readonly) MusicLibraryBrowseCollectionViewConfiguration *libraryViewConfiguration;

@property (nonatomic,retain) /*SKUIClientContext **/ id clientContext;
@property (nonatomic,readonly) UICollectionViewFlowLayout *collectionViewFlowLayout;
@property (strong, nonatomic) SWCelloPrefs *celloPrefs;

- (id)_entityValueContextAtIndexPath:(id)arg1;
- (id)_sectionEntityValueContextForIndex:(unsigned long long)arg1;
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




