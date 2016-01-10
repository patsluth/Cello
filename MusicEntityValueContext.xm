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
- (BOOL)cello_isActionAvailableForKey:(NSString *)key
{
    if ([key isEqualToString:@"cello_showinstore"]) {
        return [self cello_showInStoreAvailable];
    } else if ([key isEqualToString:@"cello_startradiostation"]) {
        return [self cello_startRadioStationAvailable];
    } else if ([key isEqualToString:@"cello_playnext"] || [key isEqualToString:@"cello_addtoupnext"]) {
        return [self cello_upNextAvailable];
    } else if ([key isEqualToString:@"cello_addtoplaylist"]) {
        return [self cello_addToPlaylistAvailable];
    } else if ([key isEqualToString:@"cello_makeavailableoffline"]) {
        return [self cello_makeAvailableOfflineAvailable];
    } else if ([key isEqualToString:@"cello_deleteremove"]) {
        return [self cello_deleteAvailable];
    }
    
    return NO;
}

%new
- (BOOL)cello_showInStoreAvailable
{
    if ([self cello_isConcreteMediaItem]) {
        return YES;
    }
    
    MPMediaItemCollection *mediaCollection = (MPMediaItemCollection *)[self cello_isConcreteMediaCollection];
    
    if (mediaCollection && mediaCollection.groupingType == MPMediaGroupingAlbum) {
        return YES;
    }
    
    return NO;
}

%new
- (BOOL)cello_startRadioStationAvailable
{
    if ([self cello_isConcreteMediaItem]) {
        return YES;
    }
    
    if ([self cello_isConcreteMediaCollection]) {
        
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
- (BOOL)cello_upNextAvailable
{
    if ([self cello_isConcreteMediaItem] || [self cello_isConcreteMediaPlaylist]) {
        return YES;
    }
    
    if ([self cello_isConcreteMediaCollection]) {
        
        MPMediaItemCollection *mediaCollection = (MPMediaItemCollection *)self.entityValueProvider;
        
        if (mediaCollection.groupingType != MPMediaGroupingComposer && mediaCollection.groupingType != MPMediaGroupingGenre) {
            return YES;
        }
        
    }
    
    return NO;
}

%new
- (BOOL)cello_addToPlaylistAvailable
{
    if ([self cello_isConcreteMediaItem] || [self cello_isConcreteMediaPlaylist]) {
        return YES;
    }
    
    MPMediaItemCollection *mediaCollection = (MPMediaItemCollection *)[self cello_isConcreteMediaCollection];
    
    if (mediaCollection && (mediaCollection.groupingType == MPMediaGroupingAlbum ||
                            mediaCollection.groupingType == 17)) {
        return YES;
    }
    
    return NO;
}

%new
- (BOOL)cello_makeAvailableOfflineAvailable
{
    return YES;
}

%new
- (BOOL)cello_removeFromPlaylistAvailable
{
    if ([self cello_isConcreteMediaItem]) {
        
        if (self.containerEntityValueProvider && [(id)self.containerEntityValueProvider isKindOfClass:%c(MPConcreteMediaPlaylist)]) {
            return YES;
        }
        
    }
    
    return NO;
}

%new
- (BOOL)cello_deleteAvailable
{
    return YES;
}



// return MPMediaConcreteItem if this value context is pointing to an individual item (not a collection)
%new
- (/*MPMediaConcreteItem **/ id)cello_isConcreteMediaItem
{
    if (self.entityValueProvider && [(id)self.entityValueProvider isKindOfClass:%c(MPConcreteMediaItem)]) {
        return self.entityValueProvider;
    }
    
    return nil;
}

// return MPConcreteMediaItemCollection if this value context is pointing to an individual item (not a collection)
%new
- (/*MPConcreteMediaItemCollection **/ id)cello_isConcreteMediaCollection
{
    if (self.entityValueProvider && [(id)self.entityValueProvider isKindOfClass:%c(MPConcreteMediaItemCollection)]) {
        return self.entityValueProvider;
    }
    
    return nil;
}

// return MPConcreteMediaPlaylist if this value context is pointing to a playlist
%new
- (/*MPConcreteMediaPlaylist **/ id)cello_isConcreteMediaPlaylist
{
    if (self.entityValueProvider && [(id)self.entityValueProvider isKindOfClass:%c(MPConcreteMediaPlaylist)]) {
        return self.entityValueProvider;
    }
    
    return nil;
}

%new
- (Class)cello_correctLibraryViewConfiguration
{
    if ([self cello_isConcreteMediaItem]) { // song
        
        return %c(MusicLibrarySongsViewConfiguration);
        
    } else if ([self cello_isConcreteMediaCollection]) { // media collection (genre, compilation, etc)
        
        id albumArtistName = [self.entityValueProvider valueForEntityProperty:@"albumArtistName"];
        id albumName = [self.entityValueProvider valueForEntityProperty:@"albumName"];
        id title = [self.entityValueProvider valueForEntityProperty:@"title"];
        id albumAlbumArtist = [self.entityValueProvider valueForEntityProperty:@"albumAlbumArtist"];
        id albumCount = [self.entityValueProvider valueForEntityProperty:@"albumCount"];
        id itemCount = [self.entityValueProvider valueForEntityProperty:@"itemCount"];
        id genreName = [self.entityValueProvider valueForEntityProperty:@"genreName"];
        id composerName = [self.entityValueProvider valueForEntityProperty:@"composerName"];
        BOOL musicAlbumIsCompilation = false;
        if ([self.entityValueProvider valueForEntityProperty:@"musicAlbumIsCompilation"]) {
            musicAlbumIsCompilation = [[self.entityValueProvider valueForEntityProperty:@"musicAlbumIsCompilation"] boolValue];
        }
        
        
        BOOL isArtist = (albumArtistName && !albumName && !title);
        if (isArtist) {
            return %c(MusicLibraryArtistsViewConfiguration);
        }
        BOOL isAlbum = (albumName != nil);// && albumAlbumArtist && !musicAlbumIsCompilation);
        if (isAlbum) {
            return %c(MusicLibraryAlbumsViewConfiguration);
        }
        BOOL isGenre = (albumCount && genreName && itemCount);
        if (isGenre) {
            return %c(MusicLibraryGenresViewConfiguration);
        }
        BOOL isComposer = (albumCount && itemCount && composerName);
        if (isComposer) {
            return %c(MusicLibraryComposersViewConfiguration);
        }
        BOOL isCompilation = (albumName && albumAlbumArtist && musicAlbumIsCompilation);
        if (isCompilation) {
            return %c(MusicLibraryCompilationsViewConfiguration);
        }
        
        
    } else if ([self cello_isConcreteMediaPlaylist]) { // playlist
        
        return %c(MusicLibraryPlaylistsViewConfiguration);
        
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




