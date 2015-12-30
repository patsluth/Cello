//
//  MusicLibraryBrowseCollectionViewController.xm
//  Cello
//
//  Created by Pat Sluth on 2015-12-21.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import "SWCelloPrefs.h"
#import "SWCelloMediaEntityPreviewViewController.h"

#import "SWCelloPrefs.h"
#import "SWCelloMediaEntityPreviewViewController.h"

#import "MusicLibraryBrowseCollectionViewController.h"
#import "MusicLibraryBrowseHeterogenousCollectionViewController.h"
#import "MusicLibrarySearchResultsViewController.h"

#import "MusicLibraryBrowseTableViewController.h"
#import "MusicMediaAlbumDetailViewController.h"
#import "MusicProfileAlbumsViewController.h"
#import "MusicMediaProfileDetailViewController.h"
#import "MusicMediaPlaylistDetailViewController.h"

#import "MusicLibraryPlaylistsViewConfiguration.h"

#import "MusicMediaEntityProvider.h"
#import "MusicEntityValueContext.h"
#import "MusicCoalescingEntityValueProvider.h"

#import "MusicContextualActionsHeaderViewController.h"

#import "MusicContextualShowInStoreAlertAction.h"
#import "MusicContextualStartStationAlertAction.h"
#import "MusicContextualUpNextAlertAction.h"
#import "MusicContextualAddToPlaylistAlertAction.h"
#import "MusicContextualLibraryUpdateAlertAction.h"
#import "MusicContextualRemoveFromPlaylistAlertAction.h"
#import "MusicContextualPlaylistPickerViewController.h"


#import <MediaPlayer/MediaPlayer.h>
#import "MPQueryPlaybackContext.h"
#import "MPMediaEntity+SW.h"

#import "SWCelloPrefs.h"





@protocol Cello_MusicEntityCollectionViewCellValueProviding
@required
@property (nonatomic,retain) id<MusicEntityValueProviding> entityValueProvider;
@end





%hook MusicLibrarySearchResultsViewController

// peek
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    return [self cello_previewingContext:previewingContext viewControllerForLocation:location];
}

// pop
- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self cello_previewingContext:previewingContext commitViewController:viewControllerToCommit];
}

%end

%hook MusicLibraryBrowseHeterogenousCollectionViewController

// peek
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    return [self cello_previewingContext:previewingContext viewControllerForLocation:location];
}

// pop
- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self cello_previewingContext:previewingContext commitViewController:viewControllerToCommit];
}

%end

%hook MusicLibraryBrowseCollectionViewController

- (void)viewDidAppear:(BOOL)animated
{
    self.celloPrefs = [[SWCelloPrefs alloc] init];
    
    %orig(animated);
}

- (void)viewWillDisappear:(BOOL)animated
{
    // remove our associated object
    self.celloPrefs = nil;
    
    %orig(animated);
}

// peek
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    return [self cello_previewingContext:previewingContext viewControllerForLocation:location];
}

