
#import "MusicMediaDetailTintInformation.h"




@interface MusicMediaDetailHeaderViewController : UIViewController
{
}

@property (assign, nonatomic) double artworkFittingHeight;
@property (nonatomic, retain) UIImage *artworkImage;
// 0 = large artist header
// 1 = regular header
@property (assign, nonatomic) unsigned long long headerStyle;
@property (nonatomic, copy) MusicMediaDetailTintInformation *mediaDetailTintInformation;
//@property (assign, nonatomic, __weak) id<MusicMediaDetailHeaderViewControllerDelegate> mediaHeaderViewControllerDelegate;

- (void)_applyTintInformation;
- (void)_updateHeaderProperties;
- (double)_maximumHeaderHeightForBoundsHeight:(double)arg1;
- (id)_calculateArtworkContentBackgroundColor;
- (void)_applyHeaderStyle;
- (void)_applyHeaderLegibilityTintInformation;
- (void)_reloadContentEffectSnapshotView;
- (double)maximumMediaDetailHeaderHeightForBoundsHeight:(double)arg1 returningShouldDeferToContentViewController:(BOOL*)arg2;
- (void)setMediaDetailHeaderHeight:(double)arg1 withMaximumHeaderHeight:(double)arg2 headerVerticalOffset:(double)arg3 transitionProgress:(double)arg4;

@end




