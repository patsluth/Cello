
#import "MusicEntityProviding.h"
#import "MusicMediaQueryDataSource.h"

@class MPMediaQuery;





@interface MusicMediaEntityProvider : NSObject <MusicEntityProviding>
{
}

@property (nonatomic, readonly) MusicMediaQueryDataSource *mediaQueryDataSource;
@property (nonatomic, retain) MPMediaQuery *mediaQuery;

- (id)initWithMediaQueryDataSource:(id)arg1;
- (id)initWithMediaQuery:(id)arg1;

@end