%new
- (UIViewController *)cello_previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    if (self.presentedViewController) {
        return nil;
    }
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    
    if (!indexPath) {
        return nil;
    }
    
    UICollectionViewCell<Cello_MusicEntityCollectionViewCellValueProviding> *cell;
    cell = (UICollectionViewCell<Cello_MusicEntityCollectionViewCellValueProviding> *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    if (cell) {
        
#ifdef DEBUG
        
        NSDate *methodStart = [NSDate date];
        
#endif
        
        __block MusicEntityValueContext *valueContext = [self cello_entityValueContextAtIndexPath:indexPath];
        NSMutableArray *actions = [@[] mutableCopy];
        
        if (self.celloPrefs.showInStore_peek && [valueContext showInStoreAvailable]) {
            
            UIPreviewAction *showInStoreAction = [UIPreviewAction
                                                  actionWithTitle:@"Show in iTunes Store"
                                                  style:UIPreviewActionStyleDefault
                                                  handler:^(UIPreviewAction * _Nonnull action,
                                                            UIViewController * _Nonnull previewViewController) {
                                                      
                                                      [self cello_performShowInStoreActionForIndexPath:indexPath];
                                                      
                                                  }];
            [actions addObject: showInStoreAction];
            
        }
        
        
        if (self.celloPrefs.startRadioStation_peek && [valueContext startRadioStationAvailable]) {
            
            UIPreviewAction *startRadioStationAction = [UIPreviewAction
                                                        actionWithTitle:@"Start Radio Station"
                                                        style:UIPreviewActionStyleDefault
                                                        handler:^(UIPreviewAction * _Nonnull action,
                                                                  UIViewController * _Nonnull previewViewController) {
                                                            
                                                            [self cello_performStartStationActionForIndexPath:indexPath];
                                                            
                                                        }];
            [actions addObject: startRadioStationAction];
            
        }
        
        
        if (self.celloPrefs.upNext_peek && [valueContext upNextAvailable]) {
            
            UIPreviewAction *playNextAction = [UIPreviewAction
                                               actionWithTitle:@"Play Next"
                                               style:UIPreviewActionStyleDefault
                                               handler:^(UIPreviewAction * _Nonnull action,
                                                         UIViewController * _Nonnull previewViewController) {
                                                   
                                                   valueContext = [self cello_entityValueContextAtIndexPath:indexPath];
                                                   [self cello_performUpNextAction:UpNextAlertAction_PlayNext forIndexPath:indexPath];
                                                   
                                               }];
            [actions addObject: playNextAction];
            
            
            UIPreviewAction *addToUpNextAction = [UIPreviewAction
                                                  actionWithTitle:@"Add to Up Next"
                                                  style:UIPreviewActionStyleDefault
                                                  handler:^(UIPreviewAction * _Nonnull action,
                                                            UIViewController * _Nonnull previewViewController) {
                                                      
                                                      valueContext = [self cello_entityValueContextAtIndexPath:indexPath];
                                                      [self cello_performUpNextAction:UpNextAlertAction_AddToUpNext forIndexPath:indexPath];
                                                      
                                                  }];
            [actions addObject: addToUpNextAction];
            
        }
        
        
        if (self.celloPrefs.addToPlaylist_peek && [valueContext addToPlaylistAvailable]) {
            
            UIPreviewAction *addToPlaylistAction = [UIPreviewAction
                                                    actionWithTitle:@"Add to Playlist"
                                                    style:UIPreviewActionStyleDefault
                                                    handler:^(UIPreviewAction * _Nonnull action,
                                                              UIViewController * _Nonnull previewViewController) {
                                                        
                                                        [self cello_performAddToPlaylistActionForIndexPath:indexPath];
                                                        
                                                    }];
            [actions addObject: addToPlaylistAction];
            
        }
        
        
        if (self.celloPrefs.makeAvailableOffline_peek && [valueContext makeAvailableOfflineAvailable]) {
            
            // contains cached media properties
            MusicCoalescingEntityValueProvider *coalescingEntityValueProvider;
            coalescingEntityValueProvider = (MusicCoalescingEntityValueProvider *)cell.entityValueProvider;
            
            // so we know if the item is already downloaded or not
            NSNumber *keepLocal = [coalescingEntityValueProvider valueForEntityProperty:@"keepLocal"];
            NSString *downloadActionTitle;
            if (keepLocal.boolValue) {
                if ([valueContext isConcreteMediaItem]) {
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
                                                   
                                                   [self cello_performDownloadActionForIndexPath:indexPath];
                                                   
                                               }];
            [actions addObject: downloadAction];
            
        }
        
        
        if (self.celloPrefs.deleteRemove_peek && [valueContext deleteAvailable]) {
            
            UIPreviewAction *deleteAction = [UIPreviewAction
                                             actionWithTitle:@"Delete"
                                             style:UIPreviewActionStyleDestructive
                                             handler:^(UIPreviewAction * _Nonnull action,
                                                       UIViewController * _Nonnull previewViewController) {
                                                 
                                                 UIAlertController *deleteConfirmController = [self cello_deleteConfirmationAlertController:indexPath];
                                                 [self presentViewController:deleteConfirmController animated:YES completion:nil];
                                                 
                                             }];
            [actions addObject: deleteAction];
            
        }
        
        
        
        UIViewController<SWCelloMediaEntityPreviewViewController> *previewViewController;
        previewViewController= [self.libraryViewConfiguration previewViewControllerForEntityValueContext:valueContext
                                                                                      fromViewController:self];
        
        if (!previewViewController) { // unsupported Media type
            previewViewController = [self cello_previewViewControllerForEntityValueContext:valueContext];
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
    
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self cello_previewingContext:previewingContext commitViewController:viewControllerToCommit];
}

%new
- (void)cello_previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    UIViewController<SWCelloMediaEntityPreviewViewController> *previewViewController;
    previewViewController = (UIViewController<SWCelloMediaEntityPreviewViewController> *)viewControllerToCommit;
    
    
    if (self.celloPrefs.popActionType == SWCelloPrefs_ActionType_PushViewController) {
        
        if ([previewViewController isKindOfClass:%c(MusicContextualActionsHeaderViewController)]) {
            
            // I use the contextual alert header view as a preview for unsopprted media collection types (genre, composer)
            // This will simulate clicking the contextual action header view, opening the view controller for the collection
            MusicContextualActionsHeaderViewController *headerVC = (MusicContextualActionsHeaderViewController *)previewViewController;
            [self.libraryViewConfiguration handleSelectionOfEntityValueContext:headerVC.entityValueContext fromViewController:nil];
            
        } else {
            
            [self showViewController:previewViewController sender:nil];
            
        }
        
    } else {
        
        //MusicEntityValueContext *valueContext = [self cello_entityValueContextAtIndexPath:self.celloCurrentPreviewingIndexPath];
        
        if (self.celloPrefs.popActionType == SWCelloPrefs_ActionType_ShowInStore) {
            [self cello_performShowInStoreActionForIndexPath:previewViewController.celloPreviewIndexPath];
        } else if (self.celloPrefs.popActionType == SWCelloPrefs_ActionType_StartRadioStation) {
            [self cello_performStartStationActionForIndexPath:previewViewController.celloPreviewIndexPath];
        } else if (self.celloPrefs.popActionType == SWCelloPrefs_ActionType_PlayNext) {
            [self cello_performUpNextAction:UpNextAlertAction_PlayNext forIndexPath:previewViewController.celloPreviewIndexPath];
        } else if (self.celloPrefs.popActionType == SWCelloPrefs_ActionType_AddToUpNext) {
            [self cello_performUpNextAction:UpNextAlertAction_AddToUpNext forIndexPath:previewViewController.celloPreviewIndexPath];
        } else if (self.celloPrefs.popActionType == SWCelloPrefs_ActionType_AddToPlaylist) {
            [self cello_performAddToPlaylistActionForIndexPath:previewViewController.celloPreviewIndexPath];
        } else if (self.celloPrefs.popActionType == SWCelloPrefs_ActionType_ToggleKeepLocal) {
            [self cello_performDownloadActionForIndexPath:previewViewController.celloPreviewIndexPath];
        } else if (self.celloPrefs.popActionType == SWCelloPrefs_ActionType_Delete) {
            UIAlertController *deleteConfirmController = [self cello_deleteConfirmationAlertController:previewViewController.celloPreviewIndexPath];
            [self presentViewController:deleteConfirmController animated:YES completion:nil];
        }
        
    }
}

