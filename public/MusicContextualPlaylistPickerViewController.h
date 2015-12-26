
@class MusicContextualPlaylistPickerViewConfiguration;





@interface MusicContextualPlaylistPickerViewController : UIViewController // : MusicNavigationController <MusicContextualPlaylistPickerDelegate>
{
}

@property (nonatomic, retain) NSArray *prepopulatedNewPlaylistMediaItems;

- (id)initWithPlaylistSelectionHandler:(/*^block*/id)arg1;

+ (BOOL)automaticallyInstallAccountBarButtonItem;
+ (BOOL)automaticallyInstallSearchBarButtonItem;

-(void)_dismissPlaylistPicker;
-(void)playlistPickerDidFinishWithSelectedPlaylist:(id)arg1;

@end




