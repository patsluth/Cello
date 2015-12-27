//
//  MusicLibraryBrowseTableViewController.xm
//  Cello
//
//  Created by Pat Sluth on 2015-12-21.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import "SWCelloMediaEntityPreviewViewController.h"

#import "MusicLibraryBrowseTableViewController.h"
#import "MusicMediaAlbumDetailViewController.h"
#import "MusicProfileAlbumsViewController.h"
#import "MusicMediaProfileDetailViewController.h"
#import "MusicMediaPlaylistDetailViewController.h"


#import "MusicLibraryViewConfiguration.h"
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





@protocol Cello_MusicEntityTableViewCellValueProviding
@required
@property (nonatomic,retain) id<MusicEntityValueProviding> entityValueProvider;
@end





%hook MusicProfileAlbumsViewController

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

%hook MusicProductTracklistTableViewController

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

%hook MusicLibraryBrowseTableViewController

- (void)viewDidAppear:(BOOL)animated
{
    self.celloPrefs = [[SWCelloPrefs alloc] init];
    
    %orig(animated);
}

- (void)viewWillDisappear:(BOOL)animated
{
    // remove our associated object
    self.celloPrefs = nil;
    self.celloCurrentPreviewingIndexPath = nil;
    
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

    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    self.celloCurrentPreviewingIndexPath = indexPath;
    
    if (!indexPath) {
        return nil;
    }
    
    UITableViewCell<Cello_MusicEntityTableViewCellValueProviding> *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    

    if (cell) {
        
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
        
        previewViewController.celloPreviewActionItems = [actions copy];
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
    if (self.celloPrefs.popActionType == SWCelloPrefs_ActionType_PushViewController) {
    
        if ([viewControllerToCommit isKindOfClass:%c(MusicContextualActionsHeaderViewController)]) {
            
            // I use the contextual alert header view as a preview for unsopprted media collection types (genre, composer)
            // This will simulate clicking the contextual action header view, opening the view controller for the collection
            MusicContextualActionsHeaderViewController *headerVC = (MusicContextualActionsHeaderViewController *)viewControllerToCommit;
            [self.libraryViewConfiguration handleSelectionOfEntityValueContext:headerVC.entityValueContext fromViewController:nil];
            
        } else {
            
            [self showViewController:viewControllerToCommit sender:nil];
            
        }
        
    } else {
        
        //MusicEntityValueContext *valueContext = [self cello_entityValueContextAtIndexPath:self.celloCurrentPreviewingIndexPath];
        
        if (self.celloPrefs.popActionType == SWCelloPrefs_ActionType_ShowInStore) {
            [self cello_performShowInStoreActionForIndexPath:self.celloCurrentPreviewingIndexPath];
        } else if (self.celloPrefs.popActionType == SWCelloPrefs_ActionType_StartRadioStation) {
            [self cello_performStartStationActionForIndexPath:self.celloCurrentPreviewingIndexPath];
        } else if (self.celloPrefs.popActionType == SWCelloPrefs_ActionType_PlayNext) {
            [self cello_performUpNextAction:UpNextAlertAction_PlayNext forIndexPath:self.celloCurrentPreviewingIndexPath];
        } else if (self.celloPrefs.popActionType == SWCelloPrefs_ActionType_AddToUpNext) {
            [self cello_performUpNextAction:UpNextAlertAction_AddToUpNext forIndexPath:self.celloCurrentPreviewingIndexPath];
        } else if (self.celloPrefs.popActionType == SWCelloPrefs_ActionType_AddToPlaylist) {
            [self cello_performAddToPlaylistActionForIndexPath:self.celloCurrentPreviewingIndexPath];
        } else if (self.celloPrefs.popActionType == SWCelloPrefs_ActionType_ToggleKeepLocal) {
            [self cello_performDownloadActionForIndexPath:self.celloCurrentPreviewingIndexPath];
        } else if (self.celloPrefs.popActionType == SWCelloPrefs_ActionType_Delete) {
            UIAlertController *deleteConfirmController = [self cello_deleteConfirmationAlertController:self.celloCurrentPreviewingIndexPath];
            [self presentViewController:deleteConfirmController animated:YES completion:nil];
        }
        
    }
    
    self.celloCurrentPreviewingIndexPath = nil;
}

#pragma mark - UITableViewEditing

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
    // if all options are disabled then don't allow sliding
    if (self.celloPrefs.upNext_slide || self.celloPrefs.makeAvailableOffline_slide || self.celloPrefs.deleteRemove_slide) {
        return YES;
    } else {
        return %orig(tableView, indexPath);
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if all options are disabled then don't allow sliding
    if (self.celloPrefs.upNext_slide || self.celloPrefs.makeAvailableOffline_slide || self.celloPrefs.deleteRemove_slide) {
        
        UITableViewCell<Cello_MusicEntityTableViewCellValueProviding> *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        if ([(id)cell.entityValueProvider isKindOfClass:%c(MusicCoalescingEntityValueProvider)]) {
            
            
            // contains cached media properties
            MusicCoalescingEntityValueProvider *coalescingEntityValueProvider;
            coalescingEntityValueProvider = (MusicCoalescingEntityValueProvider *)cell.entityValueProvider;
            
            if ([[(id)coalescingEntityValueProvider.baseEntityValueProvider class] isSubclassOfClass:%c(MPMediaEntity)]){ // media cell
                
                return UITableViewCellEditingStyleDelete;
                
            }
        }
        
    }
    
    // not a media cell
    return %orig(tableView, indexPath);
}

%new
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell<Cello_MusicEntityTableViewCellValueProviding> *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
        if (!cell) {
        return nil;
    }
    
    MusicEntityValueContext *valueContext = [self cello_entityValueContextAtIndexPath:indexPath];
    NSMutableArray *actions = [@[] mutableCopy];
    
    
    if (self.celloPrefs.upNext_slide && [valueContext upNextAvailable]) {
        
        UITableViewRowAction *playNextAction = [UITableViewRowAction
                                                rowActionWithStyle:UITableViewRowActionStyleNormal
                                                title:@"Play\nNext"
                                                handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                    
                                                    [self cello_performUpNextAction:UpNextAlertAction_PlayNext forIndexPath:indexPath];
                                                    [self.tableView setEditing:NO animated:YES];
                                                    
                                                }];
        playNextAction.backgroundColor = [UIColor colorWithRed:0.1 green:0.71 blue:1.0 alpha:1.0];
        [actions addObject:playNextAction];
        
        
        UITableViewRowAction *addToUpNextAction = [UITableViewRowAction
                                                   rowActionWithStyle:UITableViewRowActionStyleNormal
                                                   title:@"Up\nNext"
                                                   handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                       
                                                       [self cello_performUpNextAction:UpNextAlertAction_AddToUpNext forIndexPath:indexPath];
                                                       [self.tableView setEditing:NO animated:YES];
                                                       
                                                   }];
        addToUpNextAction.backgroundColor = [UIColor colorWithRed:0.97 green:0.58 blue:0.02 alpha:1.0];
        [actions addObject:addToUpNextAction];
        
    }
    
    
    if (self.celloPrefs.makeAvailableOffline_slide && [valueContext makeAvailableOfflineAvailable]) {
        
        // contains cached media properties
        MusicCoalescingEntityValueProvider *coalescingEntityValueProvider;
        coalescingEntityValueProvider = (MusicCoalescingEntityValueProvider *)cell.entityValueProvider;
        
        // so we know if the item is already downloaded or not
        NSNumber *keepLocal = [coalescingEntityValueProvider valueForEntityProperty:@"keepLocal"];
        UITableViewRowAction *downloadAction = [UITableViewRowAction
                                                rowActionWithStyle:UITableViewRowActionStyleNormal
                                                title:(keepLocal.boolValue ? @"Remove\nDownload" : @"Download")
                                                handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                    
                                                    [CATransaction begin];
                                                    [CATransaction setCompletionBlock: ^{
                                                        [self cello_performDownloadActionForIndexPath:indexPath];
                                                    }];
                                                    [self.tableView setEditing:NO animated:YES];
                                                    [CATransaction commit];
                                                    
                                                    
                                                }];
        downloadAction.backgroundColor = [UIColor colorWithRed:0.56 green:0.27 blue:0.68 alpha:1.0];
        [actions addObject:downloadAction];
        
    }
    
    
    if (self.celloPrefs.deleteRemove_slide && [valueContext deleteAvailable]) {
     
        UITableViewRowAction *deleteAction = [UITableViewRowAction
                                              rowActionWithStyle:UITableViewRowActionStyleDestructive
                                              title:@"Delete"
                                              handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                  
                                                  UIAlertController *deleteConfirmController = [self cello_deleteConfirmationAlertController:indexPath];
                                                  [self presentViewController:deleteConfirmController animated:YES completion:nil];
                                                  
                                              }];
        [actions addObject:deleteAction];
        
    }
    
    if (actions.count == 0) {
        return nil;
    }
    
    return [actions copy];
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
                                                                           existingJSProductNativeViewController:nil];
        
        
    } else if ([valueContext isConcreteMediaCollection]) { // media collection (genre, compilation, etc)
        
        // I use the contextual alert header view as a preview for unsopprted media collection types (genre, composer)
        // This will simulate clicking the contextual action header view, opening the view controller for the collection
        previewViewController = [[%c(MusicContextualActionsHeaderViewController) alloc]
                                 initWithEntityValueContext:valueContext
                                 contextualActions:nil];
        previewViewController.view.backgroundColor = [UIColor whiteColor];
        
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
                     additionalPresentationHandler:^(MusicContextualPlaylistPickerViewController *arg1){
                         
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
    UITableViewCell<Cello_MusicEntityTableViewCellValueProviding> *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    MusicCoalescingEntityValueProvider *coalescingEntityValueProvider;
    coalescingEntityValueProvider = (MusicCoalescingEntityValueProvider *)cell.entityValueProvider;
    
    __block MusicEntityValueContext *valueContext = [self cello_entityValueContextAtIndexPath:indexPath];
    
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:[coalescingEntityValueProvider cello_EntityNameBestGuess]
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             
                                                             [self.tableView setEditing:NO animated:YES];
                                                             
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

%new
- (NSIndexPath *)celloCurrentPreviewingIndexPath
{
    return objc_getAssociatedObject(self, @selector(_celloCurrentPreviewingIndexPath));
}

%new
- (void)setCelloCurrentPreviewingIndexPath:(NSIndexPath *)celloCurrentPreviewingIndexPath
{
    objc_setAssociatedObject(self, @selector(_celloCurrentPreviewingIndexPath), celloCurrentPreviewingIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%end








#pragma mark - Debugging
// shows exacty details of system media queries for each type of media view controller

//%hook MusicMediaProfileDetailViewController
//
//-(id)initWithContainerEntityProvider:(id)arg1
//clientContext:(id)arg2
//existingJSProfileNativeViewController:(id)arg3
//profileType:(unsigned long long)arg4
//{
//    id orig = %orig(arg1, arg2, arg3, arg4);
//
//    NSLog(@"%@", NSStringFromClass(self.class));
//    NSLog(@"initWithContainerEntityProvider:[%@]", arg1);
//    NSLog(@"clientContext:[%@]", arg2);
//    NSLog(@"existingJSProfileNativeViewController:[%@]", arg3);
//    NSLog(@"profileType:[%@]", @(arg4));
//    NSLog(@"retunVal:[%@]", orig);
//
//    return orig;
//}
//
//%end

//%hook MusicMediaProductDetailViewController
//
//-(id)initWithContainerEntityProvider:(MusicMediaEntityProvider *)arg1
//tracklistEntityProvider:(MusicMediaEntityProvider *)arg2
//clientContext:(id)arg3
//existingJSProductNativeViewController:(id)arg4
//{
//    id orig = %orig(arg1, arg2, arg3, arg4);
//    
//    NSLog(@"%@", NSStringFromClass(self.class));
//    NSLog(@"initWithContainerEntityProvider:[%@]", arg1);
//    NSLog(@"tracklistEntityProvider:[%@]", arg2);
//    NSLog(@"clientContext:[%@]", arg3);
//    NSLog(@"existingJSProductNativeViewController:[%@]", arg4);
//    NSLog(@"retunVal:[%@]", orig);
//    
//    NSLog(@"arg1.mediaQuery:[%@]", arg1.mediaQuery);
//    NSLog(@"arg1.mediaQueryDataSource.entities:[%@]", arg1.mediaQueryDataSource.entities);
//    NSLog(@"arg2.mediaQuery:[%@]", arg2.mediaQuery);
//    NSLog(@"arg2.mediaQueryDataSource.entities:[%@]", arg2.mediaQueryDataSource.entities);
//    
//    return orig;
//}
//
//%end

//%hook MusicContextualAddToPlaylistAlertAction
//
//+ (id)contextualAddToPlaylistActionForEntityValueContext:(MusicEntityValueContext *)arg1
//shouldDismissHandler:(/*^block*/id)arg2
//additionalPresentationHandler:(/*^block*/id)arg3
//didDismissHandler:(/*^block*/id)arg4
//{
//    id x = %orig(arg1, arg2, arg3, arg4);
//    
//    NSLog(@"\n\n\nx %@", x);
//    NSLog(@"arg2 %@", arg2);
//    NSLog(@"arg3 %@", arg3);
//    NSLog(@"arg4 %@", arg4);
//    
//    [arg1 log];
//    
//    return x;
//}
//
//%end
//
//%hook MusicContextualPlaylistPickerViewController
//
//- (id)initWithPlaylistSelectionHandler:(/*^block*/id)arg1
//{
//    id x = %orig(arg1);
//    
//    NSLog(@"\n\n\nx %@", x);
//    NSLog(@"arg1 %@", arg1);
//    
//    return x;
//}
//
//%end

//@interface MusicJSNativeViewEventRegistry : NSObject
//@end
//
//%hook MusicJSNativeViewEventRegistry
//
//-(void)registerExistingJSNativeViewController:(id)arg1 forViewController:(id)arg2
//{
//    NSLog(@"%@", NSStringFromClass(self.class));
//    NSLog(@"");NSLog(@"");
//    NSLog(@"registerExistingJSNativeViewController:[%@]", arg1);
//    NSLog(@"forViewController:[%@]", arg2);
//    NSLog(@"");NSLog(@"");
//    
//    %orig(arg1, arg2);
//}
//
//-(void)requestAccessToJSNativeViewControllerForViewController:(id)arg1 usingBlock:(/*^block*/id)arg2
//{
//    NSLog(@"%@", NSStringFromClass(self.class));
//    NSLog(@"");NSLog(@"");
//    NSLog(@"requestAccessToJSNativeViewControllerForViewController:[%@]", arg1);
//    NSLog(@"usingBlock:[%@]", arg2);
//    NSLog(@"");NSLog(@"");
//    
//    %orig(arg1, arg2);
//}
//
//-(void)dispatchNativeViewEventOfType:(long long)arg1 forViewController:(id)arg2
//{
//    NSLog(@"%@", NSStringFromClass(self.class));
//    NSLog(@"");NSLog(@"");
//    NSLog(@"dispatchNativeViewEventOfType:[%@]", @(arg1));
//    NSLog(@"forViewController:[%@]", arg2);
//    NSLog(@"");NSLog(@"");
//    
//    %orig(arg1, arg2);
//}
//
//-(id)_existingRegisteredJSNativeViewControllerForViewController:(id)arg1
//{
//    id orig = %orig(arg1);
//    
//    NSLog(@"%@", NSStringFromClass(self.class));
//    NSLog(@"");NSLog(@"");
//    NSLog(@"_existingRegisteredJSNativeViewControllerForViewController:[%@]", arg1);
//    NSLog(@"retunVal:[%@]", orig);
//    NSLog(@"");NSLog(@"");
//    
//    return orig;
//}
//
//-(void)_dispatchNativeViewEventOfType:(long long)arg1
//withExtraInfo:(id)arg2
//forJSNativeViewController:(id)arg3
//appContext:(id)arg4
//jsContext:(id)arg5
//completion:(/*^block*/id)arg6
//{
//    NSLog(@"%@", NSStringFromClass(self.class));
//    NSLog(@"");NSLog(@"");
//    NSLog(@"_dispatchNativeViewEventOfType:[%@]", @(arg1));
//    NSLog(@"withExtraInfo:[%@]", arg2);
//    NSLog(@"forJSNativeViewController:[%@]", arg3);
//    NSLog(@"appContext:[%@]", arg4);
//    NSLog(@"jsContext:[%@]", arg5);
//    NSLog(@"completion:[%@]", arg6);
//    NSLog(@"");NSLog(@"");
//    
//    %orig(arg1, arg2, arg3, arg4, arg5, arg6);
//}
//
//-(void)_registerViewController:(id)arg1 withExistingJSNativeViewController:(id)arg2
//{
//    NSLog(@"%@", NSStringFromClass(self.class));
//    NSLog(@"");NSLog(@"");
//    NSLog(@"_registerViewController:[%@]", arg1);
//    NSLog(@"withExistingJSNativeViewController:[%@]", arg2);
//    NSLog(@"");NSLog(@"");
//    
//    %orig(arg1, arg2);
//}
//
//%end



