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


#import "MusicLibraryViewConfiguration.h"



#import "MusicMediaPlaylistDetailViewController.h"



#import "MusicCoalescingEntityValueProvider.h"
#import "MusicEntityValueContext.h"
#import "MusicMediaEntityProvider.h"

#import "MusicContextualUpNextAlertAction.h"
#import "MusicContextualAddToPlaylistAlertAction.h"
#import "MusicContextualLibraryUpdateAlertAction.h"
//unused as of now
#import "MusicContextualRemoveFromPlaylistAlertAction.h"
#import "MusicContextualShowInStoreAlertAction.h"
#import "MusicContextualStartStationAlertAction.h"
//related
#import "MusicContextualPlaylistPickerViewController.h"












#import "MusicContextualActionsHeaderViewController.h"

#import <MediaPlayer/MediaPlayer.h>

#import "MPQueryPlaybackContext.h"


#import "MPMediaEntity+SW.h"


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

%end

%hook MusicProductTracklistTableViewController

// peek
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    return [self cello_previewingContext:previewingContext viewControllerForLocation:location];
}

%end

%hook MusicLibraryBrowseTableViewController

// peek
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    return [self cello_previewingContext:previewingContext viewControllerForLocation:location];
}

%new
- (UIViewController *)cello_previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    if (self.presentedViewController){
        return nil;
    }

    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    if (!indexPath) {
        return nil;
    }
    
    UITableViewCell<Cello_MusicEntityTableViewCellValueProviding> *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    

    if (cell) {
        
        // contains cached media properties
        MusicCoalescingEntityValueProvider *coalescingEntityValueProvider;
        coalescingEntityValueProvider = (MusicCoalescingEntityValueProvider *)cell.entityValueProvider;
        
        MusicEntityValueContext *valueContext = [self cello_entityValueContextAtIndexPath:indexPath];
        NSMutableArray *actions = [@[] mutableCopy];
        
        
        if ([valueContext showInStoreAvailable]) {
            
            UIPreviewAction *showInStoreAction = [UIPreviewAction
                                                   actionWithTitle:@"Show in iTunes Store"
                                                   style:UIPreviewActionStyleDefault
                                                   handler:^(UIPreviewAction * _Nonnull action,
                                                             UIViewController * _Nonnull previewViewController) {
                                                       
                                                       [self cello_performShowInStoreActionForValueContext:valueContext];
                                                       
                                                   }];
            [actions addObject: showInStoreAction];
            
        }
        
        
        if ([valueContext startStation]) {
            
            UIPreviewAction *startStationAction = [UIPreviewAction
                                                   actionWithTitle:@"Start Station"
                                                   style:UIPreviewActionStyleDefault
                                                   handler:^(UIPreviewAction * _Nonnull action,
                                                             UIViewController * _Nonnull previewViewController) {
                                                       
                                                       [self cello_performStartStationActionForValueContext:valueContext];
                                                       
                                                   }];
            [actions addObject: startStationAction];
            
        }
        
        
        if ([valueContext upNextAvailable]) {
            
            UIPreviewAction *playNextAction = [UIPreviewAction
                                               actionWithTitle:@"Play Next"
                                               style:UIPreviewActionStyleDefault
                                               handler:^(UIPreviewAction * _Nonnull action,
                                                         UIViewController * _Nonnull previewViewController) {
                                                   
                                                   [self cello_performUpNextAction:UpNextAlertAction_PlayNext forValueContext:valueContext];
                                                   
                                               }];
            [actions addObject: playNextAction];
            
            
            UIPreviewAction *addToUpNextAction = [UIPreviewAction
                                                  actionWithTitle:@"Add to Up Next"
                                                  style:UIPreviewActionStyleDefault
                                                  handler:^(UIPreviewAction * _Nonnull action,
                                                            UIViewController * _Nonnull previewViewController) {
                                                      
                                                      [self cello_performUpNextAction:UpNextAlertAction_AddToUpNext forValueContext:valueContext];
                                                      
                                                  }];
            [actions addObject: addToUpNextAction];
            
        }
        
        
        if ([valueContext addToPlaylistAvailable]) {
            
            UIPreviewAction *addToPlaylistAction = [UIPreviewAction
                                                    actionWithTitle:@"Add to Playlist"
                                                    style:UIPreviewActionStyleDefault
                                                    handler:^(UIPreviewAction * _Nonnull action,
                                                              UIViewController * _Nonnull previewViewController) {
                                                        
                                                        [self cello_performAddToPlaylistActionForValueContext:valueContext];
                                                        
                                                    }];
            [actions addObject: addToPlaylistAction];
            
        }


        // so we know if the item is already downloaded or not
        NSNumber *keepLocal = [coalescingEntityValueProvider valueForEntityProperty:@"keepLocal"];
        UIPreviewAction *downloadAction = [UIPreviewAction
                                         actionWithTitle:(keepLocal.boolValue ? @"Remove Download" : @"Make Available Offline")
                                         style:UIPreviewActionStyleDefault
                                         handler:^(UIPreviewAction * _Nonnull action,
                                                   UIViewController * _Nonnull previewViewController) {

                                             [self cello_performDownloadActionForValueContext:valueContext];

                                         }];
        [actions addObject: downloadAction];
        
        
        UIPreviewAction *deleteAction = [UIPreviewAction
                                         actionWithTitle:@"Delete"
                                         style:UIPreviewActionStyleDestructive
                                         handler:^(UIPreviewAction * _Nonnull action,
                                                   UIViewController * _Nonnull previewViewController) {
                                             
                                             UIAlertController *deleteConfirmController = [self cello_deleteConfirmationAlertController:indexPath];
                                             [self presentViewController:deleteConfirmController animated:YES completion:nil];
                                             
                                         }];
        [actions addObject: deleteAction];
        
        
        
        
        
        
        UIViewController<SWCelloMediaEntityPreviewViewController> *previewViewController;
        previewViewController= [self.libraryViewConfiguration previewViewControllerForEntityValueContext:valueContext
                                                                                      fromViewController:nil];
        
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
    if ([viewControllerToCommit isKindOfClass:%c(MusicContextualActionsHeaderViewController)]) {
        
        // I use the contextual alert header view as a preview for unsopprted media collection types (genre, composer)
        // This will simulate clicking the contextual action header view, opening the view controller for the collection
        MusicContextualActionsHeaderViewController *headerVC = (MusicContextualActionsHeaderViewController *)viewControllerToCommit;
        [self.libraryViewConfiguration handleSelectionOfEntityValueContext:headerVC.entityValueContext fromViewController:self];
        
    } else {
        
        [self showViewController:viewControllerToCommit sender:self];
        
    }
}

