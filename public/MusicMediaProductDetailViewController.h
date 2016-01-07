
#import "MusicMediaDetailViewController.h"

@class MusicMediaEntityProvider;





@interface MusicMediaProductDetailViewController : MusicMediaDetailViewController
{
}

- (id)initWithContainerEntityProvider:(MusicMediaEntityProvider *)arg1
             tracklistEntityProvider:(MusicMediaEntityProvider *)arg2
                       clientContext:(/*MusicClientContext **/ id)arg3
existingJSProductNativeViewController:(id)arg4;

- (void)jsProductNativeViewController:(id)arg1 setTracklistItems:(id)arg2;

@end




