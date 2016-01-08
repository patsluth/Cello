//
//  MusicLibraryBrowseTableViewController.xm
//  Cello
//
//  Created by Pat Sluth on 2015-12-21.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import "SWCelloDataSource.h"
#import "SWCelloMediaEntityPreviewViewController.h"

#import "MusicLibraryBrowseTableViewController.h"
#import "MusicProfileAlbumsViewController.h"

#import "MusicEntityValueContext.h"
#import "MusicEntityContentDescriptorViewConfiguring.h"

//TODO: Consilidate to SWCelloDataSource (UITABLEVIEW / UICOLLECTIONVIEW editing)
#import "SWCello.h"
#import "SWCelloPrefs.h"
#import "MusicCoalescingEntityValueProvider.h"





%hook MusicProfileAlbumsViewController

// make sure album views show all items
- (void)_setCollapseSections:(BOOL)arg1
{
    %orig(NO);
}

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
    self.celloDataSource = [[SWCelloDataSource alloc] initWithDelegate:self];
    
    %orig(animated);
}

- (void)viewWillDisappear:(BOOL)animated
{
    // remove our associated object
    self.celloDataSource = nil;
    
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
    
    
    if (indexPath) {
        
        CGRect cellFrame = [self.tableView rectForRowAtIndexPath:indexPath];
        CGRect headerFrame = [self.tableView rectForHeaderInSection:indexPath.section];
        
        // indexPathForRowAtPoint will return the first cell in a section even if we are touching the section
        if (!CGRectContainsPoint(cellFrame, location) && CGRectContainsPoint(headerFrame, location)) {
            //indexPath = [NSIndexPath indexPathForRow:-1 inSection:indexPath.section];
            return nil;
        }
        
        
    } else {
        
        // Have to manually check header/footer frames by iterating over them all until we find ours
        // Send indexpath with invalid row to indicate we need to check the context for the section
        for (NSUInteger section = 0; section < self.tableView.numberOfSections; section++) {
            
            UIView *sectionHeader = [self.tableView headerViewForSection:section];
            if (sectionHeader && CGRectContainsPoint(sectionHeader.frame, location)) {
                
                // we found our header
                //indexPath = [NSIndexPath indexPathForRow:-1 inSection:indexPath.section];
                return nil;
                
            }
            
        }
                  
    }
    
    
    if (indexPath) {
        return [self.celloDataSource previewViewControllerForIndexPath:indexPath];
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
    [self.celloDataSource previewingContext:previewingContext commitViewController:previewViewController];
}

#pragma mark - UITableView

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if all options are disabled then don't allow sliding
    if (self.celloDataSource.celloPrefs.upNext_slide ||
        self.celloDataSource.celloPrefs.makeAvailableOffline_slide ||
        self.celloDataSource.celloPrefs.deleteRemove_slide) {
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
    if (self.celloDataSource.celloPrefs.upNext_slide ||
        self.celloDataSource.celloPrefs.makeAvailableOffline_slide ||
        self.celloDataSource.celloPrefs.deleteRemove_slide) {
        
        id<MusicEntityValueProviding> cell = [self cello_entityValueProviderAtIndexPath:indexPath];
        
        // MusicCoalescingEntityValueProvider contains cached media properties
        if (cell && [cell isKindOfClass:%c(MusicCoalescingEntityValueProvider)]) {
            
            id baseEntityValueProvider = ((MusicCoalescingEntityValueProvider *)cell).baseEntityValueProvider;
            
            // media cell
            if ([[baseEntityValueProvider class] isSubclassOfClass:%c(MPMediaEntity)]) {
                
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
    id<MusicEntityValueProviding> entityValueProvider = [self cello_entityValueProviderAtIndexPath:indexPath];
    MusicEntityValueContext *valueContext = [self _entityValueContextAtIndexPath:indexPath];
    
    if (!entityValueProvider || !valueContext) {
        return nil;
    }
    
    
    NSMutableArray *actions = [@[] mutableCopy];
    
    
    if (self.celloDataSource.celloPrefs.upNext_slide &&
        [valueContext cello_upNextAvailable]) {
        
        UITableViewRowAction *playNextAction = [UITableViewRowAction
                                                rowActionWithStyle:UITableViewRowActionStyleNormal
                                                title:@"Play\nNext"
                                                handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                    
                                                    [self.celloDataSource performUpNextAction:SWCello_UpNextActionType_PlayNext
                                                                                 forIndexPath:indexPath];
                                                    [self.tableView setEditing:NO animated:YES];
                                                    
                                                }];
        playNextAction.backgroundColor = [UIColor colorWithRed:0.1 green:0.71 blue:1.0 alpha:1.0];
        [actions addObject:playNextAction];
        
        
        UITableViewRowAction *addToUpNextAction = [UITableViewRowAction
                                                   rowActionWithStyle:UITableViewRowActionStyleNormal
                                                   title:@"Up\nNext"
                                                   handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                       
                                                       [self.celloDataSource performUpNextAction:SWCello_UpNextActionType_AddToUpNext
                                                                                    forIndexPath:indexPath];
                                                       [self.tableView setEditing:NO animated:YES];
                                                       
                                                   }];
        addToUpNextAction.backgroundColor = [UIColor colorWithRed:0.97 green:0.58 blue:0.02 alpha:1.0];
        [actions addObject:addToUpNextAction];
        
    }
    
    
    if (self.celloDataSource.celloPrefs.makeAvailableOffline_slide &&
        [valueContext cello_makeAvailableOfflineAvailable]) {
        
        // so we know if the item is already downloaded or not
        NSNumber *keepLocal = [entityValueProvider valueForEntityProperty:@"keepLocal"];
        UITableViewRowAction *downloadAction = [UITableViewRowAction
                                                rowActionWithStyle:UITableViewRowActionStyleNormal
                                                title:(keepLocal.boolValue ? @"Remove\nDownload" : @"Download")
                                                handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                    
                                                    [CATransaction begin];
                                                    [CATransaction setCompletionBlock: ^{
                                                        [self.celloDataSource performDownloadActionForIndexPath:indexPath];
                                                    }];
                                                    [self.tableView setEditing:NO animated:YES];
                                                    [CATransaction commit];
                                                    
                                                    
                                                }];
        downloadAction.backgroundColor = [UIColor colorWithRed:0.56 green:0.27 blue:0.68 alpha:1.0];
        [actions addObject:downloadAction];
        
    }
    
    
    if (self.celloDataSource.celloPrefs.deleteRemove_slide &&
        [valueContext cello_deleteAvailable]) {
        
        UITableViewRowAction *deleteAction = [UITableViewRowAction
                                              rowActionWithStyle:UITableViewRowActionStyleDestructive
                                              title:@"Delete"
                                              handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                  
                                                  UIAlertController *deleteConfirmController = [self.celloDataSource deleteConfirmationAlertControllerForIndexPath:indexPath];
                                                  [self presentViewController:deleteConfirmController animated:YES completion:nil];
                                                  
                                              }];
        [actions addObject:deleteAction];
        
    }
    
    if (actions.count == 0) {
        return nil;
    }
    
    return [actions copy];
}