#pragma mark - UITableViewEditing

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell<Cello_MusicEntityTableViewCellValueProviding> *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if ([(id)cell.entityValueProvider isKindOfClass:%c(MusicCoalescingEntityValueProvider)]) {
        
        // contains cached media properties
        MusicCoalescingEntityValueProvider *coalescingEntityValueProvider;
        coalescingEntityValueProvider = (MusicCoalescingEntityValueProvider *)cell.entityValueProvider;
        
        if ([[(id)coalescingEntityValueProvider.baseEntityValueProvider class] isSubclassOfClass:%c(MPMediaEntity)]){ // media cell
            
            return UITableViewCellEditingStyleDelete;
            
        }
    }
    
    
    // not a media cell
    return UITableViewCellEditingStyleNone;
}

%new
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell<Cello_MusicEntityTableViewCellValueProviding> *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    
    if (!cell) {
        return nil;
    }
    
    
    // contains cached media properties
    MusicCoalescingEntityValueProvider *coalescingEntityValueProvider;
    coalescingEntityValueProvider = (MusicCoalescingEntityValueProvider *)cell.entityValueProvider;
    
    MusicEntityValueContext *valueContext = [self cello_entityValueContextAtIndexPath:indexPath];
    NSMutableArray *actions = [@[] mutableCopy];
    
    
    if ([valueContext upNextAvailable]) {
        
        UITableViewRowAction *playNextAction = [UITableViewRowAction
                                                rowActionWithStyle:UITableViewRowActionStyleNormal
                                                title:@"Play\nNext"
                                                handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                    
                                                    [self cello_performUpNextAction:UpNextAlertAction_PlayNext forValueContext:valueContext];
                                                    [self.tableView setEditing:NO animated:YES];
                                                    
                                                }];
        playNextAction.backgroundColor = [UIColor colorWithRed:0.1 green:0.71 blue:1.0 alpha:1.0];
        [actions addObject:playNextAction];
        
        
        UITableViewRowAction *addToUpNextAction = [UITableViewRowAction
                                                   rowActionWithStyle:UITableViewRowActionStyleNormal
                                                   title:@"Up\nNext"
                                                   handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                       
                                                       [self cello_performUpNextAction:UpNextAlertAction_AddToUpNext forValueContext:valueContext];
                                                       [self.tableView setEditing:NO animated:YES];
                                                       
                                                   }];
        addToUpNextAction.backgroundColor = [UIColor colorWithRed:0.97 green:0.58 blue:0.02 alpha:1.0];
        [actions addObject:addToUpNextAction];
        
    }
    
    
    // so we know if the item is already downloaded or not
    NSNumber *keepLocal = [coalescingEntityValueProvider valueForEntityProperty:@"keepLocal"];
    UITableViewRowAction *downloadAction = [UITableViewRowAction
                                          rowActionWithStyle:UITableViewRowActionStyleNormal
                                            title:(keepLocal.boolValue ? @"Remove\nDownload" : @"Download")
                                          handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                              
                                              [CATransaction begin];
                                              [CATransaction setCompletionBlock: ^{
                                                  [self cello_performDownloadActionForValueContext:valueContext];
                                              }];
                                              [self.tableView setEditing:NO animated:YES];
                                              [CATransaction commit];
                                              
                                              
                                          }];
    downloadAction.backgroundColor = [UIColor colorWithRed:0.56 green:0.27 blue:0.68 alpha:1.0];
    [actions addObject:downloadAction];
    
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction
                                          rowActionWithStyle:UITableViewRowActionStyleDestructive
                                          title:@"Delete"
                                          handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                              
                                              UIAlertController *deleteConfirmController = [self cello_deleteConfirmationAlertController:indexPath];
                                              [self presentViewController:deleteConfirmController animated:YES completion:nil];
                                              
                                          }];
    [actions addObject:deleteAction];
    
    
    return [actions copy];
}

