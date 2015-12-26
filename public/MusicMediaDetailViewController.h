
#import "SWCelloMediaEntityPreviewViewController.h"

@class MusicMediaDetailHeaderContentViewController;





@interface MusicMediaDetailViewController : UIViewController <SWCelloMediaEntityPreviewViewController>
{
}

@property (strong, nonatomic) UIViewController /*MusicMediaDetailHeaderContentViewController*/ *headerContentViewController;
@property (strong, nonatomic) UIViewController /*MusicMediaDetailHeaderViewController*/ *headerViewController;

@property (nonatomic, readonly) CGSize maximumHeaderSize;
- (BOOL)_updateMaximumHeaderHeight;


@end




