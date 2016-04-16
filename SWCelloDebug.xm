//
//  SWCelloDebug.m
//  Cello
//
//  Created by Pat Sluth on 2015-12-27.
//
//


#import <MediaPlayer/MPArtworkCatalog.h>
#import <FuseUI/MusicMediaEntityProvider.h>
#import "MusicEntityValueContext+SW.h"

#import "libsw/libSluthware/libSluthware.h"





// Log details of system media queries for each type of media view controller
%hook MusicMediaProfileDetailViewController

- (id)initWithContainerEntityProvider:(id)arg1
clientContext:(id)arg2
existingJSProfileNativeViewController:(id)arg3
profileType:(unsigned long long)arg4
{
    id orig = %orig(arg1, arg2, arg3, arg4);
    
    LOG_METHOD_START
    NSLog(@"arg1:[%@]", arg1);
    NSLog(@"arg2:[%@]", arg2);
    NSLog(@"arg3:[%@]", arg3);
    NSLog(@"arg4:[%@]", @(arg4));
    NSLog(@"retunVal:[%@]", orig);
    LOG_METHOD_END

    return orig;
}

%end





%hook MusicMediaProductDetailViewController

- (id)initWithContainerEntityProvider:(MusicMediaEntityProvider *)arg1
tracklistEntityProvider:(MusicMediaEntityProvider *)arg2
clientContext:(id)arg3
existingJSProductNativeViewController:(id)arg4
{
    id orig = %orig(arg1, arg2, arg3, arg4);

    LOG_METHOD_START
    NSLog(@"arg1:[%@]", arg1);
    NSLog(@"arg2:[%@]", arg2);
    NSLog(@"arg3:[%@]", arg3);
    NSLog(@"arg4:[%@]", arg4);

    NSLog(@"arg1.mediaQuery:[%@]", arg1.mediaQuery);
    NSLog(@"arg1.mediaQueryDataSource.entities:[%@]", arg1.mediaQueryDataSource.entities);
    NSLog(@"arg2.mediaQuery:[%@]", arg2.mediaQuery);
    NSLog(@"arg2.mediaQueryDataSource.entities:[%@]", arg2.mediaQueryDataSource.entities);
    
    NSLog(@"retunVal:[%@]", orig);
    LOG_METHOD_END

    return orig;
}

%end





%hook MusicContextualAddToPlaylistAlertAction

+ (id)contextualAddToPlaylistActionForEntityValueContext:(MusicEntityValueContext *)arg1
shouldDismissHandler:(/*^block*/id)arg2
additionalPresentationHandler:(/*^block*/id)arg3
didDismissHandler:(/*^block*/id)arg4
{
    id orig = %orig(arg1, arg2, arg3, arg4);
    
    LOG_METHOD_START
    NSLog(@"arg1:[%@]", arg1);
    NSLog(@"arg2:[%@]", arg2);
    NSLog(@"arg3:[%@]", arg3);
    NSLog(@"arg4:[%@]", arg4);
    NSLog(@"retunVal:[%@]", orig);
    LOG_METHOD_END

    return orig;
}

%end





%hook MusicContextualPlaylistPickerViewController

- (id)initWithPlaylistSelectionHandler:(/*^block*/id)arg1
{
    id orig = %orig(arg1);

    LOG_METHOD_START
    NSLog(@"arg1:[%@]", arg1);
    NSLog(@"retunVal:[%@]", orig);
    LOG_METHOD_END

    return orig;
}

%end





%hook MusicJSNativeViewEventRegistry

- (void)registerExistingJSNativeViewController:(id)arg1 forViewController:(id)arg2
{
    LOG_METHOD_START
    NSLog(@"arg1:[%@]", arg1);
    NSLog(@"arg2:[%@]", arg2);
    LOG_METHOD_END

    %orig(arg1, arg2);
}

- (void)requestAccessToJSNativeViewControllerForViewController:(id)arg1 usingBlock:(/*^block*/id)arg2
{
    LOG_METHOD_START
    NSLog(@"arg1:[%@]", arg1);
    NSLog(@"arg2:[%@]", arg2);
    LOG_METHOD_END

    %orig(arg1, arg2);
}

- (void)dispatchNativeViewEventOfType:(long long)arg1 forViewController:(id)arg2
{
    LOG_METHOD_START
    NSLog(@"arg1:[%@]", @(arg1));
    NSLog(@"arg2:[%@]", arg2);
    LOG_METHOD_END

    %orig(arg1, arg2);
}