#pragma mark - Cello Additions

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
- (void)cello_performShowInStoreActionForValueContext:(MusicEntityValueContext *)valueContext
{
    MusicContextualShowInStoreAlertAction *contextAction;
    contextAction = [%c(MusicContextualShowInStoreAlertAction) contextualShowInStoreActionWithEntityValueContext:valueContext
                                                                                               didDismissHandler:nil];
    [contextAction performContextualAction];
}

%new
- (void)cello_performStartStationActionForValueContext:(MusicEntityValueContext *)valueContext
{
    MusicContextualStartStationAlertAction *contextAction;
    contextAction = [%c(MusicContextualStartStationAlertAction) contextualStartStationActionWithEntityValueContext:valueContext];
    
    [contextAction performContextualAction];
}

%new
- (void)cello_performUpNextAction:(UpNextAlertAction_Type)actionType forValueContext:(MusicEntityValueContext *)valueContext
{
    MusicContextualUpNextAlertAction *contextAction = [%c(MusicContextualUpNextAlertAction)
                                                      contextualUpNextActionWithEntityValueContext:valueContext
                                                      insertionType:actionType
                                                      didDismissHandler:nil];
    
    [contextAction performContextualAction];
}

%new
- (void)cello_performAddToPlaylistActionForValueContext:(MusicEntityValueContext *)valueContext
{
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
- (void)cello_performDownloadActionForValueContext:(MusicEntityValueContext *)valueContext
{
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

//%new
//- (void)cello_performRemoveFromPlaylistActionForValueContext:(MusicEntityValueContext *)valueContext
//{
//    MusicContextualRemoveFromPlaylistAlertAction *contextAction;
//    contextAction = [%c(MusicContextualRemoveFromPlaylistAlertAction)
//                     contextualRemoveFromPlaylistActionWithEntityValueContext:valueContext];
//    
//    [contextAction performContextualAction];
//}

%new
- (UIAlertController *)cello_deleteConfirmationAlertController:(NSIndexPath *)indexPath
{
    UITableViewCell<Cello_MusicEntityTableViewCellValueProviding> *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    MusicCoalescingEntityValueProvider *coalescingEntityValueProvider;
    coalescingEntityValueProvider = (MusicCoalescingEntityValueProvider *)cell.entityValueProvider;
    
    NSString *message = [NSString stringWithFormat:@"%@ %@",
                         [coalescingEntityValueProvider cello_EntityNameBestGuess],
                         @"will also be removed from all your devices."];
    
    
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             
                                                             [self.tableView setEditing:NO animated:YES];
                                                             
                                                         }];
    
    UIAlertAction *deleteAction = [UIAlertAction
                                   actionWithTitle:@"Delete from Music Library"
                                   style:UIAlertActionStyleDestructive
                                   handler:^(UIAlertAction * action) {
                                       
                                       MusicEntityValueContext *valueContext = [self cello_entityValueContextAtIndexPath:indexPath];
                                       
                                       // special situation with single items in a playlist
                                       // this allows them to be deleted as well by constructing a new query for the item
                                       // without it's playlist referenced
                                       if ([(id)valueContext.entityValueProvider isKindOfClass:%c(MPConcreteMediaItem)]) {
                                           
                                           MPMediaEntity *mediaItem = (MPMediaEntity *)valueContext.entityValueProvider;
                                           
                                           MPMediaPropertyPredicate *queryPredicate = [MPMediaPropertyPredicate predicateWithValue:@(mediaItem.persistentID)
                                                                                                                       forProperty:MPMediaItemPropertyPersistentID];
                                           
                                           MPMediaQuery *titlesQuery = [MPMediaQuery songsQuery];
                                           [titlesQuery addFilterPredicate:queryPredicate];
                                           
                                           if (titlesQuery.items.count == 1) {
                                               valueContext = [[%c(MusicEntityValueContext) alloc] init];
                                               [valueContext configureWithMediaEntity:titlesQuery.items[0]];
                                           } else {
                                               NSLog(@"Cello - Error constructing query");
                                           }
                                           
                                       }
                                       
                                       MusicContextualLibraryUpdateAlertAction *contextAction;
                                       [%c(MusicContextualLibraryUpdateAlertAction) getContextualLibraryAddRemoveAction:&contextAction
                                                                                                        keepLocalAction:nil
                                                                                                  forEntityValueContext:valueContext
                                                                                             overrideItemEntityProvider:nil
                                                                                                   shouldDismissHandler:nil
                                                                                          additionalPresentationHandler:nil
                                                                                                      didDismissHandler:nil];
                                       
                                       [contextAction performContextualAction];
                                       
                                   }];
    
    // add actions
    [controller addAction:cancelAction];
    [controller addAction:deleteAction];
    
    // iPad
    UIPopoverPresentationController *popPresenter = [controller popoverPresentationController];
    popPresenter.sourceView = cell;
    popPresenter.sourceRect = cell.bounds;
    
    return controller;
}

