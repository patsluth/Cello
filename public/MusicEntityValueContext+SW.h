
#import <FuseUI/MusicEntityValueContext.h>




@interface MusicEntityValueContext(SW)
{
}

- (BOOL)cello_isActionAvailableForKey:(NSString *)key;
- (BOOL)cello_showInStoreAvailable;
- (BOOL)cello_startRadioStationAvailable;
- (BOOL)cello_upNextAvailable;
- (BOOL)cello_addToPlaylistAvailable;
- (BOOL)cello_makeAvailableOfflineAvailable;
- (BOOL)cello_removeFromPlaylistAvailable;
- (BOOL)cello_deleteAvailable;

- (/*MPMediaConcreteItem **/ id)cello_isConcreteMediaItem;
- (/*MPConcreteMediaItemCollection **/ id)cello_isConcreteMediaCollection;
- (/*MPConcreteMediaPlaylist **/ id)cello_isConcreteMediaPlaylist;

- (Class)cello_correctLibraryViewConfiguration;

- (void)log;

@end




