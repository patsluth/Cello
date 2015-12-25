//
//  MusicLibraryBrowseTableViewController.xm
//  Cello
//
//  Created by Pat Sluth on 2015-12-21.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

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
#import "MusicContextualLibraryUpdateAlertAction.h"
#import "MusicContextualRemoveFromPlaylistAlertAction.h"

#import "MusicContextualActionsConfiguration.h"
#import "MusicContextualActionsHeaderViewController.h"

#import <MediaPlayer/MediaPlayer.h>




#import "MPMediaEntity+SW.h"


@protocol Cello_MusicEntityTableViewCellValueProviding
@required
@property (nonatomic,retain) id<MusicEntityValueProviding> entityValueProvider;
@end





%hook MusicLibraryBrowseTableViewController

//- (void)viewDidLoad
//{
//    %orig();
//    
//    // check device for 3D touch capability
//    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] &&
//        self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
//        
//        [self registerForPreviewingWithDelegate:self sourceView:self.tableView];
//        
//    }
//}

// peek
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    if (self.presentedViewController){
        return nil;
    }


    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    UITableViewCell<Cello_MusicEntityTableViewCellValueProviding> *cell = [self.tableView cellForRowAtIndexPath:indexPath];

    // contains cached media properties
    MusicCoalescingEntityValueProvider *coalescingEntityValueProvider;
    coalescingEntityValueProvider = (MusicCoalescingEntityValueProvider *)cell.entityValueProvider;

    if (cell) {
        
        MusicEntityValueContext *valueContext = [self cello_entityValueContextAtIndexPath:indexPath];
        
        
        //set up actions
        UIPreviewAction *playNextAction = [UIPreviewAction
                                              actionWithTitle:@"Play Next"
                                              style:UIPreviewActionStyleDefault
                                              handler:^(UIPreviewAction * _Nonnull action,
                                                        UIViewController * _Nonnull previewViewController) {

                                                  [self cello_performUpNextAction:UpNextAlertAction_PlayNext forIndexPath:indexPath];

                                              }];


        UIPreviewAction *addToUpNextAction = [UIPreviewAction
                                              actionWithTitle:@"Add to Up Next"
                                              style:UIPreviewActionStyleDefault
                                              handler:^(UIPreviewAction * _Nonnull action,
                                                        UIViewController * _Nonnull previewViewController) {

                                                  [self cello_performUpNextAction:UpNextAlertAction_AddToUpNext forIndexPath:indexPath];

                                              }];


        // so we know if the item is already downloaded or not
        NSNumber *keepLocal = [coalescingEntityValueProvider valueForEntityProperty:@"keepLocal"];
        UIPreviewAction *downloadAction = [UIPreviewAction
                                         actionWithTitle:(keepLocal.boolValue ? @"Remove Download" : @"Download")
                                         style:UIPreviewActionStyleDefault
                                         handler:^(UIPreviewAction * _Nonnull action,
                                                   UIViewController * _Nonnull previewViewController) {

                                             [self cello_performDownloadActionForIndexPath:indexPath];

                                         }];


        UIPreviewAction *deleteAction = [UIPreviewAction
                                         actionWithTitle:@"Delete"
                                         style:UIPreviewActionStyleDestructive
                                         handler:^(UIPreviewAction * _Nonnull action,
                                                   UIViewController * _Nonnull previewViewController) {

                                             UIAlertController *deleteConfirmController = [self cello_deleteConfirmationAlertController:indexPath];
                                             [self presentViewController:deleteConfirmController animated:YES completion:nil];

                                         }];
        
        
        MusicMediaDetailViewController *previewViewController = [self.libraryViewConfiguration
                                                             previewViewControllerForEntityValueContext:valueContext fromViewController:nil];
        
        if (!previewViewController) { // unsupported Media type
            previewViewController = [self cello_previewViewControllerForEntityValueContext:valueContext];
        }
        
        
        // make sure header view is layed out and set our content size to it's height
        [previewViewController.view layoutSubviews];
        previewViewController.preferredContentSize = CGSizeMake(0.0, CGRectGetHeight(previewViewController.headerContentViewController.view.bounds));
        
        previewViewController.celloPreviewActionItems = @[playNextAction, addToUpNextAction, downloadAction, deleteAction];
        
        return previewViewController;
    }

    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self showViewController:viewControllerToCommit sender:self];
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

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