%end





@interface MusicEntityTracklistItemTableViewCell : UITableViewCell <Cello_MusicEntityTableViewCellValueProviding>
{
}

- (BOOL)tracklistItemViewShouldLayoutAsEditing:(id)arg1;
- (void)tracklistItemViewDidSelectContextualActionsButton:(id)arg1;

@end

@interface MusicEntityHorizontalLockupTableViewCell : UITableViewCell <Cello_MusicEntityTableViewCellValueProviding>
{
}

- (BOOL)horizontalLockupViewShouldLayoutAsEditing:(id)arg1;
- (void)horizontalLockupViewDidSelectContextualActionsButton:(id)arg1;

@end




%hook MusicEntityTracklistItemTableViewCell

- (BOOL)tracklistItemViewShouldLayoutAsEditing:(id)arg1
{
    return NO;
}

- (void)tracklistItemViewDidSelectContextualActionsButton:(id)arg1
{
    if (self.isEditing) {
        return;
    }
    
    %orig();
}

%end


%hook MusicEntityHorizontalLockupTableViewCell

- (BOOL)horizontalLockupViewShouldLayoutAsEditing:(id)arg1
{
    return NO;
}

- (void)horizontalLockupViewDidSelectContextualActionsButton:(id)arg1
{
    if (self.isEditing) {
        return;
    }
    
    %orig();
}

