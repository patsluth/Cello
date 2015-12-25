
@class MusicMediaDetailHeaderContentViewController;





@interface MusicMediaDetailViewController : UIViewController
{
}

@property (strong, nonatomic) UIViewController /*MusicMediaDetailHeaderContentViewController*/ *headerContentViewController;
@property (strong, nonatomic) UIViewController /*MusicMediaDetailHeaderViewController*/ *headerViewController;

@property (nonatomic, readonly) CGSize maximumHeaderSize;
-(id)_loadProductHeaderContentViewController;
-(id)_loadDetailHeaderConfiguration;

// cello addition
@property (strong, nonatomic) NSArray<id<UIPreviewActionItem>> *celloPreviewActionItems;


@end




