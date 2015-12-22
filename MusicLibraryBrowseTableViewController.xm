//
//  MusicLibraryBrowseTableViewController.xm
//  Cello
//
//  Created by Pat Sluth on 2015-12-21.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import "MusicContextualUpNextAlertAction.h"
#import "MusicContextualLibraryUpdateAlertAction.h"
#import "MusicEntityValueContext.h"

#import <MediaPlayer/MediaPlayer.h>





@interface MPConcreteMediaEntityPropertiesCache : NSObject
{
    //NSMutableDictionary *_properties;
}

@end

@interface MusicCoalescingEntityValueProvider : NSObject
{
    //NSMutableDictionary *_properties;
}

@property (nonatomic,retain) id<MusicEntityValueProviding> baseEntityValueProvider;

- (NSDictionary *)_cachedPropertyValues;
- (id)valueForEntityProperty:(NSString *)arg1;

@end

















@interface MusicLibraryBrowseTableViewController : UIViewController
{
}

@property (strong, nonatomic ) /*MusicTableView*/ UITableView *tableView;

- (id)_entityValueContextAtIndexPath:(id)arg1;
- (void)_configureEntityValueContextOutput:(id)arg1 forIndexPath:(id)arg2;

@end


// not an actual class, use for easy casting
@interface MusicLibraryBrowseTableViewCell : UITableViewCell
{
}

@property (nonatomic,retain) id<MusicEntityValueProviding> entityValueProvider;

@end

@interface MusicEntityTracklistItemTableViewCell : MusicLibraryBrowseTableViewCell
{
}

- (BOOL)tracklistItemViewShouldLayoutAsEditing:(id)arg1;
- (void)tracklistItemViewDidSelectContextualActionsButton:(id)arg1;

@end

@interface MusicEntityHorizontalLockupTableViewCell : MusicLibraryBrowseTableViewCell
{
}

- (BOOL)horizontalLockupViewShouldLayoutAsEditing:(id)arg1;
- (void)horizontalLockupViewDidSelectContextualActionsButton:(id)arg1;

@end





%hook MusicLibraryBrowseTableViewController

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MusicLibraryBrowseTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([(id)cell.entityValueProvider isKindOfClass:%c(MusicCoalescingEntityValueProvider)]) {
        
        // contains cached media properties
        MusicCoalescingEntityValueProvider *coalescingEntityValueProvider;
        coalescingEntityValueProvider = (MusicCoalescingEntityValueProvider *)cell.entityValueProvider;
        
        if ([[(id)coalescingEntityValueProvider.baseEntityValueProvider class] isSubclassOfClass:%c(MPMediaEntity)]){ // media cell
            
            return UITableViewCellEditingStyleDelete;
            
        }
    }
    
    
    // not a media cell
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

