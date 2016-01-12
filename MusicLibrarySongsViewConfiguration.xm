//
//  MusicLibrarySongsViewConfiguration.xm
//  Cello
//
//  Created by Pat Sluth on 2015-12-27.
//
//

#import <FuseUI/MusicLibrarySongsViewConfiguration.h>
#import <FuseUI/MusicMediaAlbumDetailViewController.h>
#import <FuseUI/MusicMediaEntityProvider.h>

#import "SWCelloMediaEntityPreviewViewController.h"

#import "MusicEntityValueContext+SW.h"
#import "MPMediaEntity+SW.h"

#import <MediaPlayer/MediaPlayer.h>





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
    
    return previewViewController;
}

%end




