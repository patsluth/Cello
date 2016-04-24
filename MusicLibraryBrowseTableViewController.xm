//
//  MusicLibraryBrowseTableViewController.xm
//  Cello
//
//  Created by Pat Sluth on 2015-12-21.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import "SWCelloDataSource.h"
#import "SWCelloMediaEntityPreviewViewController.h"

#import "MusicEntityValueContext+SW.h"
#import "MusicLibraryBrowseTableViewController+SW.h"

#import <FuseUI/MusicEntityContentDescriptorViewConfiguring.h>
#import <FuseUI/MusicProfileAlbumsViewController.h>
#import <FuseUI/MusicHUDViewController.h>

//TODO: Consilidate to SWCelloDataSource (UITABLEVIEW / UICOLLECTIONVIEW editing)
#import "SWCello.h"
#import "SWCelloPrefs.h"
#import <FuseUI/MusicCoalescingEntityValueProvider.h>






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
        
        if ([self.presentedViewController isKindOfClass:%c(MusicHUDViewController)]) {
            [(MusicHUDViewController *)self.presentedViewController dismissAnimated:NO completion:nil];
        }
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

// pop
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
    if (self.celloDataSource.celloPrefs.contextualActionsSlide.count > 0) {
        return YES;
    } else {
        return %orig(tableView, indexPath);
    }
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if all options are disabled then don't allow sliding
    if (self.celloDataSource.celloPrefs.contextualActionsSlide.count > 0) {
        
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
    NSArray *actions = [self.celloDataSource availableActionsForIndexPath:indexPath actionClass:[UITableViewRowAction class]];
    
    if (actions.count == 0) {
        return nil;
    }
    
    return actions;
}

- (MusicEntityValueContext *)_entityValueContextAtIndexPath:(NSIndexPath *)indexPath
{
    MusicEntityValueContext *valueContext = nil;
    
//    if (indexPath.row != -1) { // Row
        valueContext = %orig(indexPath);
//    } else { // Header/Footer
//        valueContext = [self _sectionEntityValueContextForIndex:indexPath.section];
//    }
	
    if (valueContext) {
		
		//[valueContext resetOutputValues];
        
        // make sure our queries are set up correctly
        valueContext.wantsItemGlobalIndex = YES;
        valueContext.wantsItemEntityValueProvider = YES;
        valueContext.wantsContainerEntityValueProvider = YES;
        valueContext.wantsItemIdentifierCollection = YES;
        valueContext.wantsContainerIdentifierCollection = YES;
        valueContext.wantsItemPlaybackContext = YES;
        valueContext.wantsContainerPlaybackContext = YES;
        
        
//        if (indexPath.row != -1) { // Row
//            [self _configureEntityValueContextOutput:valueContext forIndexPath:indexPath];
//         } else { // Header/Footer
//            [self _configureSectionEntityValueContextOutput:valueContext forIndex:indexPath.section];
//        }
		
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
		[NSObject cancelPreviousPerformRequestsWithTarget:self.celloDataSource];
        [[NSNotificationCenter defaultCenter] removeObserver:self.celloDataSource];
    }
    
    objc_setAssociatedObject(self, @selector(_celloDataSource), celloDataSource, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%end