- (id)_existingRegisteredJSNativeViewControllerForViewController:(id)arg1
{
    id orig = %orig(arg1);

    LOG_METHOD_START
    NSLog(@"arg1:[%@]", arg1);
    NSLog(@"retunVal:[%@]", orig);
    LOG_METHOD_END

    return orig;
}

- (void)_dispatchNativeViewEventOfType:(long long)arg1
withExtraInfo:(id)arg2
forJSNativeViewController:(id)arg3
appContext:(id)arg4
jsContext:(id)arg5
completion:(/*^block*/id)arg6
{
    LOG_METHOD_START
    NSLog(@"arg1:[%@]", @(arg1));
    NSLog(@"arg2:[%@]", arg2);
    NSLog(@"arg3:[%@]", arg3);
    NSLog(@"arg4:[%@]", arg4);
    NSLog(@"arg5:[%@]", arg5);
    NSLog(@"arg6:[%@]", arg6);
    LOG_METHOD_END

    %orig(arg1, arg2, arg3, arg4, arg5, arg6);
}

- (void)_registerViewController:(id)arg1 withExistingJSNativeViewController:(id)arg2
{
    LOG_METHOD_START
    NSLog(@"arg1:[%@]", arg1);
    NSLog(@"arg2:[%@]", arg2);
    LOG_METHOD_END

    %orig(arg1, arg2);
}

%end





%hook MusicPreviewViewController

- (id)loadJSNativeViewControllerWithAppContext:(id)arg1
{
    id orig = %orig(arg1);
    
    LOG_METHOD_START
    NSLog(@"arg1:[%@]", arg1);
    NSLog(@"retunVal:[%@]", orig);
    LOG_METHOD_END
    
    return orig;
    
}

- (void)jsPreviewViewController:(id)arg1 setPreviewDocument:(id)arg2 options:(id)arg3
{
    %orig(arg1, arg2, arg3);
    
    LOG_METHOD_START
    NSLog(@"arg1:[%@]", arg1);
    NSLog(@"arg2:[%@]", arg2);
    NSLog(@"arg3:[%@]", arg3);
    LOG_METHOD_END
}

- (id)initWithPreviewIdentifier:(id)arg1 clientContext:(id)arg2
{
    id orig = %orig(arg1, arg2);
    
    LOG_METHOD_START
    NSLog(@"arg1:[%@]", arg1);
    NSLog(@"arg2:[%@]", arg2);
    NSLog(@"retunVal:[%@]", orig);
    LOG_METHOD_END
    
    return orig;
}

- (id)previewCommitViewController
{
    id orig = %orig();
    
    LOG_METHOD_START
    NSLog(@"retunVal:[%@]", orig);
    LOG_METHOD_END
    
    return orig;
}

%end





// log js media controller info
%hook MusicMediaAlbumDetailViewController

- (void)jsProductNativeViewController:(id)arg1 setProductEntityValueProviderData:(id)arg2
{
    %orig(arg1, arg2);
    
    LOG_METHOD_START
    NSLog(@"arg1:[%@]", arg1);
    NSLog(@"arg2:[%@]", arg2);
    LOG_METHOD_END
}

- (void)jsProductNativeViewController:(id)arg1 setReportingInformation:(id)arg2
{
    %orig(arg1, arg2);
    
    LOG_METHOD_START
    NSLog(@"arg1:[%@]", arg1);
    NSLog(@"arg2:[%@]", arg2);
    LOG_METHOD_END
}

- (void)jsProductNativeViewController:(id)arg1 setTracklistItems:(NSArray *)arg2
{
    %orig(arg1, arg2);
    
    LOG_METHOD_START
    NSLog(@"arg1:[%@]", arg1);
    NSLog(@"arg2:[%@]", arg2);
    LOG_METHOD_END
}

%end





%hook MusicMediaDetailHeaderViewController

- (void)setArtworkImage:(id)arg1
{
    %orig(arg1);
    
    LOG_METHOD_START
    NSLog(@"arg1:[%@]", arg1);
    LOG_METHOD_END
}

- (void)setMediaDetailTintInformation:(id)arg1
{
    %orig(arg1);
    
    LOG_METHOD_START
    NSLog(@"arg1:[%@]", arg1);
    LOG_METHOD_END
}

%end





%hook MusicMediaDetailTintInformation

- (void)configureJSEventDictionary:(id)arg1
{
    %orig(arg1);
    
    LOG_METHOD_START
    NSLog(@"arg1:[%@]", arg1);
    LOG_METHOD_END
}

