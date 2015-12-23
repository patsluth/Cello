
@protocol MusicEntityValueProviding;
@class MusicEntityViewContentDescriptor;





@interface MusicCoalescingEntityValueProvider : NSObject
{
}

@property (nonatomic, retain) id<MusicEntityValueProviding> baseEntityValueProvider;
@property (nonatomic, retain) MusicEntityViewContentDescriptor *contentDescriptor;

- (NSDictionary *)_cachedPropertyValues;
- (id)valueForEntityProperty:(NSString *)arg1;

// new
- (NSString *)cello_EntityNameBestGuess;

@end




