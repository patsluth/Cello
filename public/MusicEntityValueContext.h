
#import "MusicEntityValueProviding.h"

@class MPUContentItemIdentifierCollection, MPPlaybackContext, MPQueryPlaybackContext;





@interface MusicEntityValueContext : NSObject
{
}

- (void)configureWithMediaEntity:(id)arg1;

@property (assign,nonatomic) BOOL wantsItemGlobalIndex;
@property (assign,nonatomic) BOOL wantsItemEntityValueProvider;
@property (assign,nonatomic) BOOL wantsContainerEntityValueProvider;
@property (assign,nonatomic) BOOL wantsItemIdentifierCollection;
@property (assign,nonatomic) BOOL wantsContainerIdentifierCollection;
@property (assign,nonatomic) BOOL wantsItemPlaybackContext;
@property (assign,nonatomic) BOOL wantsContainerPlaybackContext;

@property (assign,nonatomic) unsigned long long itemGlobalIndex;
@property (nonatomic, readonly) id<MusicEntityValueProviding> entityValueProvider;
@property (nonatomic, retain) id<MusicEntityValueProviding> containerEntityValueProvider;
@property (nonatomic, copy) MPUContentItemIdentifierCollection *itemIdentifierCollection;
@property (nonatomic, copy) MPUContentItemIdentifierCollection *containerIdentifierCollection;
@property (nonatomic, retain) MPQueryPlaybackContext *itemPlaybackContext; // individual song
@property (nonatomic, retain) MPQueryPlaybackContext *containerPlaybackContext; // album, artist, playlist, etc

- (void)resetOutputValues;

// Cello additions
- (BOOL)showInStoreAvailable;
- (BOOL)startRadioStationAvailable;
- (BOOL)upNextAvailable;
- (BOOL)addToPlaylistAvailable;
- (BOOL)makeAvailableOfflineAvailable;
- (BOOL)removeFromPlaylistAvailable;
- (BOOL)deleteAvailable;

- (/*MPMediaConcreteItem **/ id)isConcreteMediaItem;
- (/*MPConcreteMediaItemCollection **/ id)isConcreteMediaCollection;
- (/*MPConcreteMediaPlaylist **/ id)isConcreteMediaPlaylist;

- (void)log;

@end