#pragma mark - Cello Additions

%new
- (UIViewController<SWCelloMediaEntityPreviewViewController> *)cello_previewViewControllerForEntityValueContext:(MusicEntityValueContext *)valueContext
{
    UIViewController<SWCelloMediaEntityPreviewViewController> *previewViewController = nil;
    
    if ([valueContext isConcreteMediaItem]) { // song
        
        // the base media item
        MPMediaItem *mediaItem = ((MPMediaEntity *)[valueContext isConcreteMediaItem]).representativeItem;
        
        MPMediaPropertyPredicate *queryPredicate = [MPMediaPropertyPredicate predicateWithValue:@(mediaItem.albumPersistentID)
                                                                                    forProperty:MPMediaItemPropertyAlbumPersistentID];
        
        
        MPMediaQuery *albumQuery = [MPMediaQuery albumsQuery];
        MPMediaQuery *titlesQuery = [MPMediaQuery songsQuery];
        
        [albumQuery addFilterPredicate:queryPredicate];
        [titlesQuery addFilterPredicate:queryPredicate];
        
        MusicMediaEntityProvider *albumProvider = [[%c(MusicMediaEntityProvider) alloc] initWithMediaQuery:albumQuery];
        MusicMediaEntityProvider *titlesProvider = [[%c(MusicMediaEntityProvider) alloc] initWithMediaQuery:titlesQuery];
        
        previewViewController = [[%c(MusicMediaAlbumDetailViewController) alloc] initWithContainerEntityProvider:albumProvider
                                                                                         tracklistEntityProvider:titlesProvider
                                                                                                   clientContext:self.clientContext
                                                                           existingJSProductNativeViewController:nil
                                                                                              forContentCreation:YES];
        
    } else if ([valueContext isConcreteMediaCollection]) { // media collection (genre, compilation, etc)
        
        // I use the contextual alert header view as a preview for unsopprted media collection types (genre, composer)
        // This will simulate clicking the contextual action header view, opening the view controller for the collection
        previewViewController = [[%c(MusicContextualActionsHeaderViewController) alloc]
                                 initWithEntityValueContext:valueContext
                                 contextualActions:nil];
        previewViewController.view.backgroundColor = [UIColor whiteColor];
        
    } else if ([valueContext isConcreteMediaPlaylist]) { // playlist
        
        [%c(MusicLibraryPlaylistsViewConfiguration) getDetailViewController:&previewViewController
                                                            playbackContext:nil
                                                      forEntityValueContext:valueContext
                                                       sourceViewController:self];
        
    }
    
    return previewViewController;
}

