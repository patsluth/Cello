
#import "MusicEntityValueProviding.h"

@class MusicEntityViewContentDescriptor;





@interface MusicCoalescingEntityValueProvider : NSObject <MusicEntityValueProviding>
{
}

@property (nonatomic, retain) id<MusicEntityValueProviding> baseEntityValueProvider;
@property (nonatomic, retain) MusicEntityViewContentDescriptor *contentDescriptor;

- (NSDictionary *)_cachedPropertyValues;
- (id)imageURLForEntityArtworkProperty:(id)arg1 fittingSize:(CGSize)arg2 destinationScale:(double)arg3;

- (NSString *)cello_EntityNameBestGuess;

@end




