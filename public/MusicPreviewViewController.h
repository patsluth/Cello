
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