%new
- (id)cello_entityValueContextAtIndexPath:(NSIndexPath *)indexPath
{
    MusicEntityValueContext *valueContext = [self _entityValueContextAtIndexPath:indexPath];
    
    if (valueContext) {
        
        // make sure our queries are set up correctly
        valueContext.wantsItemGlobalIndex = YES;
        valueContext.wantsItemEntityValueProvider = YES;
        valueContext.wantsContainerEntityValueProvider = YES;
        valueContext.wantsItemIdentifierCollection = YES;
        valueContext.wantsContainerIdentifierCollection = YES;
        valueContext.wantsItemPlaybackContext = YES;
        valueContext.wantsContainerPlaybackContext = YES;
        
        [self _configureEntityValueContextOutput:valueContext forIndexPath:indexPath];
        
    }
    
    return valueContext;
}

%new
- (void)cello_performShowInStoreActionForIndexPath:(NSIndexPath *)indexPath
{
    MusicEntityValueContext *valueContext = [self cello_entityValueContextAtIndexPath:indexPath];
    
    MusicContextualShowInStoreAlertAction *contextAction;
    contextAction = [%c(MusicContextualShowInStoreAlertAction) contextualShowInStoreActionWithEntityValueContext:valueContext
                                                                                               didDismissHandler:nil];
    [contextAction performContextualAction];
}

%new
- (void)cello_performStartStationActionForIndexPath:(NSIndexPath *)indexPath
{
    MusicEntityValueContext *valueContext = [self cello_entityValueContextAtIndexPath:indexPath];
    
    MusicContextualStartStationAlertAction *contextAction;
    contextAction = [%c(MusicContextualStartStationAlertAction) contextualStartStationActionWithEntityValueContext:valueContext];
    
    [contextAction performContextualAction];
}

%new
- (void)cello_performUpNextAction:(UpNextAlertAction_Type)actionType forIndexPath:(NSIndexPath *)indexPath
{
    MusicEntityValueContext *valueContext = [self cello_entityValueContextAtIndexPath:indexPath];
    
    MusicContextualUpNextAlertAction *contextAction = [%c(MusicContextualUpNextAlertAction)
                                                       contextualUpNextActionWithEntityValueContext:valueContext
                                                       insertionType:actionType
                                                       didDismissHandler:nil];
    
    [contextAction performContextualAction];
}

%new
- (void)cello_performAddToPlaylistActionForIndexPath:(NSIndexPath *)indexPath
{
    MusicEntityValueContext *valueContext = [self cello_entityValueContextAtIndexPath:indexPath];
    
    MusicContextualAddToPlaylistAlertAction *contextAction;
    contextAction = [%c(MusicContextualAddToPlaylistAlertAction)
                     contextualAddToPlaylistActionForEntityValueContext:valueContext
                     shouldDismissHandler:nil
                     additionalPresentationHandler:^(MusicContextualPlaylistPickerViewController *arg1) {
                         
                         [self presentViewController:arg1 animated:YES completion:nil];
                         
                     }
                     didDismissHandler:nil];
    
    [contextAction performContextualAction];
}

