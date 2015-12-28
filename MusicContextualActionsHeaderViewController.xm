//
//  MusicContextualActionsHeaderViewController.xm
//  Cello
//
//  Created by Pat Sluth on 2015-12-23.
//
//

#import "MusicContextualActionsHeaderViewController.h"





%hook MusicContextualActionsHeaderViewController

%new
- (NSIndexPath *)celloPreviewIndexPath
{
    return objc_getAssociatedObject(self, @selector(_celloPreviewIndexPath));
}

%new
- (void)setCelloPreviewIndexPath:(NSIndexPath *)celloPreviewIndexPath
{
    objc_setAssociatedObject(self, @selector(_celloPreviewIndexPath), celloPreviewIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (NSArray<id<UIPreviewActionItem>> *)celloPreviewActionItems
{
    return objc_getAssociatedObject(self, @selector(_celloPreviewActionItems));
}

%new
- (void)setCelloPreviewActionItems:(NSArray<id<UIPreviewActionItem>> *)celloPreviewActionItems
{
    objc_setAssociatedObject(self, @selector(_celloPreviewActionItems), celloPreviewActionItems, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)viewWillDisappear:(BOOL)animated
{
    %orig(animated);
    
    // remove our associated object
    self.celloPreviewActionItems = nil;
}

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems
{
    return self.celloPreviewActionItems;
}

%end




