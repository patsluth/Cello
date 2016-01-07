
#import "MusicClientContextConsuming.h"

@class MusicEntityValueContext;





@interface MusicLibraryViewConfiguration : NSObject
{
}

- (BOOL)canPreviewEntityValueContext:(id)arg1;

- (id)previewViewControllerForEntityValueContext:(MusicEntityValueContext *)valueContext
                              fromViewController:(id<MusicClientContextConsuming>)viewController;
- (long long)handleSelectionOfEntityValueContext:(MusicEntityValueContext *)valueContext
                              fromViewController:(id<MusicClientContextConsuming>)viewController;

@end




