
@class MusicEntityViewContentDescriptor;




@protocol MusicEntityContentDescriptorViewConfiguring <NSObject>

@property (nonatomic, retain) MusicEntityViewContentDescriptor *contentDescriptor;
@property (nonatomic, retain) id<MusicEntityValueProviding> entityValueProvider;

@end




