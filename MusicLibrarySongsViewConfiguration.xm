//
//  MusicLibrarySongsViewConfiguration.xm
//  Cello
//
//  Created by Pat Sluth on 2015*12*27.
//
//

#import "MusicLibrarySongsViewConfiguration.h"
#import "MusicMediaEntityProvider.h"
#import "MusicEntityValueContext.h"

#import "SWCelloMediaEntityPreviewViewController.h"
#import "MusicMediaAlbumDetailViewController.h"

#import <MediaPlayer/MediaPlayer.h>
#import "MPMediaEntity+SW.h"





%hook MusicLibrarySongsViewConfiguration

- (id)previewViewControllerForEntityValueContext:(MusicEntityValueContext *)valueContext
fromViewController:(id<MusicClientContextConsuming>)viewController
{
    // the base media item
    MPMediaItem *mediaItem = ((MPMediaEntity *)[valueContext cello_isConcreteMediaItem]).representativeItem;
    
    // construct media query
    MPMediaPropertyPredicate *queryPredicate = [MPMediaPropertyPredicate predicateWithValue:@(mediaItem.albumPersistentID)
                                                                                forProperty:MPMediaItemPropertyAlbumPersistentID];
    
    
    MPMediaQuery *albumQuery = [MPMediaQuery albumsQuery];
    MPMediaQuery *titlesQuery = [MPMediaQuery songsQuery];
    
    [albumQuery addFilterPredicate:queryPredicate];
    [titlesQuery addFilterPredicate:queryPredicate];
    
    MusicMediaEntityProvider *albumProvider = [[%c(MusicMediaEntityProvider) alloc] initWithMediaQuery:albumQuery];
    MusicMediaEntityProvider *titlesProvider = [[%c(MusicMediaEntityProvider) alloc] initWithMediaQuery:titlesQuery];
    
    
    // Create our view controller without the tracklist, so it loads much faster
    UIViewController<SWCelloMediaEntityPreviewViewController> *previewViewController;
    previewViewController = [[%c(MusicMediaAlbumDetailViewController) alloc] initWithContainerEntityProvider:albumProvider
                                                                                     tracklistEntityProvider:titlesProvider
                                                                                               clientContext:viewController.clientContext
                                                                       existingJSProductNativeViewController:nil];
    
    
    
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
//    dispatch_async(queue, ^{
//        
//        // create identical view controller with full tracklist on background thread
//        UIViewController<SWCelloMediaEntityPreviewViewController> *commitViewController;
//        commitViewController = [[%c(MusicMediaAlbumDetailViewController) alloc] initWithContainerEntityProvider:albumProvider
//                                                                                        tracklistEntityProvider:titlesProvider
//                                                                                                  clientContext:viewController.clientContext
//                                                                          existingJSProductNativeViewController:nil];
//        
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            previewViewController.celloCommitViewController = commitViewController;
//        });
//    });
    
    
    return previewViewController;
}

%end