%new
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // contains cached media properties
    MusicLibraryBrowseTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    MusicCoalescingEntityValueProvider *coalescingEntityValueProvider;
    coalescingEntityValueProvider = (MusicCoalescingEntityValueProvider *)cell.entityValueProvider;
    
    
    /**
     *  Perform Up Next
     *
     *  @param option 0 or 1 (add to up next or play next)
     */
    void (^_upNextAction)(NSIndexPath *indexPath, NSInteger option) = ^(NSIndexPath *indexPath, NSInteger option) {
        
        MusicEntityValueContext *valueContext = [self _entityValueContextAtIndexPath:indexPath];
        
        // make sure our queries are set up correctly
        valueContext.wantsItemGlobalIndex = YES;
        valueContext.wantsItemEntityValueProvider = YES;
        valueContext.wantsContainerEntityValueProvider = YES;
        valueContext.wantsItemIdentifierCollection = YES;
        valueContext.wantsContainerIdentifierCollection = YES;
        valueContext.wantsItemPlaybackContext = YES;
        valueContext.wantsContainerPlaybackContext = YES;
        [self _configureEntityValueContextOutput:valueContext forIndexPath:indexPath];
        
        
        MusicContextualUpNextAlertAction *a = [%c(MusicContextualUpNextAlertAction)
                                               contextualUpNextActionWithEntityValueContext:valueContext
                                               insertionType:option
                                               didDismissHandler:nil];
        
        [a performContextualAction];
        
    };
    
    
    
    UITableViewRowAction *addToUpNextButton = [UITableViewRowAction
                                          rowActionWithStyle:UITableViewRowActionStyleNormal
                                          title:@"Up\nNext"
                                          handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                              
                                              _upNextAction(indexPath, 0);
                                              [self.tableView setEditing:NO animated:YES];
                                              
                                          }];
    
    UITableViewRowAction *playNextButton = [UITableViewRowAction
                                          rowActionWithStyle:UITableViewRowActionStyleNormal
                                          title:@"Play\nNext"
                                          handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                              
                                              _upNextAction(indexPath, 1);
                                              [self.tableView setEditing:NO animated:YES];
                                              
                                          }];
    
    
     UITableViewRowAction *deleteButton = [UITableViewRowAction
                                           rowActionWithStyle:UITableViewRowActionStyleDestructive
                                           title:@"Delete"
                                           handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                               
                                               MusicEntityValueContext *valueContext = [self _entityValueContextAtIndexPath:indexPath];
                                               
                                               // make sure our identifiers are set up correctly
                                               valueContext.wantsItemGlobalIndex = YES;
                                               valueContext.wantsItemEntityValueProvider = YES;
                                               valueContext.wantsContainerEntityValueProvider = YES;
                                               valueContext.wantsItemIdentifierCollection = YES;
                                               valueContext.wantsContainerIdentifierCollection = YES;
                                               valueContext.wantsItemPlaybackContext = YES;
                                               valueContext.wantsContainerPlaybackContext = YES;
                                               [self _configureEntityValueContextOutput:valueContext forIndexPath:indexPath];
                                               
                                               
                                               NSString *itemName; // try and find the best cached name for current item
                                               for (NSString *propertyKey in [coalescingEntityValueProvider _cachedPropertyValues]) {
                                                   if ([propertyKey.lowercaseString containsString:@"name"] ||
                                                       [propertyKey.lowercaseString containsString:@"title"]) {
                                                       itemName = [coalescingEntityValueProvider valueForEntityProperty:propertyKey];
                                                       
                                                       if ([propertyKey.lowercaseString isEqualToString:@"name"]) {
                                                           break;
                                                       }
                                                       
                                                   }
                                               }
                                               
                                               
                                               // delete confirmation controller
                                               UIAlertController *alertController = [UIAlertController
                                                                                     alertControllerWithTitle:nil
                                                                                     message:[NSString stringWithFormat:@"%@ %@", itemName, @"will also be removed from all your devices."]
                                                                                     preferredStyle:UIAlertControllerStyleActionSheet];
                                               
                                               UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel"
                                                                                                      style:UIAlertActionStyleCancel
                                                                                                    handler:^(UIAlertAction * action) {
                                                                                                        [self.tableView setEditing:NO animated:YES];
                                                                                                    }];
                                               
                                               UIAlertAction *deleteButton = [UIAlertAction
                                                                              actionWithTitle:@"Delete from Music Library"
                                                                              style:UIAlertActionStyleDestructive
                                                                              handler:^(UIAlertAction * action) {
                                                                                  
                                                                                  MusicContextualLibraryUpdateAlertAction *deleteAction;
                                                                                  
                                                                                  [%c(MusicContextualLibraryUpdateAlertAction) getContextualLibraryAddRemoveAction:&deleteAction
                                                                                                                                                   keepLocalAction:nil
                                                                                                                                             forEntityValueContext:valueContext
                                                                                                                                        overrideItemEntityProvider:nil
                                                                                                                                              shouldDismissHandler:nil
                                                                                                                                     additionalPresentationHandler:nil
                                                                                                                                                 didDismissHandler:nil];
                                                                                  
                                                                                  [deleteAction performContextualAction];
                                                                                  
                                                                              }];
                                               
                                               // add actions
                                               [alertController addAction:cancelButton];
                                               [alertController addAction:deleteButton];
                                               
                                               if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) { // iPad requires popover
                                                   
                                                   UIPopoverPresentationController *popPresenter = [alertController popoverPresentationController];
                                                   popPresenter.sourceView = cell;
                                                   popPresenter.sourceRect = cell.bounds;
                                                   
                                               }
                                               
                                               //present delete confirmation controller
                                               [self presentViewController:alertController animated:YES completion:nil];
                                               
                                           }];
    
    
    NSNumber *keepLocal = [coalescingEntityValueProvider valueForEntityProperty:@"keepLocal"];
    
    UITableViewRowAction *downloadButton = [UITableViewRowAction
                                          rowActionWithStyle:UITableViewRowActionStyleNormal
                                            title:(keepLocal.boolValue ? @"Remove\nDownload" : @"Download")
                                          handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                              
                                              MusicEntityValueContext *valueContext = [self _entityValueContextAtIndexPath:indexPath];
                                              
                                              // make sure our identifiers are set up correctly
                                              valueContext.wantsItemGlobalIndex = YES;
                                              valueContext.wantsItemEntityValueProvider = YES;
                                              valueContext.wantsContainerEntityValueProvider = YES;
                                              valueContext.wantsItemIdentifierCollection = YES;
                                              valueContext.wantsContainerIdentifierCollection = YES;
                                              valueContext.wantsItemPlaybackContext = YES;
                                              valueContext.wantsContainerPlaybackContext = YES;
                                              [self _configureEntityValueContextOutput:valueContext forIndexPath:indexPath];
                                              
                                              
                                              MusicContextualLibraryUpdateAlertAction *downloadAction;
                                              
                                              [%c(MusicContextualLibraryUpdateAlertAction) getContextualLibraryAddRemoveAction:nil
                                                                                                               keepLocalAction:&downloadAction
                                                                                                         forEntityValueContext:valueContext
                                                                                                    overrideItemEntityProvider:nil
                                                                                                          shouldDismissHandler:nil
                                                                                                 additionalPresentationHandler:nil
                                                                                                             didDismissHandler:nil];
                                              [downloadAction performContextualAction];
                                              [self.tableView setEditing:NO animated:YES];
                                              
                                              
                                          }];
    
    
    
    playNextButton.backgroundColor = [UIColor colorWithRed:0.1 green:0.71 blue:1.0 alpha:1.0];
    addToUpNextButton.backgroundColor = [UIColor colorWithRed:0.97 green:0.58 blue:0.02 alpha:1.0];
    downloadButton.backgroundColor = [UIColor colorWithRed:0.56 green:0.27 blue:0.68 alpha:1.0];
    