%end









//#pragma mark - Media Query View Controller Mapping DEBUG
// shows exacty details of system media queries for each type of media view controller
//
//%hook MusicMediaProfileDetailViewController
//
//-(id)initWithContainerEntityProvider:(id)arg1
//clientContext:(id)arg2
//existingJSProfileNativeViewController:(id)arg3
//profileType:(unsigned long long)arg4
//{
//    id x = %orig(arg1, arg2, arg3, arg4);
//
//    NSLog(@"PAT MusicMediaProfileDetailViewController:initWithContainerEntityProvider \n\n%@\n\n\n\n%@\n\n\n\n%@\n\n\n\n%@\n\n\n\n%@\n\n",
//          x,
//          arg1,
//          arg2,
//          arg3,
//          @(arg4));
//
//    return x;
//}
//
//%end
//
//
////MusicPreviewViewController
//%hook MusicMediaProductDetailViewController
//
//-(id)initWithContainerEntityProvider:(MusicMediaEntityProvider *)arg1
//tracklistEntityProvider:(MusicMediaEntityProvider *)arg2
//clientContext:(id)arg3
//existingJSProductNativeViewController:(id)arg4
//{
//    id x = %orig(arg1, arg2, arg3, arg4);
//    
//    NSLog(@"Cello MusicMediaProductDetailViewController:initWithContainerEntityProvider \n\n%@\n\n\n\n%@\n\n\n\n%@\n\n\n\n%@\n\n\n\n%@\n\n", x,
//          arg1,
//          arg2,
//          arg3,
//          arg4);
//    
//    NSLog(@"***\n\n%@\n\n\n\n%@\n\n\n\n%@\n\n\n\n%@\n\n\n\n***",
//          arg1.mediaQuery,
//          arg1.mediaQueryDataSource.entities,
//          arg2.mediaQuery,
//          arg2.mediaQueryDataSource.entities);
//    
//    return x;
//}
//
//%end



%hook MusicContextualAddToPlaylistAlertAction

+ (id)contextualAddToPlaylistActionForEntityValueContext:(MusicEntityValueContext *)arg1
shouldDismissHandler:(/*^block*/id)arg2
additionalPresentationHandler:(/*^block*/id)arg3
didDismissHandler:(/*^block*/id)arg4
{
    id x = %orig(arg1, arg2, arg3, arg4);
    
    NSLog(@"\n\n\nx %@", x);
    NSLog(@"arg2 %@", arg2);
    NSLog(@"arg3 %@", arg3);
    NSLog(@"arg4 %@", arg4);
    NSLog(@"entityValueProvider %@", arg1.entityValueProvider);
    NSLog(@"containerEntityValueProvider %@", arg1.containerEntityValueProvider);
    NSLog(@"itemIdentifierCollection %@", arg1.itemIdentifierCollection);
    NSLog(@"containerIdentifierCollection %@\n\n\n", arg1.containerIdentifierCollection);
    
    return x;
}

%end

%hook MusicContextualPlaylistPickerViewController

- (id)initWithPlaylistSelectionHandler:(/*^block*/id)arg1
{
    id x = %orig(arg1);
    
    NSLog(@"\n\n\nx %@", x);
    NSLog(@"arg1 %@", arg1);
    
    return x;
}

%end





