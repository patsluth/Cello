//
//  SWCelloDebug.m
//  Cello
//
//  Created by Pat Sluth on 2015-12-27.
//
//

#import "MusicMediaAlbumDetailViewController.h"




@interface MusicPreviewViewController : UIViewController
//<MusicJSNativeViewControllerFactory, MusicJSPreviewViewControllerDelegate, SKUINavigationBarDisplayConfiguring, SKUIViewControllerPreviewing>
{

//NSString* _previewIdentifier;

//SKUIDocumentContainerViewController* _previewDocumentViewController;

}

//@property (nonatomic,retain) SKUIClientContext * clientContext;

- (id)loadJSNativeViewControllerWithAppContext:(id)arg1;
- (void)jsPreviewViewController:(id)arg1 setPreviewDocument:(id)arg2 options:(id)arg3;
- (id)initWithPreviewIdentifier:(id)arg1 clientContext:(id)arg2;
- (id)previewCommitViewController;

@end

%hook MusicPreviewViewController

- (id)loadJSNativeViewControllerWithAppContext:(id)arg1
{
    id orig = %orig(arg1);
    
    NSLog(@"");NSLog(@"--------------------------------");
    NSLog(@"%@", NSStringFromClass(self.class));
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSLog(@"--------------------------------");
    NSLog(@"arg1:[%@]", arg1);
    NSLog(@"retunVal:[%@]", orig);
    NSLog(@"--------------------------------");NSLog(@"");
    
    return orig;
    
}

- (void)jsPreviewViewController:(id)arg1 setPreviewDocument:(id)arg2 options:(id)arg3
{
    %orig(arg1, arg2, arg3);
    
    NSLog(@"");NSLog(@"--------------------------------");
    NSLog(@"%@", NSStringFromClass(self.class));
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSLog(@"--------------------------------");
    NSLog(@"arg1:[%@]", arg1);
    NSLog(@"arg2:[%@]", arg2);
    NSLog(@"arg3:[%@]", arg3);
    NSLog(@"--------------------------------");NSLog(@"");
}

- (id)initWithPreviewIdentifier:(id)arg1 clientContext:(id)arg2
{
    id orig = %orig(arg1, arg2);
    
    NSLog(@"");NSLog(@"--------------------------------");
    NSLog(@"%@", NSStringFromClass(self.class));
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSLog(@"--------------------------------");
    NSLog(@"arg1:[%@]", arg1);
    NSLog(@"arg2:[%@]", arg2);
    NSLog(@"retunVal:[%@]", orig);
    NSLog(@"--------------------------------");NSLog(@"");
    
    return orig;
}

- (id)previewCommitViewController
{
    id orig = %orig();
    
    NSLog(@"");NSLog(@"--------------------------------");
    NSLog(@"%@", NSStringFromClass(self.class));
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSLog(@"--------------------------------");
    NSLog(@"retunVal:[%@]", orig);
    NSLog(@"--------------------------------");NSLog(@"");
    
    return orig;
}

%end














%hook MusicMediaAlbumDetailViewController

- (void)jsProductNativeViewController:(id)arg1 setProductEntityValueProviderData:(id)arg2
{
    %orig(arg1, arg2);
    
    NSLog(@"");NSLog(@"--------------------------------");
    NSLog(@"%@", NSStringFromClass(self.class));
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSLog(@"--------------------------------");
    NSLog(@"arg1:[%@]", arg1);
    NSLog(@"arg2:[%@]", arg2);
    NSLog(@"--------------------------------");NSLog(@"");
}

- (void)jsProductNativeViewController:(id)arg1 setReportingInformation:(id)arg2
{
    %orig(arg1, arg2);
    
    NSLog(@"");NSLog(@"--------------------------------");
    NSLog(@"%@", NSStringFromClass(self.class));
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSLog(@"--------------------------------");
    NSLog(@"arg1:[%@]", arg1);
    NSLog(@"arg2:[%@]", arg2);
    NSLog(@"--------------------------------");NSLog(@"");
}

- (void)jsProductNativeViewController:(id)arg1 setTracklistItems:(NSArray *)arg2
{
    %orig(arg1, arg2);
    
    NSLog(@"");NSLog(@"--------------------------------");
    NSLog(@"%@", NSStringFromClass(self.class));
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSLog(@"--------------------------------");
    NSLog(@"arg1:[%@]", arg1);
    NSLog(@"arg2:[%@]", arg2);
    NSLog(@"--------------------------------");NSLog(@"");
}

%end






