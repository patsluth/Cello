//
//  MusicLibraryBrowseTableViewController.xm
//  Cello
//
//  Created by Pat Sluth on 2015-12-21.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import "MusicCoalescingEntityValueProvider.h"
#import "MusicEntityValueContext.h"

#import "MusicContextualUpNextAlertAction.h"
#import "MusicContextualLibraryUpdateAlertAction.h"
#import "MusicContextualRemoveFromPlaylistAlertAction.h"

#import "MusicContextualActionsConfiguration.h"
#import "MusicContextualActionsHeaderViewController.h"

typedef enum {
    UpNextAlertAction_PlayNext = 0,
    UpNextAlertAction_AddToUpNext = 1
} UpNextAlertAction_Type;
















@interface MusicLibraryViewConfiguration : NSObject {
}

@property (nonatomic,copy) NSString * iconName;
@property (nonatomic,copy) NSString * identifier;
@property (nonatomic,copy) NSString * title;
@property (nonatomic,copy) NSArray * userActivityItemTypes;
@property (nonatomic,retain) Class viewControllerClass;
@property (nonatomic,readonly) BOOL wantsVisualIndicationOfSelection;
@property (assign,nonatomic) BOOL supportsSplitView;
@property (assign,nonatomic) BOOL wantsImmediateHandlingOfEditingChangeRecords;
//@property (nonatomic,readonly) MusicEntityViewDescriptor * entityViewDescriptor;
-(void)setIconName:(NSString *)arg1 ;
-(NSString *)iconName;
-(void)setTitle:(NSString *)arg1 ;
-(NSString *)identifier;
-(NSString *)title;
-(id)newViewController;
-(id)loadEntityViewDescriptor;


-(long long)handleSelectionOfEntityValueContext:(id)arg1 fromViewController:(id)arg2 ;


-(BOOL)canDeleteEntityValueContext:(id)arg1 ;
-(long long)handleSelectionFromUserActivityContext:(id)arg1 containerItem:(id)arg2 entityValueContext:(id)arg3 viewController:(id)arg4 ;
-(BOOL)canPreviewEntityValueContext:(id)arg1 ;
-(id)previewViewControllerForEntityValueContext:(id)arg1 fromViewController:(id)arg2 ;
-(void)handleCommitPreviewViewController:(id)arg1 fromViewController:(id)arg2 ;
-(BOOL)canMoveEntityValueContext:(id)arg1 ;
@end

@interface MusicLibrarySongsViewConfiguration : MusicLibraryViewConfiguration {
}

-(long long)handleSelectionOfEntityValueContext:(id)arg1 fromViewController:(id)arg2 ;
@end


//%hook MusicLibraryViewConfiguration
//
//-(BOOL)canPreviewEntityValueContext:(id)arg1
//{
//    BOOL x = %orig(arg1);
//    
//    NSLog(@"PAT canPreviewEntityValueContext \n%@\n%@\n", @(x), arg1);
//    
//    return YES;
//}
//
//-(id)previewViewControllerForEntityValueContext:(id)arg1 fromViewController:(id)arg2
//{
//    id x = %orig(arg1, arg2);
//    
//    NSLog(@"PAT previewViewControllerForEntityValueContext \n%@\n%@\n%@\n", x, arg1, arg2);
//    
//    return x;
//}
//
//%end
















@protocol Cello_MusicEntityTableViewCellValueProviding
@required
@property (nonatomic,retain) id<MusicEntityValueProviding> entityValueProvider;
@end





@interface MusicLibraryBrowseTableViewController : UITableViewController <UIViewControllerPreviewingDelegate>
{
}

@property (nonatomic,readonly) MusicLibraryViewConfiguration * libraryViewConfiguration;

@property (strong, nonatomic) /*MusicClientContext*/ id clientContext;
@property (strong, nonatomic) /*MusicTableView*/ UITableView *tableView;

- (id)_entityValueContextAtIndexPath:(id)arg1;
- (void)_configureEntityValueContextOutput:(id)arg1 forIndexPath:(id)arg2;

// handles configuring required fields
- (id)cello_entityValueContextAtIndexPath:(NSIndexPath *)indexPath;
- (void)cello_performUpNextAction:(UpNextAlertAction_Type)actionType forIndexPath:(NSIndexPath *)indexPath;
- (void)cello_performDownloadActionForIndexPath:(NSIndexPath *)indexPath;
- (void)cello_performRemoveFromPlaylistActionForIndexPath:(NSIndexPath *)indexPath;
- (UIAlertController *)cello_deleteConfirmationAlertController:(NSIndexPath *)indexPath;

@end











//@interface MusicMediaProductDetailViewController : UIViewController
//
//-(id)initWithContainerEntityProvider:(id)arg1
//tracklistEntityProvider:(id)arg2
//clientContext:(id)arg3
//existingJSProductNativeViewController:(id)arg4;
//
//@end;
//
////MusicPreviewViewController
//%hook MusicMediaProductDetailViewController
//
//-(id)initWithContainerEntityProvider:(id)arg1
//tracklistEntityProvider:(id)arg2
//clientContext:(id)arg3
//existingJSProductNativeViewController:(id)arg4
//{
//    id x = %orig(arg1, arg2, arg3, arg4);
//    
//    NSLog(@"PAT initWithContainerEntityProvider \n\n%@\n\n\n\n%@\n\n\n\n%@\n\n\n\n%@\n\n\n\n%@\n\n", x, arg1, arg2, arg3, arg4);
//    
//    return x;
//}
//
//-(BOOL)_shouldAutomaticallyPopForMissingContainerEntityValueProvider
//{
//    return YES;
//}
//
//%end































%hook MusicLibraryBrowseTableViewController

- (void)viewDidLoad
{
    %orig();
    
    // check device for 3D touch capability
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] &&
        self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        
        [self registerForPreviewingWithDelegate:self sourceView:self.tableView];
        
    }
}

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
    
    
    MusicContextualActionsHeaderViewController *controller = nil;
    
    
    if (cell) {
        
        //previewingContext.sourceRect = cell.frame;
        MusicEntityValueContext *valueContext = [self cello_entityValueContextAtIndexPath:indexPath];
        
        //default controller
       // UIViewController *x = [self.libraryViewConfiguration previewViewControllerForEntityValueContext:valueContext fromViewController:self];
        
        
        
        controller = [[%c(MusicContextualActionsHeaderViewController) alloc] initWithEntityValueContext:valueContext
                                                                                      contextualActions:nil];
        controller.view.backgroundColor = [UIColor whiteColor];
        
        
        
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
        
        controller.celloPreviewActionItems = @[playNextAction, addToUpNextAction, downloadAction, deleteAction];
    }
    
    return controller;
}

// pop
- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    MusicContextualActionsHeaderViewController *controller = (MusicContextualActionsHeaderViewController *)viewControllerToCommit;
    
    // Dirty hack to simulate tapping on the header view
    MusicContextualActionsConfiguration *tempConfig = [[%c(MusicContextualActionsConfiguration) alloc] init];
    
    // Set up a new MusicActionAlertController and select the header
    tempConfig.entityValueContext = controller.entityValueContext;
    [tempConfig _didSelectHeaderFromAlertController:[tempConfig newViewController]];
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
    
    
    
//    playNextButton.backgroundColor = [UIColor colorWithRed:0.1 green:0.71 blue:1.0 alpha:1.0];
//    addToUpNextButton.backgroundColor = [UIColor colorWithRed:0.97 green:0.58 blue:0.02 alpha:1.0];
//    downloadButton.backgroundColor = [UIColor colorWithRed:0.56 green:0.27 blue:0.68 alpha:1.0];
    
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




