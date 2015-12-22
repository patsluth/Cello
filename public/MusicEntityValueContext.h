
@class MPUContentItemIdentifierCollection, MPPlaybackContext;

@protocol MusicEntityValueProviding
    - (id)valueForEntityProperty:(id)arg1;
@end





@interface MusicEntityValueContext : NSObject
{
}

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
@property (nonatomic, retain) MPPlaybackContext *itemPlaybackContext; // individual song
@property (nonatomic, retain) MPPlaybackContext *containerPlaybackContext; // album, artist, playlist, etc

- (void)resetOutputValues;

@end