- (id)initWithArtworkColorAnalysis:(id /* MPMutableArtworkColorAnalysis * */)arg1
{
    id orig = %orig(arg1);
    
    LOG_METHOD_START
    NSLog(@"arg1:[%@]", arg1);
    NSLog(@"retunVal:[%@]", orig);
    LOG_METHOD_END
    
    return orig;
}

%end





@interface MPArtworkColorAnalyzer : NSObject
{
}

@property (nonatomic, readonly) long long algorithm;
@property (nonatomic, readonly) UIImage *image;

- (id)initWithImage:(id)arg1 algorithm:(long long)arg2;
- (void)analyzeWithCompletionHandler:(/*^block*/id)arg1;
- (id)_fallbackColorAnalysis;

@end

%hook MPArtworkColorAnalyzer

- (id)initWithImage:(id)arg1 algorithm:(long long)arg2
{
	id orig = %orig(arg1, arg2);
	
	LOG_METHOD_START
	NSLog(@"arg1:[%@]", arg1);
	NSLog(@"arg2:[%@]", @(arg2));
	NSLog(@"retunVal:[%@]", orig);
	LOG_METHOD_END
	
	return orig;
}

-(void)analyzeWithCompletionHandler:(/*^block*/id)arg1
{
	%orig(arg1);
	
	LOG_METHOD_START
	NSLog(@"arg1:[%@]", arg1);
	LOG_METHOD_END
}

%end





%hook MusicColorAnalysisUtilities

+ (void)configureColorsBasedOnBackgroundColorOfArtworkCatalog:(id)arg1 usingBlock:(/*^block*/id)arg2
{
    %orig(arg1, arg2);
    
    LOG_METHOD_START
    NSLog(@"arg1:[%@]", arg1);
    NSLog(@"arg2:[%@]", arg2);
    LOG_METHOD_END
}

%end





%hook MPArtworkCatalog

- (id)initWithToken:(id)arg1 dataSource:(id)arg2
{
	id orig = %orig(arg1, arg2);
	
	LOG_METHOD_START
	NSLog(@"arg1:[%@]", arg1);
	NSLog(@"arg2:[%@]", arg2);
	NSLog(@"retunVal:[%@]", orig);
	LOG_METHOD_END
	
	return orig;
}

+ (id)staticArtworkCatalogWithImage:(id)arg1
{
	id orig = %orig(arg1);
	
	LOG_METHOD_START
	NSLog(@"arg1:[%@]", arg1);
	NSLog(@"retunVal:[%@]", orig);
	LOG_METHOD_END
	
	return orig;
}

- (void)requestColorAnalysisWithAlgorithm:(int)arg1 completionHandler:(id /* block */)arg2
{
	%orig(arg1, arg2);
	
	LOG_METHOD_START
	NSLog(@"arg1:[%@]", @(arg1));
	NSLog(@"arg2:[%@]", arg2);
	LOG_METHOD_END
}

%end


















%hook MusicLibraryArtistsViewConfiguration

- (long long)handleSelectionOfEntityValueContext:(id)arg1 fromViewController:(id)arg2
{
    long long orig = %orig(arg1, arg2);
    
    LOG_METHOD_START
    NSLog(@"arg1:[%@]", arg1);
    NSLog(@"arg2:[%@]", arg2);
    NSLog(@"retunVal:[%@]", @(orig));
    LOG_METHOD_END
    
    return orig;
}

- (long long)handleSelectionFromUserActivityContext:(id)arg1 containerItem:(id)arg2 entityValueContext:(id)arg3 viewController:(id)arg4
{
    long long orig = %orig(arg1, arg2, arg3, arg4);
    
    LOG_METHOD_START
    NSLog(@"arg1:[%@]", arg1);
    NSLog(@"arg2:[%@]", arg2);
    NSLog(@"arg2:[%@]", arg3);
    NSLog(@"arg2:[%@]", arg4);
    NSLog(@"retunVal:[%@]", @(orig));
    LOG_METHOD_END
    
    return orig;
}

%end





%hook MusicCoalescingEntityValueProvider

- (id)imageURLForEntityArtworkProperty:(id)arg1 fittingSize:(CGSize)arg2 destinationScale:(CGFloat)arg3
{
	id orig = %orig(arg1, arg2, arg3);
	
	LOG_METHOD_START
	NSLog(@"arg1:[%@]", arg1);
	NSLog(@"arg2:[%@]", NSStringFromCGSize(arg2));
	NSLog(@"arg2:[%@]", @(arg3));
	NSLog(@"retunVal:[%@]", orig);
	LOG_METHOD_END
	
	return orig;
}



%end




