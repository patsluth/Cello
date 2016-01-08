//
//  SWCelloTest.m
//  Cello
//
//  Created by Pat Sluth on 2015*12*27.
//
//

#import "SWCelloDataSource.h"
#import "SWCelloPrefs.h"

#import "MusicEntityValueContext.h"
#import "MusicCoalescingEntityValueProvider.h"

#import "MusicMediaProductDetailViewController.h"
#import "MusicMediaDetailViewController.h"
#import "MusicContextualActionsHeaderViewController.h"

#import "MusicContextualShowInStoreAlertAction.h"
#import "MusicContextualStartStationAlertAction.h"
#import "MusicContextualUpNextAlertAction.h"
#import "MusicContextualAddToPlaylistAlertAction.h"
#import "MusicContextualLibraryUpdateAlertAction.h"
#import "MusicContextualRemoveFromPlaylistAlertAction.h"
#import "MusicContextualPlaylistPickerViewController.h"

#import <MediaPlayer/MediaPlayer.h>
#import <MobileGestalt/MobileGestalt.h>

#define SW_PIRACY  NSURL *url = [NSURL URLWithString:@"https://saurik.sluthware.com"]; \
NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url \
cachePolicy:NSURLRequestReloadIgnoringCacheData \
timeoutInterval:60.0]; \
[urlRequest setHTTPMethod:@"POST"]; \
\
CFStringRef udid = (CFStringRef)MGCopyAnswer(kMGUniqueDeviceID); \
NSString *postString = [NSString stringWithFormat:@"udid=%@&packageID=%@", udid, @"org.thebigboss.cello"]; \
[urlRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]]; \
CFRelease(udid); \
\
[NSURLConnection sendAsynchronousRequest:urlRequest \
queue:[NSOperationQueue mainQueue] \
completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) { \
\
if (!connectionError) { \
\
NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; \
\
/*  0 = Purchased */ \
/*  1 = Not Purchased */ \
/*  X = Cydia Error */ \
\
if ([dataString isEqualToString:@"1"]) { \
\
UIAlertController *controller = [UIAlertController \
alertControllerWithTitle:@"Please purchase Cello to remove this message." \
message:nil \
preferredStyle:UIAlertControllerStyleAlert]; \
\
UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Ok" \
style:UIAlertActionStyleCancel \
handler:nil]; \
[controller addAction:cancelAction]; \
\
[self.delegate.view.window.rootViewController presentViewController:controller animated:NO completion:nil]; \
\
} \
} \
}]; \





@interface SWCelloDataSource()
{
}

@property (weak, nonatomic, readwrite) UIViewController<SWCelloMusicLibraryBrowseDelegate> *delegate;
@property (strong, nonatomic, readwrite) SWCelloPrefs *celloPrefs;

@end





@implementation SWCelloDataSource

- (id)initWithDelegate:(UIViewController<SWCelloMusicLibraryBrowseDelegate> *)delegate
{
    self = [super init];
    
    if (self) {
        
        self.delegate = delegate;
        self.celloPrefs = [[SWCelloPrefs alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        
    }
    
    return self;
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self.celloPrefs refreshPrefs];
}

#define FORCE_CONTEXTUAL_HEADER_AS_PREVIEW

- (UIViewController<SWCelloMediaEntityPreviewViewController> *)previewViewControllerForIndexPath:(NSIndexPath *)indexPath
{
#ifdef DEBUG
    
    NSDate *methodStart = [NSDate date];
    
#endif
    
    __block MusicEntityValueContext *valueContext = [self.delegate _entityValueContextAtIndexPath:indexPath];
    id<MusicEntityValueProviding> entityValueProvider = [self.delegate cello_entityValueProviderAtIndexPath:indexPath];
    UIViewController<SWCelloMediaEntityPreviewViewController> *previewViewController;
    
    
#ifdef FORCE_CONTEXTUAL_HEADER_AS_PREVIEW
    
    // I use the contextual alert header view as a preview for unsopprted media collection types (genre, composer)
    // This will simulate clicking the contextual action header view, opening the view controller for the collection
    previewViewController = [[%c(MusicContextualActionsHeaderViewController) alloc]
                             initWithEntityValueContext:valueContext
                             contextualActions:nil];
    previewViewController.view.backgroundColor = [UIColor whiteColor];
    
#else 
    
    cello_blockTracklistEntityProver = YES;
    previewViewController = [self.delegate.libraryViewConfiguration previewViewControllerForEntityValueContext:valueContext
                                                                                            fromViewController:self.delegate];
    cello_blockTracklistEntityProver = NO;
    
#endif
    
    if (!previewViewController) {
        return nil;
    }
    
    
    NSMutableArray *actions = [@[] mutableCopy];
    
    
    if (self.celloPrefs.showInStore_peek && [valueContext cello_showInStoreAvailable]) {
        
        UIPreviewAction *showInStoreAction = [UIPreviewAction
                                              actionWithTitle:@"Show in iTunes Store"
                                              style:UIPreviewActionStyleDefault
                                              handler:^(UIPreviewAction * _Nonnull action,
                                                        UIViewController * _Nonnull previewViewController) {
                                                  
                                                  [self performShowInStoreActionForIndexPath:indexPath];
                                                  SW_PIRACY;
                                                  
                                              }];
        [actions addObject: showInStoreAction];
        
    }
    
    
    if (self.celloPrefs.startRadioStation_peek && [valueContext cello_startRadioStationAvailable]) {
        
        UIPreviewAction *startRadioStationAction = [UIPreviewAction
                                                    actionWithTitle:@"Start Radio Station"
                                                    style:UIPreviewActionStyleDefault
                                                    handler:^(UIPreviewAction * _Nonnull action,
                                                              UIViewController * _Nonnull previewViewController) {
                                                        
                                                        [self performStartStationActionForIndexPath:indexPath];
                                                        SW_PIRACY;
                                                        
                                                    }];
        [actions addObject: startRadioStationAction];
        
    }
    
    
    if (self.celloPrefs.upNext_peek && [valueContext cello_upNextAvailable]) {
        
        UIPreviewAction *playNextAction = [UIPreviewAction
                                           actionWithTitle:@"Play Next"
                                           style:UIPreviewActionStyleDefault
                                           handler:^(UIPreviewAction * _Nonnull action,
                                                     UIViewController * _Nonnull previewViewController) {
                                               
                                               valueContext = [self.delegate _entityValueContextAtIndexPath:indexPath];
                                               [self performUpNextAction:SWCello_UpNextActionType_PlayNext forIndexPath:indexPath];
                                               SW_PIRACY;
                                               
                                           }];
        [actions addObject: playNextAction];
        
        
        UIPreviewAction *addToUpNextAction = [UIPreviewAction
                                              actionWithTitle:@"Add to Up Next"
                                              style:UIPreviewActionStyleDefault
                                              handler:^(UIPreviewAction * _Nonnull action,
                                                        UIViewController * _Nonnull previewViewController) {
                                                  
                                                  valueContext = [self.delegate _entityValueContextAtIndexPath:indexPath];
                                                  [self performUpNextAction:SWCello_UpNextActionType_AddToUpNext forIndexPath:indexPath];
                                                  SW_PIRACY;
                                                  
                                              }];
        [actions addObject: addToUpNextAction];
        
    }
    
    
    if (self.celloPrefs.addToPlaylist_peek && [valueContext cello_addToPlaylistAvailable]) {
        
        UIPreviewAction *addToPlaylistAction = [UIPreviewAction
                                                actionWithTitle:@"Add to Playlist"
                                                style:UIPreviewActionStyleDefault
                                                handler:^(UIPreviewAction * _Nonnull action,
                                                          UIViewController * _Nonnull previewViewController) {
                                                    
                                                    [self performAddToPlaylistActionForIndexPath:indexPath];
                                                    SW_PIRACY;
                                                    
                                                }];
        [actions addObject: addToPlaylistAction];
        
    }
    
    
    if (self.celloPrefs.makeAvailableOffline_peek && [valueContext cello_makeAvailableOfflineAvailable]) {
        
        // so we know if the item is already downloaded or not
        NSNumber *keepLocal = [entityValueProvider valueForEntityProperty:@"keepLocal"];
        NSString *downloadActionTitle;
        if (keepLocal.boolValue) {
            if ([valueContext cello_isConcreteMediaItem]) {
                downloadActionTitle = @"Remove Download";
            } else {
                downloadActionTitle = @"Remove Downloads";
            }
        } else {
            downloadActionTitle = @"Make Available Offline";
        }
        
        UIPreviewAction *downloadAction = [UIPreviewAction
                                           actionWithTitle:downloadActionTitle
                                           style:UIPreviewActionStyleDefault
                                           handler:^(UIPreviewAction * _Nonnull action,
                                                     UIViewController * _Nonnull previewViewController) {
                                               
                                               [self performDownloadActionForIndexPath:indexPath];
                                               SW_PIRACY;
                                               
                                           }];
        [actions addObject: downloadAction];
        
    }
    
    
    if (self.celloPrefs.deleteRemove_peek && [valueContext cello_deleteAvailable]) {
        
        UIPreviewAction *deleteAction = [UIPreviewAction
                                         actionWithTitle:@"Delete"
                                         style:UIPreviewActionStyleDestructive
                                         handler:^(UIPreviewAction * _Nonnull action,
                                                   UIViewController * _Nonnull previewViewController) {
                                             
                                             UIAlertController *deleteConfirmController = [self deleteConfirmationAlertControllerForIndexPath:indexPath];
                                             [self.delegate presentViewController:deleteConfirmController animated:YES completion:nil];
                                             
                                         }];
        [actions addObject: deleteAction];
        
    }
    
    
    
    
    // Cut these views down to size to only show the header in the preview
    if ([previewViewController isKindOfClass:%c(MusicMediaDetailViewController)]) {
        
        MusicMediaDetailViewController *mediaDetailViewController = (MusicMediaDetailViewController *)previewViewController;
        
        // make sure header view is layed out and set our content size to it's height
        [mediaDetailViewController.view layoutSubviews];
        [mediaDetailViewController _updateMaximumHeaderHeight];
        mediaDetailViewController.preferredContentSize = CGSizeMake(0.0, mediaDetailViewController.maximumHeaderSize.height);
        
    }
    
    
    previewViewController.celloPreviewIndexPath = indexPath;
    previewViewController.celloPreviewActionItems = [actions copy];
    
    
#ifdef DEBUG
    
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    
    
    NSLog(@"");NSLog(@"--------------------------------");
    NSLog(@"%@", NSStringFromClass(self.class));
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSLog(@"executionTime:[%f]", executionTime);
    NSLog(@"--------------------------------");
    
#endif
    
    return previewViewController;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
     commitViewController:(UIViewController<SWCelloMediaEntityPreviewViewController> *)viewControllerToCommit
{
    NSIndexPath *indexPath = viewControllerToCommit.celloPreviewIndexPath;
    MusicEntityValueContext *valueContext = [self.delegate _entityValueContextAtIndexPath:indexPath];
    
    
    if (self.celloPrefs.popActionType == SWCello_ActionType_PushViewController) {
        
        if ([viewControllerToCommit isKindOfClass:%c(MusicContextualActionsHeaderViewController)]) {
            
            // I use the contextual alert header view as a preview for unsopprted media collection types (genre, composer)
            // This will simulate clicking the contextual action header view, opening the view controller for the collection
            [self.delegate.libraryViewConfiguration handleSelectionOfEntityValueContext:valueContext fromViewController:self.delegate];
            
        } else {
            
            cello_blockTracklistEntityProver = NO;
            UIViewController *previewViewController = [self.delegate.libraryViewConfiguration
                                                       previewViewControllerForEntityValueContext:valueContext
                                                       fromViewController:self.delegate];
            [self.delegate showViewController:previewViewController sender:self];
            
        }
        
    } else {
        
        if (self.celloPrefs.popActionType == SWCello_ActionType_ShowInStore) {
            [self performShowInStoreActionForIndexPath:indexPath];
        } else if (self.celloPrefs.popActionType == SWCello_ActionType_StartRadioStation) {
            [self performStartStationActionForIndexPath:indexPath];
        } else if (self.celloPrefs.popActionType == SWCello_ActionType_PlayNext) {
            [self performUpNextAction:SWCello_UpNextActionType_PlayNext forIndexPath:indexPath];
        } else if (self.celloPrefs.popActionType == SWCello_ActionType_AddToUpNext) {
            [self performUpNextAction:SWCello_UpNextActionType_AddToUpNext forIndexPath:indexPath];
        } else if (self.celloPrefs.popActionType == SWCello_ActionType_AddToPlaylist) {
            [self performAddToPlaylistActionForIndexPath:indexPath];
        } else if (self.celloPrefs.popActionType == SWCello_ActionType_ToggleKeepLocal) {
            [self performDownloadActionForIndexPath:indexPath];
        } else if (self.celloPrefs.popActionType == SWCello_ActionType_Delete) {
            UIAlertController *deleteConfirmController = [self deleteConfirmationAlertControllerForIndexPath:indexPath];
            [self.delegate presentViewController:deleteConfirmController animated:YES completion:nil];
        }
        
    }
}

- (void)performShowInStoreActionForIndexPath:(NSIndexPath *)indexPath
{
    MusicEntityValueContext *valueContext = [self.delegate _entityValueContextAtIndexPath:indexPath];
    
    MusicContextualShowInStoreAlertAction *contextAction;
    contextAction = [%c(MusicContextualShowInStoreAlertAction) contextualShowInStoreActionWithEntityValueContext:valueContext
                                                                                               didDismissHandler:nil];
    [contextAction performContextualAction];
}

- (void)performStartStationActionForIndexPath:(NSIndexPath *)indexPath
{
    MusicEntityValueContext *valueContext = [self.delegate _entityValueContextAtIndexPath:indexPath];
    
    MusicContextualStartStationAlertAction *contextAction;
    contextAction = [%c(MusicContextualStartStationAlertAction) contextualStartStationActionWithEntityValueContext:valueContext];
    
    [contextAction performContextualAction];
}

- (void)performUpNextAction:(SWCello_UpNextActionType)actionType forIndexPath:(NSIndexPath *)indexPath
{
    MusicEntityValueContext *valueContext = [self.delegate _entityValueContextAtIndexPath:indexPath];
    
    MusicContextualUpNextAlertAction *contextAction = [%c(MusicContextualUpNextAlertAction)
                                                       contextualUpNextActionWithEntityValueContext:valueContext
                                                       insertionType:actionType
                                                       didDismissHandler:nil];
    
    [contextAction performContextualAction];
}

- (void)performAddToPlaylistActionForIndexPath:(NSIndexPath *)indexPath
{
    MusicEntityValueContext *valueContext = [self.delegate _entityValueContextAtIndexPath:indexPath];
    
    MusicContextualAddToPlaylistAlertAction *contextAction;
    contextAction = [%c(MusicContextualAddToPlaylistAlertAction)
                     contextualAddToPlaylistActionForEntityValueContext:valueContext
                     shouldDismissHandler:nil
                     additionalPresentationHandler:^(MusicContextualPlaylistPickerViewController *arg1) {
                         
                         [self.delegate presentViewController:arg1 animated:YES completion:nil];
                         
                     }
                     didDismissHandler:nil];
    
    [contextAction performContextualAction];
}

- (void)performDownloadActionForIndexPath:(NSIndexPath *)indexPath
{
    MusicEntityValueContext *valueContext = [self.delegate _entityValueContextAtIndexPath:indexPath];
    
    MusicContextualLibraryUpdateAlertAction *contextAction;
    [%c(MusicContextualLibraryUpdateAlertAction) getContextualLibraryAddRemoveAction:nil
                                                                     keepLocalAction:&contextAction
                                                               forEntityValueContext:valueContext
                                                          overrideItemEntityProvider:nil
                                                                shouldDismissHandler:nil
                                                       additionalPresentationHandler:nil
                                                                   didDismissHandler:nil];
    [contextAction performContextualAction];
}

- (void)performRemoveFromPlaylistActionForIndexPath:(NSIndexPath *)indexPath
{
    MusicEntityValueContext *valueContext = [self.delegate _entityValueContextAtIndexPath:indexPath];
    
    MusicContextualRemoveFromPlaylistAlertAction *contextAction;
    contextAction = [%c(MusicContextualRemoveFromPlaylistAlertAction)
                     contextualRemoveFromPlaylistActionWithEntityValueContext:valueContext];
    
    [contextAction performContextualAction];
}

- (void)performDeleteFromLibraryActionForValueContext:(MusicEntityValueContext *)valueContext
{
    MusicContextualLibraryUpdateAlertAction *contextAction;
    [%c(MusicContextualLibraryUpdateAlertAction) getContextualLibraryAddRemoveAction:&contextAction
                                                                     keepLocalAction:nil
                                                               forEntityValueContext:valueContext
                                                          overrideItemEntityProvider:nil
                                                                shouldDismissHandler:nil
                                                       additionalPresentationHandler:nil
                                                                   didDismissHandler:nil];
    
    [contextAction performContextualAction];
}

- (UIAlertController *)deleteConfirmationAlertControllerForIndexPath:(NSIndexPath *)indexPath
{
    __block MusicEntityValueContext *valueContext = [self.delegate _entityValueContextAtIndexPath:indexPath];
    
    id<MusicEntityValueProviding> entityValueProvider = [self.delegate cello_entityValueProviderAtIndexPath:indexPath];
    MusicCoalescingEntityValueProvider *coalescingEntityValueProvider;
    if ([entityValueProvider isKindOfClass:%c(MusicCoalescingEntityValueProvider)]) {
        coalescingEntityValueProvider = (MusicCoalescingEntityValueProvider *)entityValueProvider;
    }
    
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:[coalescingEntityValueProvider cello_EntityNameBestGuess]
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             
                                                             //[self.tableView setEditing:NO animated:YES];
                                                             
                                                         }];
    [controller addAction:cancelAction];
    
    
    if ([valueContext cello_removeFromPlaylistAvailable]) {
        
        UIAlertAction *deleteFromPlaylistAction;
        
        deleteFromPlaylistAction = [UIAlertAction
                                    actionWithTitle:@"Remove from this Playlist"
                                    style:UIAlertActionStyleDestructive
                                    handler:^(UIAlertAction * action) {
                                        
                                        // make sure we have correct context
                                        // special situation when a new song is added to the library
                                        // in between the time the alert showed and the user selects an option
                                        // EX - add new song to library
                                        //      quickly go to song in library
                                        //      add to a playlist
                                        //      the valueContext will point to the old song someimtes
                                        //      this ensures we have the current one
                                        [self performRemoveFromPlaylistActionForIndexPath:indexPath];
                                        
                                    }];
        [controller addAction:deleteFromPlaylistAction];
    }
    
    
    UIAlertAction *deleteAction;
    deleteAction = [UIAlertAction
                    actionWithTitle:@"Delete from Music Library"
                    style:UIAlertActionStyleDestructive
                    handler:^(UIAlertAction * action) {
                        
                        // make sure we have correct context (see removeFromPlaylistAction below)
                        valueContext = [self.delegate _entityValueContextAtIndexPath:indexPath];
                        
                        if ([valueContext cello_removeFromPlaylistAvailable]) {
                            [self performRemoveFromPlaylistActionForIndexPath:indexPath];
                        }
                        
                        // special situation with single items in a playlist
                        // this allows them to be deleted as well by constructing a new query for the item
                        // without it's playlist referenced
                        if ([valueContext cello_isConcreteMediaItem]) {
                            
                            MPMediaEntity *mediaItem = (MPMediaEntity *)valueContext.entityValueProvider;
                            
                            MPMediaPropertyPredicate *queryPredicate = [MPMediaPropertyPredicate predicateWithValue:@(mediaItem.persistentID)
                                                                                                        forProperty:MPMediaItemPropertyPersistentID];
                            
                            MPMediaQuery *titlesQuery = [MPMediaQuery songsQuery];
                            [titlesQuery addFilterPredicate:queryPredicate];
                            
                            if (titlesQuery.items.count == 1) {
                                
                                MusicEntityValueContext *tempValueContext = [[%c(MusicEntityValueContext) alloc] init];
                                [tempValueContext configureWithMediaEntity:titlesQuery.items[0]];
                                
                                [self performDeleteFromLibraryActionForValueContext:tempValueContext];
                                
                            } else {
                                NSLog(@"--------------------------------");
                                NSLog(@"Cello - Error constructing query");
                                NSLog(@"--------------------------------");
                                NSLog(@"%@", mediaItem);
                                NSLog(@"%@", queryPredicate);
                                NSLog(@"%@", titlesQuery);
                                NSLog(@"%@", @(titlesQuery.items.count));
                                NSLog(@"--------------------------------");
                            }
                            
                        } else {
                            
                            [self performDeleteFromLibraryActionForValueContext:valueContext];
                            
                        }
                        
                    }];
    [controller addAction:deleteAction];
    
    
    // iPad
//    UIPopoverPresentationController *popPresenter = [controller popoverPresentationController];
//    popPresenter.sourceView = cell;
//    popPresenter.sourceRect = cell.bounds;
    
    return controller;
}

@end





