
@interface MusicMediaDetailTintInformation : NSObject <NSCopying>
{
}

@property (nonatomic, readonly) UIColor *actionableColor;
@property (nonatomic, readonly) UIColor *backgroundColor;
@property (nonatomic, readonly) BOOL backgroundColorLight;
@property (nonatomic, readonly) UIColor *primaryTextColor;
@property (nonatomic, readonly) UIColor *separatorColor;

- (UIColor *)backgroundColor;
- (UIColor *)separatorColor;
- (void)configureJSEventDictionary:(id)arg1;
- (id)initWithArtworkColorAnalysis:(id)arg1;
- (UIColor *)actionableColor;
- (UIColor *)primaryTextColor;

@end




