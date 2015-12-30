//
//  SWCelloDebug.m
//  Cello
//
//  Created by Pat Sluth on 2015*12*27.
//
//

#import "MusicMediaEntityProvider.h"
#import "MusicEntityValueContext.h"

#define LOG_METHOD_START NSLog(@"");NSLog(@"");NSLog(@"****************************************************************"); \
                         NSLog(@"[%@]", NSStringFromClass([((id)self) class])); \
                         NSLog(@"%@]", NSStringFromSelector(_cmd)); \
                         NSLog(@"----------------------------------------------------------------");
#define LOG_METHOD_END   NSLog(@"****************************************************************");NSLog(@"");NSLog(@"");





// log details of system media queries for each type of media view controller
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

- (id)initWithArtworkColorAnalysis:(id)arg1
{
    id orig = %orig(arg1);
    
    LOG_METHOD_START
    NSLog(@"arg1:[%@]", arg1);
    NSLog(@"retunVal:[%@]", orig);
    LOG_METHOD_END
    
    return orig;
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




