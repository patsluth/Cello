//
//  MusicLibraryComposersViewConfiguration.xm
//  Cello
//
//  Created by Pat Sluth on 2015*12*27.
//
//

#import "MusicLibraryComposersViewConfiguration.h"
#import "MusicEntityValueContext.h"

#import "SWCelloMediaEntityPreviewViewController.h"
#import "MusicContextualActionsHeaderViewController.h"





%hook MusicLibraryComposersViewConfiguration

- (id)previewViewControllerForEntityValueContext:(MusicEntityValueContext *)valueContext
fromViewController:(id<MusicClientContextConsuming>)viewController
{
    UIViewController<SWCelloMediaEntityPreviewViewController> *previewViewController;
    
    // I use the contextual alert header view as a preview for unsopprted media collection types (genre, composer)
    // This will simulate clicking the contextual action header view, opening the view controller for the collection
    previewViewController = [[%c(MusicContextualActionsHeaderViewController) alloc]
                             initWithEntityValueContext:valueContext
                             contextualActions:nil];
    previewViewController.view.backgroundColor = [UIColor whiteColor];
    
    
    return previewViewController;
}

%end




