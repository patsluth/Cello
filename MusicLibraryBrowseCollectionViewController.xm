//
//  MusicLibraryBrowseCollectionViewController.xm
//  Cello
//
//  Created by Pat Sluth on 2015-12-21.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import "SWCelloDataSource.h"
#import "SWCelloMediaEntityPreviewViewController.h"

#import "MusicEntityValueContext+SW.h"
#import "MusicLibraryBrowseCollectionViewController+SW.h"

#import <FuseUI/MusicEntityContentDescriptorViewConfiguring.h>
#import <FuseUI/MusicLibraryBrowseHeterogenousCollectionViewController.h>
#import <FuseUI/MusicLibrarySearchResultsViewController.h>
#import <FuseUI/MusicHUDViewController.h>






%hook MusicLibrarySearchResultsViewController

#pragma mark - UIViewControllerPreviewing

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

- (MusicEntityValueContext *)_entityValueContextAtIndexPath:(NSIndexPath *)indexPath
{
	MusicEntityValueContext *valueContext = %orig(indexPath);
	
	if (valueContext) {
		
		// make sure our playback context's are setup correctly
		valueContext.wantsItemPlaybackContext = YES;
		valueContext.wantsContainerPlaybackContext = YES;
		
	}
	
	return valueContext;
}

%end





%hook MusicLibraryBrowseHeterogenousCollectionViewController

#pragma mark - UIViewControllerPreviewing

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

#pragma mark - Init

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

#pragma mark - UIViewControllerPreviewing

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
	
	UIViewController *presentedVC = self.view.window.rootViewController.presentedViewController;
	// The root view controller displays the HUD popup instead of self (Unline MusicLibraryBrowsetableViewController)
	if (presentedVC && [presentedVC isKindOfClass:%c(MusicHUDViewController)]) {
		[(MusicHUDViewController *)presentedVC dismissAnimated:NO completion:nil];
		return nil;
	}

    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    
    if ([self.collectionView cellForItemAtIndexPath:indexPath]) {
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

- (MusicEntityValueContext *)_entityValueContextAtIndexPath:(NSIndexPath *)indexPath
{
    MusicEntityValueContext *valueContext = %orig(indexPath);
	
	if (valueContext) {
		
		// make sure our queries are set up correctly
		valueContext.wantsItemGlobalIndex = YES;
		valueContext.wantsItemEntityValueProvider = YES;
		valueContext.wantsContainerEntityValueProvider = YES;
		valueContext.wantsItemIdentifierCollection = YES;
		valueContext.wantsContainerIdentifierCollection = YES;
		valueContext.wantsItemPlaybackContext = YES;
		valueContext.wantsContainerPlaybackContext = YES;
        
    }
    
    return valueContext;
}

#pragma mark - Cello Additions

%new
- (id<MusicEntityValueProviding>)cello_entityValueProviderAtIndexPath:(NSIndexPath *)indexPath
{
    id cell = [self.collectionView cellForItemAtIndexPath:indexPath];
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