%new
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell<Cello_MusicEntityTableViewCellValueProviding> *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    // contains cached media properties
    MusicCoalescingEntityValueProvider *coalescingEntityValueProvider;
    coalescingEntityValueProvider = (MusicCoalescingEntityValueProvider *)cell.entityValueProvider;
    
    
    
    UITableViewRowAction *playNextAction = [UITableViewRowAction
                                            rowActionWithStyle:UITableViewRowActionStyleNormal
                                            title:@"Play\nNext"
                                            handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                
                                                [self cello_performUpNextAction:UpNextAlertAction_PlayNext forIndexPath:indexPath];
                                                [self.tableView setEditing:NO animated:YES];
                                                
                                            }];
    
    
    UITableViewRowAction *addToUpNextAction = [UITableViewRowAction
                                          rowActionWithStyle:UITableViewRowActionStyleNormal
                                          title:@"Up\nNext"
                                          handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                              
                                              [self cello_performUpNextAction:UpNextAlertAction_AddToUpNext forIndexPath:indexPath];
                                              [self.tableView setEditing:NO animated:YES];
                                              
                                          }];
    
    
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
    
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction
                                          rowActionWithStyle:UITableViewRowActionStyleDestructive
                                          title:@"Delete"
                                          handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                              
                                              UIAlertController *deleteConfirmController = [self cello_deleteConfirmationAlertController:indexPath];
                                              [self presentViewController:deleteConfirmController animated:YES completion:nil];
                                              
                                          }];
    
    playNextAction.backgroundColor = [UIColor darkGrayColor];
    addToUpNextAction.backgroundColor = [UIColor grayColor];
    downloadAction.backgroundColor = [UIColor lightGrayColor];
    
    return @[playNextAction, addToUpNextAction, downloadAction, deleteAction];
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
- (UIViewController *)cello_previewViewControllerForEntityValueContext:(MusicEntityValueContext *)entityValueContext
{
    id provider = entityValueContext.entityValueProvider;
    MusicMediaDetailViewController *previewViewController = nil;
    // the base media item
    MPMediaItem *mediaItem = ((MPMediaEntity *)entityValueContext.entityValueProvider).representativeItem;
    
    
    if ([provider isKindOfClass:%c(MPConcreteMediaItem)]) { // song
        
        
        MPMediaPropertyPredicate *queryPredicate = [MPMediaPropertyPredicate predicateWithValue:@(mediaItem.albumPersistentID)
                                                                                    forProperty:MPMediaItemPropertyAlbumPersistentID];
        
        
        MPMediaQuery *albumQuery = [MPMediaQuery albumsQuery];
        MPMediaQuery *albumTitlesQuery = [MPMediaQuery songsQuery];
        
        [albumQuery addFilterPredicate:queryPredicate];
        [albumTitlesQuery addFilterPredicate:queryPredicate];
        
        MusicMediaEntityProvider *albumProvider = [[%c(MusicMediaEntityProvider) alloc] initWithMediaQuery:albumQuery];
        MusicMediaEntityProvider *albumTitlesTitlesProvider = [[%c(MusicMediaEntityProvider) alloc] initWithMediaQuery:albumTitlesQuery];
        
        previewViewController = [[%c(MusicMediaAlbumDetailViewController) alloc] initWithContainerEntityProvider:albumProvider
                                                                                         tracklistEntityProvider:albumTitlesTitlesProvider
                                                                                                   clientContext:self.clientContext
                                                                           existingJSProductNativeViewController:nil];
        
        
    } else if ([provider isKindOfClass:%c(MPConcreteMediaItemCollection)]) { // artist, album, genre, etc
        
        // TODO:
        
    }
    
    return previewViewController;
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









#pragma mark - Media Query View Controller Mapping DEBUG

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
//    NSLog(@"PAT initWithContainerEntityProvider \n\n%@\n\n\n\n%@\n\n\n\n%@\n\n\n\n%@\n\n\n\n%@\n\n", x, arg1, arg2, arg3, arg4);
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
//
//
//%hook MusicMediaEntityProvider
//
//- (id)initWithMediaQuery:(id)arg1
//{
//    id x = %orig(arg1);
//
//    NSLog(@"PAT MusicMediaEntityProvider:initWithMediaQuery \n\n%@\n\n%@\n\n", x, arg1);
//
//    return x;
//}
//
//%end