- (MusicEntityValueContext *)_entityValueContextAtIndexPath:(NSIndexPath *)indexPath
{
    MusicEntityValueContext *valueContext = nil;
    
    if (indexPath.row != -1) { // Row
        valueContext = %orig(indexPath);
    } else { // Header/Footer
        valueContext = [self _sectionEntityValueContextForIndex:indexPath.section];
    }
    
    if (valueContext) {
        
        // make sure our queries are set up correctly
        valueContext.wantsItemGlobalIndex = YES;
        valueContext.wantsItemEntityValueProvider = YES;
        valueContext.wantsContainerEntityValueProvider = YES;
        valueContext.wantsItemIdentifierCollection = YES;
        valueContext.wantsContainerIdentifierCollection = YES;
        valueContext.wantsItemPlaybackContext = YES;
        valueContext.wantsContainerPlaybackContext = YES;
        
        
        if (indexPath.row != -1) { // Row
            [self _configureEntityValueContextOutput:valueContext forIndexPath:indexPath];
         } else { // Header/Footer
            [self _configureSectionEntityValueContextOutput:valueContext forIndex:indexPath.section];
        }
        
    }
    
    return valueContext;
}

#pragma mark - Cello Additions

%new
- (id<MusicEntityValueProviding>)cello_entityValueProviderAtIndexPath:(NSIndexPath *)indexPath
{
    id cell = [self.tableView cellForRowAtIndexPath:indexPath];
    return ((id<MusicEntityContentDescriptorViewConfiguring>)cell).entityValueProvider;
}

#pragma mark - Associated Objects

%new
- (SWCelloDataSource *)celloDataSource
{
    SWCelloDataSource *dataSource = objc_getAssociatedObject(self, @selector(_celloDataSource));
    
    if (!dataSource) {
        self.celloDataSource = [[SWCelloDataSource alloc] init];
        return self.celloDataSource;
    }
    
    return dataSource;
}

%new
- (void)setCelloDataSource:(SWCelloDataSource *)celloDataSource
{
    if (celloDataSource == nil && self.celloDataSource) { // clean up notifications
        [[NSNotificationCenter defaultCenter] removeObserver:self.celloDataSource];
    }
    
    objc_setAssociatedObject(self, @selector(_celloDataSource), celloDataSource, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%end




