//
//  MusicLibrarySearchResultsEntityProviderConfiguration.xm
//  Cello
//
//  Created by Pat Sluth on 2015-12-27.
//
//

#import <FuseUI/MusicLibrarySearchResultsEntityProviderConfiguration.h>
#import <FuseUI/MusicLibraryViewConfiguration.h>

#import "MusicEntityValueContext+SW.h"





%hook MusicLibraryViewConfiguration

- (id)previewViewControllerForEntityValueContext:(MusicEntityValueContext *)valueContext fromViewController:(id<MusicClientContextConsuming>)viewController
{
    id orig = %orig(valueContext, viewController);
    
    if (!orig) {
        
        NSArray *defaultConfigurations = [%c(MusicLibrarySearchResultsEntityProviderConfiguration) _defaultLibraryViewConfigurations];
        Class desiredConfigurationClass = [valueContext cello_correctLibraryViewConfiguration];
        
        for (MusicLibraryViewConfiguration *libraryConfiguration in defaultConfigurations) {
            if ([libraryConfiguration isKindOfClass:desiredConfigurationClass]) {
                return [libraryConfiguration previewViewControllerForEntityValueContext:valueContext fromViewController:viewController];
            }
        }
        
    }
    
    return  nil;
}

%end




