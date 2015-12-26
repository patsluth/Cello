//
//  MusicEntityValueContext.xm
//  Cello
//
//  Created by Pat Sluth on 2015-12-21.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import "MusicEntityValueContext.h"

#import "MPMediaItemCollection+SW.h"

#import "libsw/libSluthware/SWPrefs.h"



//-Show in iTunes Store
//-Start Radio Station
//-Play Next
//-Add to Up Next
//-Add to Playlist
//-Remove from Playlist
//-Make Available Offline
//-Remove Download
//-Delete


%hook MusicEntityValueContext

%new
- (BOOL)showInStoreAvailable
{
    if (![[SWPrefs valueForKey:@"cello_showinstore_enabled" application:@"com.apple.Music"] boolValue]) {
        return NO;
    }
    
    if ([self isConcreteMediaItem]) {
        return YES;
    }
    
    MPMediaItemCollection *mediaCollection = (MPMediaItemCollection *)[self isConcreteMediaCollection];
    
    if (mediaCollection && mediaCollection.groupingType == MPMediaGroupingAlbum) {
        return YES;
    }
    
    return NO;
}

%new
- (BOOL)startRadioStationAvailable
{
    if (![[SWPrefs valueForKey:@"cello_startradiostation_enabled" application:@"com.apple.Music"] boolValue]) {
        return NO;
    }
    
    if ([self isConcreteMediaItem]) {
        return YES;
    }
    
    if ([self isConcreteMediaCollection]) {
        
        MPMediaItemCollection *mediaCollection = (MPMediaItemCollection *)self.entityValueProvider;
        
        if (mediaCollection.groupingType == MPMediaGroupingAlbum ||
            mediaCollection.groupingType == 17 ||
            mediaCollection.groupingType == MPMediaGroupingArtist ||
            mediaCollection.groupingType == MPMediaGroupingAlbumArtist ||
            mediaCollection.groupingType == MPMediaGroupingComposer) {
            return YES;
        }
        
    }
    
    return NO;
}

%new
- (BOOL)upNextAvailable
{
    if (![[SWPrefs valueForKey:@"cello_upnext_enabled" application:@"com.apple.Music"] boolValue]) {
        return NO;
    }
    
    if ([self isConcreteMediaItem] || [self isConcreteMediaPlaylist]) {
        return YES;
    }
    
    if ([self isConcreteMediaCollection]) {
        
        MPMediaItemCollection *mediaCollection = (MPMediaItemCollection *)self.entityValueProvider;
        
        if (mediaCollection.groupingType != MPMediaGroupingComposer && mediaCollection.groupingType != MPMediaGroupingGenre) {
            return YES;
        }
        
    }
    
    return NO;
}

%new
- (BOOL)addToPlaylistAvailable
{
    if (![[SWPrefs valueForKey:@"cello_addtoplaylist_enabled" application:@"com.apple.Music"] boolValue]) {
        return NO;
    }
    
    if ([self isConcreteMediaItem] || [self isConcreteMediaPlaylist]) {
        return YES;
    }
    
    MPMediaItemCollection *mediaCollection = (MPMediaItemCollection *)[self isConcreteMediaCollection];
    
    if (mediaCollection && (mediaCollection.groupingType == MPMediaGroupingAlbum ||
                            mediaCollection.groupingType == 17)) {
        return YES;
    }
    
    return NO;
}

%new
- (BOOL)makeAvailableOfflineAvailable
{
    if (![[SWPrefs valueForKey:@"cello_makeavailableoffline_enabled" application:@"com.apple.Music"] boolValue]) {
        return NO;
    }
    
    return YES;
}

%new
- (BOOL)removeFromPlaylistAvailable
{
    if (![[SWPrefs valueForKey:@"cello_deleteremove_enabled" application:@"com.apple.Music"] boolValue]) {
        return NO;
    }
    
    if ([self isConcreteMediaItem]) {
        
        if (self.containerEntityValueProvider && [(id)self.containerEntityValueProvider isKindOfClass:%c(MPConcreteMediaPlaylist)]) {
            return YES;
        }
        
    }
    
    return NO;
}

%new
- (BOOL)deleteAvailable
{
    if (![[SWPrefs valueForKey:@"cello_deleteremove_enabled" application:@"com.apple.Music"] boolValue]) {
        return NO;
    }
    
    return YES;
}



// return MPMediaConcreteItem if this value context is pointing to an individual item (not a collection)
%new
- (/*MPMediaConcreteItem **/ id)isConcreteMediaItem
{
    if (self.entityValueProvider && [(id)self.entityValueProvider isKindOfClass:%c(MPConcreteMediaItem)]) {
        return self.entityValueProvider;
    }
    
    return nil;
}

// return MPConcreteMediaItemCollection if this value context is pointing to an individual item (not a collection)
%new
- (/*MPConcreteMediaItemCollection **/ id)isConcreteMediaCollection
{
    if (self.entityValueProvider && [(id)self.entityValueProvider isKindOfClass:%c(MPConcreteMediaItemCollection)]) {
        return self.entityValueProvider;
    }
    
    return nil;
}

// return MPConcreteMediaPlaylist if this value context is pointing to a playlist
%new
- (/*MPConcreteMediaPlaylist **/ id)isConcreteMediaPlaylist
{
    if (self.entityValueProvider && [(id)self.entityValueProvider isKindOfClass:%c(MPConcreteMediaPlaylist)]) {
        return self.entityValueProvider;
    }
    
    return nil;
}

%new
- (void)log
{
    NSLog(@"%@", NSStringFromClass(self.class));
    NSLog(@"");NSLog(@"");
    
    NSLog(@"%@", [NSString stringWithFormat:@"itemGlobalIndex:[%@]", @(self.itemGlobalIndex)]);
    NSLog(@"%@", [NSString stringWithFormat:@"entityValueProvider:[%@]", self.entityValueProvider]);
    NSLog(@"%@", [NSString stringWithFormat:@"containerEntityValueProvider:[%@]", self.containerEntityValueProvider]);
    NSLog(@"%@", [NSString stringWithFormat:@"itemIdentifierCollection:[%@]", (id)self.itemIdentifierCollection]);
    NSLog(@"%@", [NSString stringWithFormat:@"containerIdentifierCollection:[%@]", (id)self.containerIdentifierCollection]);
    NSLog(@"%@", [NSString stringWithFormat:@"itemPlaybackContext:[%@]", self.itemPlaybackContext]);
    NSLog(@"%@", [NSString stringWithFormat:@"containerPlaybackContext:[%@]", self.containerPlaybackContext]);
    
    NSLog(@"");NSLog(@"");
}

%end




