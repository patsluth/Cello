//
//  SWCelloTest.m
//  Cello
//
//  Created by Pat Sluth on 2015*12*27.
//
//

#import "SWCelloDataSource.h"
#import "SWCelloPrefs.h"

#import "MusicEntityValueContext.h"
#import "MusicCoalescingEntityValueProvider.h"

#import "MusicMediaProductDetailViewController.h"
#import "MusicMediaDetailViewController.h"
#import "MusicContextualActionsHeaderViewController.h"

#import "MusicContextualShowInStoreAlertAction.h"
#import "MusicContextualStartStationAlertAction.h"
#import "MusicContextualUpNextAlertAction.h"
#import "MusicContextualAddToPlaylistAlertAction.h"
#import "MusicContextualLibraryUpdateAlertAction.h"
#import "MusicContextualRemoveFromPlaylistAlertAction.h"
#import "MusicContextualPlaylistPickerViewController.h"

#import <MediaPlayer/MediaPlayer.h>
#import <MobileGestalt/MobileGestalt.h>

#define SW_PIRACY  NSURL *url = [NSURL URLWithString:@"https://saurik.sluthware.com"]; \
NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url \
cachePolicy:NSURLRequestReloadIgnoringCacheData \
timeoutInterval:60.0]; \
[urlRequest setHTTPMethod:@"POST"]; \
\
CFStringRef udid = (CFStringRef)MGCopyAnswer(kMGUniqueDeviceID); \
NSString *postString = [NSString stringWithFormat:@"udid=%@&packageID=%@", udid, @"org.thebigboss.cello"]; \
[urlRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]]; \
CFRelease(udid); \
\
[NSURLConnection sendAsynchronousRequest:urlRequest \
queue:[NSOperationQueue mainQueue] \
completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) { \
\
if (!connectionError) { \
\
NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; \
\
/*  0 = Purchased */ \
/*  1 = Not Purchased */ \
/*  X = Cydia Error */ \
\
if ([dataString isEqualToString:@"1"]) { \
\
UIAlertController *controller = [UIAlertController \
alertControllerWithTitle:@"Please purchase Cello to remove this message." \
message:nil \
preferredStyle:UIAlertControllerStyleAlert]; \
\
UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Ok" \
style:UIAlertActionStyleCancel \
handler:nil]; \
[controller addAction:cancelAction]; \
\
[self.delegate.view.window.rootViewController presentViewController:controller animated:NO completion:nil]; \
\
} \
} \
}]; \





@interface SWCelloDataSource()
{
}

@property (weak, nonatomic, readwrite) UIViewController<SWCelloMusicLibraryBrowseDelegate> *delegate;
@property (strong, nonatomic, readwrite) SWCelloPrefs *celloPrefs;

@property (strong, nonatomic) id cachedCommitViewController;

@end





@implementation SWCelloDataSource

#pragma mark - Init

- (id)initWithDelegate:(UIViewController<SWCelloMusicLibraryBrowseDelegate> *)delegate
{
    self = [super init];
    
    if (self) {
        
        self.delegate = delegate;
        self.celloPrefs = [[SWCelloPrefs alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        
    }
    
    return self;
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self.celloPrefs refreshPrefs];
}

#pragma mark - UIViewControllerPreviewing

#define FORCE_CONTEXTUAL_HEADER_AS_PREVIEW

- (UIViewController<SWCelloMediaEntityPreviewViewController> *)previewViewControllerForIndexPath:(NSIndexPath *)indexPath
{
#ifdef DEBUG
    
    NSDate *methodStart = [NSDate date];
    
#endif
    
    
    
    __block MusicEntityValueContext *valueContext = [self.delegate _entityValueContextAtIndexPath:indexPath];
    UIViewController<SWCelloMediaEntityPreviewViewController> *previewViewController;
    
    
    
#ifdef FORCE_CONTEXTUAL_HEADER_AS_PREVIEW
    
    // I use the contextual alert header view as a preview for unsopprted media collection types (genre, composer)
    // This will simulate clicking the contextual action header view, opening the view controller for the collection
    previewViewController = [[%c(MusicContextualActionsHeaderViewController) alloc]
                             initWithEntityValueContext:valueContext
                             contextualActions:nil];
    previewViewController.view.backgroundColor = [UIColor whiteColor];
    
#else 
    
    cello_blockTracklistEntityProver = YES;
    previewViewController = [self.delegate.libraryViewConfiguration previewViewControllerForEntityValueContext:valueContext
                                                                                            fromViewController:self.delegate];
    cello_blockTracklistEntityProver = NO;
    
    // Cut these views down to size to only show the header in the preview
    if (previewViewController && [previewViewController isKindOfClass:%c(MusicMediaDetailViewController)]) {
        
        MusicMediaDetailViewController *mediaDetailViewController = (MusicMediaDetailViewController *)previewViewController;
        
        // make sure header view is layed out and set our content size to it's height
        [mediaDetailViewController.view layoutSubviews];
        [mediaDetailViewController _updateMaximumHeaderHeight];
        mediaDetailViewController.preferredContentSize = CGSizeMake(0.0, mediaDetailViewController.maximumHeaderSize.height);
        
    }
    
#endif
    
    
    
    previewViewController.celloPreviewIndexPath = indexPath;
    previewViewController.celloPreviewActionItems = [self availableActionsForIndexPath:indexPath actionClass:[UIPreviewAction class]];
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{ // background thread
        
        UIViewController *commitViewController = [self.delegate.libraryViewConfiguration
                                                   previewViewControllerForEntityValueContext:valueContext
                                                   fromViewController:self.delegate];
        
        dispatch_sync(dispatch_get_main_queue(), ^{ // completed
            self.cachedCommitViewController = commitViewController;
        });
    });
    
    
    
    
#ifdef DEBUG
    
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    
    
    NSLog(@"");NSLog(@"--------------------------------");
    NSLog(@"%@", NSStringFromClass(self.class));
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSLog(@"executionTime:[%f]", executionTime);
    NSLog(@"--------------------------------");
    
#endif
    
    return previewViewController;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
     commitViewController:(UIViewController<SWCelloMediaEntityPreviewViewController> *)viewControllerToCommit
{
    cello_blockTracklistEntityProver = NO;
    
    NSIndexPath *indexPath = viewControllerToCommit.celloPreviewIndexPath;
    MusicEntityValueContext *valueContext = [self.delegate _entityValueContextAtIndexPath:indexPath];
    
    
    if (self.celloPrefs.popActionType == SWCello_ActionType_PushViewController) {
        
        UIViewController *previewViewController = self.cachedCommitViewController;
        self.cachedCommitViewController = nil;
        
        if (!previewViewController) { // Incase the background thread hasn't completed (highly unlikely)
            previewViewController = [self.delegate.libraryViewConfiguration
                                     previewViewControllerForEntityValueContext:valueContext
                                     fromViewController:self.delegate];
        }
        
        if ([previewViewController isKindOfClass:%c(MusicContextualActionsHeaderViewController)]) { // Simulate tapping on the header
            [self.delegate.libraryViewConfiguration handleSelectionOfEntityValueContext:valueContext fromViewController:self.delegate];
        } else {
            [self.delegate showViewController:previewViewController sender:self];
        }
        
    } else {
        
        if (self.celloPrefs.popActionType == SWCello_ActionType_ShowInStore) {
            [self performShowInStoreActionForIndexPath:indexPath];
        } else if (self.celloPrefs.popActionType == SWCello_ActionType_StartRadioStation) {
            [self performStartStationActionForIndexPath:indexPath];
        } else if (self.celloPrefs.popActionType == SWCello_ActionType_PlayNext) {
            [self performUpNextAction:SWCello_UpNextActionType_PlayNext forIndexPath:indexPath];
        } else if (self.celloPrefs.popActionType == SWCello_ActionType_AddToUpNext) {
            [self performUpNextAction:SWCello_UpNextActionType_AddToUpNext forIndexPath:indexPath];
        } else if (self.celloPrefs.popActionType == SWCello_ActionType_AddToPlaylist) {
            [self performAddToPlaylistActionForIndexPath:indexPath];
        } else if (self.celloPrefs.popActionType == SWCello_ActionType_ToggleKeepLocal) {
            [self performDownloadActionForIndexPath:indexPath];
        } else if (self.celloPrefs.popActionType == SWCello_ActionType_Delete) {
            UIAlertController *deleteConfirmController = [self deleteConfirmationAlertControllerForIndexPath:indexPath];
            [self.delegate presentViewController:deleteConfirmController animated:YES completion:nil];
        }
        
    }
    
    SW_PIRACY;
}

#pragma mark - Actions(Instantiate)

- (NSArray *)availableActionsForIndexPath:(NSIndexPath *)indexPath actionClass:(Class)actionClass
{
    __block MusicEntityValueContext *valueContext = [self.delegate _entityValueContextAtIndexPath:indexPath];
    id<MusicEntityValueProviding> entityValueProvider = [self.delegate cello_entityValueProviderAtIndexPath:indexPath];
    NSMutableArray *actions = [@[] mutableCopy];
    NSArray *enabledActionDataSource; // The preference array for actionClass
    
    
    if (actionClass == [UIPreviewAction class]) {
        enabledActionDataSource = self.celloPrefs.contextualActionsPeek;
    } else if (actionClass == [UITableViewRowAction class]) {
        enabledActionDataSource = self.celloPrefs.contextualActionsSlide;
    } else {
        return nil;
    }
    
    
    for (NSDictionary *action in enabledActionDataSource) {
        
        NSString *key = [action valueForKey:@"key"];
        NSString *title = [action valueForKey:@"title"];
        
        // Get our action if it is available for key
        if ([valueContext cello_isActionAvailableForKey:key]) {
            
            // Special scenario for make available offline action
            if ([key isEqualToString:@"cello_makeavailableoffline"]){
                if ([[entityValueProvider valueForEntityProperty:@"keepLocal"] boolValue]) {
                    if ([valueContext cello_isConcreteMediaItem]) {
                        title = @"Remove Download";
                    } else {
                        title = @"Remove Downloads";
                    }
                }
            }
            
            id previewAction;
            
            if (actionClass == [UIPreviewAction class]) {
                previewAction = [self uipreviewActionForKey:key title:title];
            } else if (actionClass == [UITableViewRowAction class]) {
                previewAction = [self tableViewRowActionForKey:key title:title];
            }
            
            if (previewAction) {
                [actions addObject:previewAction];
            }
            
        }
        
    }
    
    return [actions copy];
}

- (UIPreviewAction *)uipreviewActionForKey:(NSString *)key title:(NSString *)title
{
    id handler = ^(UIPreviewAction *action, UIViewController<SWCelloMediaEntityPreviewViewController> *previewViewController) {
        
        NSIndexPath *indexPath = previewViewController.celloPreviewIndexPath;
        
        if ([key isEqualToString:@"cello_showinstore"]) {
            
            [self performShowInStoreActionForIndexPath:indexPath];
            
        } else if ([key isEqualToString:@"cello_startradiostation"]) {
            
            [self performStartStationActionForIndexPath:indexPath];
            
        } else if ([key isEqualToString:@"cello_playnext"]) {
            
            [self performUpNextAction:SWCello_UpNextActionType_PlayNext forIndexPath:indexPath];
            
        } else if ([key isEqualToString:@"cello_addtoupnext"]) {
            
            [self performUpNextAction:SWCello_UpNextActionType_AddToUpNext forIndexPath:indexPath];
            
        }  else if ([key isEqualToString:@"cello_addtoplaylist"]) {
            
            [self performAddToPlaylistActionForIndexPath:indexPath];
            
        } else if ([key isEqualToString:@"cello_makeavailableoffline"]) {
            
            [self performDownloadActionForIndexPath:indexPath];
            
        } else if ([key isEqualToString:@"cello_deleteremove"]) {
            
            UIAlertController *deleteConfirmController = [self deleteConfirmationAlertControllerForIndexPath:indexPath];
            [self.delegate presentViewController:deleteConfirmController animated:YES completion:nil];
            
        }
        
        SW_PIRACY;
        
    };
    
    UIPreviewAction *previewAction = [UIPreviewAction actionWithTitle:title
                                                                style:UIPreviewActionStyleDefault
                                                              handler:handler];
    return previewAction;
}

- (UITableViewRowAction *)tableViewRowActionForKey:(NSString *)key title:(NSString *)title
{
    UIColor *color;
    //TEMPORARY
    if ([key isEqualToString:@"cello_showinstore"]) {
        title = @"Store";
        color = [UIColor orangeColor];
    } else if ([key isEqualToString:@"cello_startradiostation"]) {
        title = @"Radio";
        color = [UIColor greenColor];
    } else if ([key isEqualToString:@"cello_playnext"]) {
        title = @"Play\nNext";
        color = [UIColor colorWithRed:0.1 green:0.71 blue:1.0 alpha:1.0];
    } else if ([key isEqualToString:@"cello_addtoupnext"]) {
        title = @"Queue";
        color = [UIColor colorWithRed:0.97 green:0.58 blue:0.02 alpha:1.0];
    }  else if ([key isEqualToString:@"cello_addtoplaylist"]) {
        title = @"+\nPlaylist";
        color = [UIColor cyanColor];
    } else if ([key isEqualToString:@"cello_makeavailableoffline"]) {
        title = @"Download";
        color = [UIColor colorWithRed:0.56 green:0.27 blue:0.68 alpha:1.0];
    } else if ([key isEqualToString:@"cello_deleteremove"]) {
        title = @"Delete";
        color = [UIColor redColor];
    }
    
    
    
    id handler = ^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        if ([key isEqualToString:@"cello_showinstore"]) {
            
            [self performShowInStoreActionForIndexPath:indexPath];
            
        } else if ([key isEqualToString:@"cello_startradiostation"]) {
            
            [self performStartStationActionForIndexPath:indexPath];
            
        } else if ([key isEqualToString:@"cello_playnext"]) {
            
            [self performUpNextAction:SWCello_UpNextActionType_PlayNext forIndexPath:indexPath];
            
        } else if ([key isEqualToString:@"cello_addtoupnext"]) {
            
            [self performUpNextAction:SWCello_UpNextActionType_AddToUpNext forIndexPath:indexPath];
            
        }  else if ([key isEqualToString:@"cello_addtoplaylist"]) {
            
            [self performAddToPlaylistActionForIndexPath:indexPath];
            
        } else if ([key isEqualToString:@"cello_makeavailableoffline"]) {
            
            [self performDownloadActionForIndexPath:indexPath];
            
        } else if ([key isEqualToString:@"cello_deleteremove"]) {
            
            UIAlertController *deleteConfirmController = [self deleteConfirmationAlertControllerForIndexPath:indexPath];
            [self.delegate presentViewController:deleteConfirmController animated:YES completion:nil];
            
        }
        
        SW_PIRACY;
        
    };
    
    UITableViewRowAction *rowAction = [UITableViewRowAction
                                       rowActionWithStyle:UITableViewRowActionStyleNormal
                                       title:title
                                       handler:handler];
    rowAction.backgroundColor = color;
    
    return rowAction;
}

#pragma mark - Actions(Perform)

- (void)performShowInStoreActionForIndexPath:(NSIndexPath *)indexPath
{
    MusicEntityValueContext *valueContext = [self.delegate _entityValueContextAtIndexPath:indexPath];
    
    MusicContextualShowInStoreAlertAction *contextAction;
    contextAction = [%c(MusicContextualShowInStoreAlertAction) contextualShowInStoreActionWithEntityValueContext:valueContext
                                                                                               didDismissHandler:nil];
    [contextAction performContextualAction];
}

- (void)performStartStationActionForIndexPath:(NSIndexPath *)indexPath
{
    MusicEntityValueContext *valueContext = [self.delegate _entityValueContextAtIndexPath:indexPath];
    
    MusicContextualStartStationAlertAction *contextAction;
    contextAction = [%c(MusicContextualStartStationAlertAction) contextualStartStationActionWithEntityValueContext:valueContext];
    
    [contextAction performContextualAction];
}

- (void)performUpNextAction:(SWCello_UpNextActionType)actionType forIndexPath:(NSIndexPath *)indexPath
{
    MusicEntityValueContext *valueContext = [self.delegate _entityValueContextAtIndexPath:indexPath];
    
    MusicContextualUpNextAlertAction *contextAction = [%c(MusicContextualUpNextAlertAction)
                                                       contextualUpNextActionWithEntityValueContext:valueContext
                                                       insertionType:actionType
                                                       didDismissHandler:nil];
    
    [contextAction performContextualAction];
}

- (void)performAddToPlaylistActionForIndexPath:(NSIndexPath *)indexPath
{
    MusicEntityValueContext *valueContext = [self.delegate _entityValueContextAtIndexPath:indexPath];
    
    MusicContextualAddToPlaylistAlertAction *contextAction;
    contextAction = [%c(MusicContextualAddToPlaylistAlertAction)
                     contextualAddToPlaylistActionForEntityValueContext:valueContext
                     shouldDismissHandler:nil
                     additionalPresentationHandler:^(MusicContextualPlaylistPickerViewController *arg1) {
                         
                         [self.delegate presentViewController:arg1 animated:YES completion:nil];
                         
                     }
                     didDismissHandler:nil];
    
    [contextAction performContextualAction];
}

- (void)performDownloadActionForIndexPath:(NSIndexPath *)indexPath
{
    MusicEntityValueContext *valueContext = [self.delegate _entityValueContextAtIndexPath:indexPath];
    
    MusicContextualLibraryUpdateAlertAction *contextAction;
    [%c(MusicContextualLibraryUpdateAlertAction) getContextualLibraryAddRemoveAction:nil
                                                                     keepLocalAction:&contextAction
                                                               forEntityValueContext:valueContext
                                                          overrideItemEntityProvider:nil
                                                                shouldDismissHandler:nil
                                                       additionalPresentationHandler:nil
                                                                   didDismissHandler:nil];
    [contextAction performContextualAction];
}

- (void)performRemoveFromPlaylistActionForIndexPath:(NSIndexPath *)indexPath
{
    MusicEntityValueContext *valueContext = [self.delegate _entityValueContextAtIndexPath:indexPath];
    
    MusicContextualRemoveFromPlaylistAlertAction *contextAction;
    contextAction = [%c(MusicContextualRemoveFromPlaylistAlertAction)
                     contextualRemoveFromPlaylistActionWithEntityValueContext:valueContext];
    
    [contextAction performContextualAction];
}

- (void)performDeleteFromLibraryActionForValueContext:(MusicEntityValueContext *)valueContext
{
    MusicContextualLibraryUpdateAlertAction *contextAction;
    [%c(MusicContextualLibraryUpdateAlertAction) getContextualLibraryAddRemoveAction:&contextAction
                                                                     keepLocalAction:nil
                                                               forEntityValueContext:valueContext
                                                          overrideItemEntityProvider:nil
                                                                shouldDismissHandler:nil
                                                       additionalPresentationHandler:nil
                                                                   didDismissHandler:nil];
    
    [contextAction performContextualAction];
}

- (UIAlertController *)deleteConfirmationAlertControllerForIndexPath:(NSIndexPath *)indexPath
{
    __block MusicEntityValueContext *valueContext = [self.delegate _entityValueContextAtIndexPath:indexPath];
    
    id<MusicEntityValueProviding> entityValueProvider = [self.delegate cello_entityValueProviderAtIndexPath:indexPath];
    MusicCoalescingEntityValueProvider *coalescingEntityValueProvider;
    if ([entityValueProvider isKindOfClass:%c(MusicCoalescingEntityValueProvider)]) {
        coalescingEntityValueProvider = (MusicCoalescingEntityValueProvider *)entityValueProvider;
    }
    
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:[coalescingEntityValueProvider cello_EntityNameBestGuess]
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             
                                                             //[self.tableView setEditing:NO animated:YES];
                                                             
                                                         }];
    [controller addAction:cancelAction];
    
    
    if ([valueContext cello_removeFromPlaylistAvailable]) {
        
        UIAlertAction *deleteFromPlaylistAction;
        
        deleteFromPlaylistAction = [UIAlertAction
                                    actionWithTitle:@"Remove from this Playlist"
                                    style:UIAlertActionStyleDestructive
                                    handler:^(UIAlertAction * action) {
                                        
                                        // make sure we have correct context
                                        // special situation when a new song is added to the library
                                        // in between the time the alert showed and the user selects an option
                                        // EX - add new song to library
                                        //      quickly go to song in library
                                        //      add to a playlist
                                        //      the valueContext will point to the old song someimtes
                                        //      this ensures we have the current one
                                        [self performRemoveFromPlaylistActionForIndexPath:indexPath];
                                        
                                    }];
        [controller addAction:deleteFromPlaylistAction];
    }
    
    
    UIAlertAction *deleteAction;
    deleteAction = [UIAlertAction
                    actionWithTitle:@"Delete from Music Library"
                    style:UIAlertActionStyleDestructive
                    handler:^(UIAlertAction * action) {
                        
                        // make sure we have correct context (see removeFromPlaylistAction below)
                        valueContext = [self.delegate _entityValueContextAtIndexPath:indexPath];
                        
                        if ([valueContext cello_removeFromPlaylistAvailable]) {
                            [self performRemoveFromPlaylistActionForIndexPath:indexPath];
                        }
                        
                        // special situation with single items in a playlist
                        // this allows them to be deleted as well by constructing a new query for the item
                        // without it's playlist referenced
                        if ([valueContext cello_isConcreteMediaItem]) {
                            
                            MPMediaEntity *mediaItem = (MPMediaEntity *)valueContext.entityValueProvider;
                            
                            MPMediaPropertyPredicate *queryPredicate = [MPMediaPropertyPredicate predicateWithValue:@(mediaItem.persistentID)
                                                                                                        forProperty:MPMediaItemPropertyPersistentID];
                            
                            MPMediaQuery *titlesQuery = [MPMediaQuery songsQuery];
                            [titlesQuery addFilterPredicate:queryPredicate];
                            
                            if (titlesQuery.items.count == 1) {
                                
                                MusicEntityValueContext *tempValueContext = [[%c(MusicEntityValueContext) alloc] init];
                                [tempValueContext configureWithMediaEntity:titlesQuery.items[0]];
                                
                                [self performDeleteFromLibraryActionForValueContext:tempValueContext];
                                
                            } else {
                                NSLog(@"--------------------------------");
                                NSLog(@"Cello - Error constructing query");
                                NSLog(@"--------------------------------");
                                NSLog(@"%@", mediaItem);
                                NSLog(@"%@", queryPredicate);
                                NSLog(@"%@", titlesQuery);
                                NSLog(@"%@", @(titlesQuery.items.count));
                                NSLog(@"--------------------------------");
                            }
                            
                        } else {
                            
                            [self performDeleteFromLibraryActionForValueContext:valueContext];
                            
                        }
                        
                    }];
    [controller addAction:deleteAction];
    
    
    // iPad
//    UIPopoverPresentationController *popPresenter = [controller popoverPresentationController];
//    popPresenter.sourceView = cell;
//    popPresenter.sourceRect = cell.bounds;
    
    return controller;
}

@end