%new
- (void)cello_performDownloadActionForIndexPath:(NSIndexPath *)indexPath
{
    MusicEntityValueContext *valueContext = [self cello_entityValueContextAtIndexPath:indexPath];
    
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

%new
- (void)cello_performRemoveFromPlaylistActionForIndexPath:(NSIndexPath *)indexPath
{
    MusicEntityValueContext *valueContext = [self cello_entityValueContextAtIndexPath:indexPath];
    
    MusicContextualRemoveFromPlaylistAlertAction *contextAction;
    contextAction = [%c(MusicContextualRemoveFromPlaylistAlertAction)
                     contextualRemoveFromPlaylistActionWithEntityValueContext:valueContext];
    
    [contextAction performContextualAction];
}

%new
- (void)cello_performDeleteFromLibraryActionForValueContext:(MusicEntityValueContext *)valueContext
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

%new
- (UIAlertController *)cello_deleteConfirmationAlertController:(NSIndexPath *)indexPath
{
    UICollectionViewCell<Cello_MusicEntityCollectionViewCellValueProviding> *cell;
    cell = (UICollectionViewCell<Cello_MusicEntityCollectionViewCellValueProviding> *)[self.collectionView cellForItemAtIndexPath:indexPath];
    MusicCoalescingEntityValueProvider *coalescingEntityValueProvider;
    coalescingEntityValueProvider = (MusicCoalescingEntityValueProvider *)cell.entityValueProvider;
    
    __block MusicEntityValueContext *valueContext = [self cello_entityValueContextAtIndexPath:indexPath];
    
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:[coalescingEntityValueProvider cello_EntityNameBestGuess]
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             
                                                             //[self.collectionView setEditing:NO animated:YES];
                                                             
                                                         }];
    [controller addAction:cancelAction];
    
    
    if ([valueContext removeFromPlaylistAvailable]) {
        
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
                                        valueContext = [self cello_entityValueContextAtIndexPath:indexPath];
                                        [self cello_performRemoveFromPlaylistActionForIndexPath:indexPath];
                                        
                                    }];
        [controller addAction:deleteFromPlaylistAction];
    }
    
    
    UIAlertAction *deleteAction;
    deleteAction = [UIAlertAction
                    actionWithTitle:@"Delete from Music Library"
                    style:UIAlertActionStyleDestructive
                    handler:^(UIAlertAction * action) {
                        
                        // make sure we have correct context (see removeFromPlaylistAction below)
                        valueContext = [self cello_entityValueContextAtIndexPath:indexPath];
                        
                        if ([valueContext removeFromPlaylistAvailable]) {
                            [self cello_performRemoveFromPlaylistActionForIndexPath:indexPath];
                        }
                        
                        
                        // special situation with single items in a playlist
                        // this allows them to be deleted as well by constructing a new query for the item
                        // without it's playlist referenced
                        if ([valueContext isConcreteMediaItem]) {
                            
                            MPMediaEntity *mediaItem = (MPMediaEntity *)valueContext.entityValueProvider;
                            
                            MPMediaPropertyPredicate *queryPredicate = [MPMediaPropertyPredicate predicateWithValue:@(mediaItem.persistentID)
                                                                                                        forProperty:MPMediaItemPropertyPersistentID];
                            
                            MPMediaQuery *titlesQuery = [MPMediaQuery songsQuery];
                            [titlesQuery addFilterPredicate:queryPredicate];
                            
                            if (titlesQuery.items.count == 1) {
                                
                                MusicEntityValueContext *tempValueContext = [[%c(MusicEntityValueContext) alloc] init];
                                [tempValueContext configureWithMediaEntity:titlesQuery.items[0]];
                                
                                [self cello_performDeleteFromLibraryActionForValueContext:tempValueContext];
                                
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
                            
                            [self cello_performDeleteFromLibraryActionForValueContext:valueContext];
                            
                        }
                        
                    }];
    [controller addAction:deleteAction];
    
    
    // iPad
    UIPopoverPresentationController *popPresenter = [controller popoverPresentationController];
    popPresenter.sourceView = cell;
    popPresenter.sourceRect = cell.bounds;
    
    return controller;
}

%new
- (SWCelloPrefs *)celloPrefs
{
    SWCelloPrefs *prefs = objc_getAssociatedObject(self, @selector(_celloPrefs));
    
    if (!prefs) {
        self.celloPrefs = [[SWCelloPrefs alloc] init];
        return self.celloPrefs;
    }
    
    return prefs;
}

%new
- (void)setCelloPrefs:(SWCelloPrefs *)celloPrefs
{
    if (celloPrefs == nil && self.celloPrefs) { // clean up notifications
        [[NSNotificationCenter defaultCenter] removeObserver:self.celloPrefs];
    }
    
    objc_setAssociatedObject(self, @selector(_celloPrefs), celloPrefs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%end




