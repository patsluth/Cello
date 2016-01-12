//
//  SWCelloMusicLibraryBrowseDelegate.h
//  Cello
//
//  Created by Pat Sluth on 2015-12-25.
//
//

#ifndef SWCelloMusicLibraryBrowseDelegate_h
#define SWCelloMusicLibraryBrowseDelegate_h

#import <FuseUI/MusicClientContextConsuming.h>
#import <FuseUI/MusicLibraryViewConfigurationConsuming.h>
#import <FuseUI/MusicEntityValueProviding.h>

@class MusicEntityValueContext, SWCelloDataSource;





@protocol SWCelloMusicLibraryBrowseDelegate <MusicClientContextConsuming, MusicLibraryViewConfigurationConsuming, UIViewControllerPreviewingDelegate>

@required

@property (strong, nonatomic) SWCelloDataSource *celloDataSource;

- (UIViewController *)cello_previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location;
- (void)cello_previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit;

// Row
- (MusicEntityValueContext *)_entityValueContextAtIndexPath:(NSIndexPath *)indexPath;
- (void)_configureEntityValueContextOutput:(MusicEntityValueContext *)valueContext forIndexPath:(NSIndexPath *)indexPath;
// Header/Footer
- (MusicEntityValueContext *)_sectionEntityValueContextForIndex:(NSInteger)index;
- (void)_configureSectionEntityValueContextOutput:(MusicEntityValueContext *)valueContext forIndex:(NSInteger)index;


- (id<MusicEntityValueProviding>)cello_entityValueProviderAtIndexPath:(NSIndexPath *)indexPath;

@end

#endif /* SWCelloMusicLibraryBrowseDelegate_h */




