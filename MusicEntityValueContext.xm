//
//  MusicEntityValueContext.xm
//  Cello
//
//  Created by Pat Sluth on 2015-12-21.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import "MusicEntityValueContext.h"

#import "MPMediaItemCollection+SW.h"





%hook MusicEntityValueContext

%new
- (BOOL)showInStoreAvailable
{
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
- (BOOL)startStation
{
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
    if ([self isConcreteMediaItem] || [self isConcreteMediaPlaylist]) {
        return YES;
    }
    
    MPMediaItemCollection *mediaCollection = (MPMediaItemCollection *)[self isConcreteMediaCollection];
    NSLog(@"PAT %@", @(mediaCollection.groupingType));
    if (mediaCollection && (mediaCollection.groupingType == MPMediaGroupingAlbum ||
                            mediaCollection.groupingType == 17)) {
        return YES;
    }
    
    return NO;
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

%end




