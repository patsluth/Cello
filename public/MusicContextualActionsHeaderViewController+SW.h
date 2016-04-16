
#import <FuseUI/MusicContextualActionsHeaderViewController.h>
#import "SWCelloMediaEntityPreviewViewController.h"





@interface MusicContextualActionsHeaderViewController(SW) <SWCelloMediaEntityPreviewViewController>
{
}

@property (strong, nonatomic) NSIndexPath *celloPreviewIndexPath;
@property (strong, nonatomic) NSArray<id<UIPreviewActionItem>> *celloPreviewActionItems;

@end