//    CGFloat r1, g1, b1, a1, r2, g2, b2, a2;
//    CGFloat tolerance = 0.3;
//    [deleteButton.backgroundColor getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
//    [playNextButton.backgroundColor getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
//    
//    if (fabs(r1 - r2) <= tolerance &&
//        fabs(g1 - g2) <= tolerance &&
//        fabs(b1 - b2) <= tolerance &&
//        fabs(a1 - a2) <= tolerance) { // Colors are to similar
//        
//        addToUpNextButton.backgroundColor = [UIColor darkGrayColor];
//        
//    } else {
//        
//        //calculate midpoint of the 2 colours
//        CGFloat r = (r1 + r2)/2.0;
//        r = fmax(r, tolerance);
//        CGFloat g = (g1 + g2)/2.0;
//        g = fmax(g, tolerance);
//        CGFloat b = (b1 + b2)/2.0;
//        b = fmax(b, tolerance);
//        CGFloat a = (a1 + a2)/2.0;
//        a = fmax(a, tolerance);
//        
//        addToUpNextButton.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
//        
//    }
    
    return @[playNextButton, addToUpNextButton, downloadButton, deleteButton];
}

%end





%hook MusicEntityTracklistItemTableViewCell

- (BOOL)tracklistItemViewShouldLayoutAsEditing:(id)arg1
{
    return NO;
}

- (void)tracklistItemViewDidSelectContextualActionsButton:(id)arg1
{
    if (self.isEditing) {
        return;
    }
    
    %orig();
}

%end


%hook MusicEntityHorizontalLockupTableViewCell

- (BOOL)horizontalLockupViewShouldLayoutAsEditing:(id)arg1
{
    return NO;
}

- (void)horizontalLockupViewDidSelectContextualActionsButton:(id)arg1
{
    if (self.isEditing) {
        return;
    }
    
    %orig();
}

%end




