
@interface MPQueryPlaybackContext : NSObject // MPPlaybackContext
{
}

@property (nonatomic, readonly) MPMediaQuery *query;

+ (Class)queueFeederClass;

- (id)initWithQuery:(id)arg1;

@end




