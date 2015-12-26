//
//  MusicCoalescingEntityValueProvider.xm
//  Cello
//
//  Created by Pat Sluth on 2015-12-21.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import "MusicCoalescingEntityValueProvider.h"





%hook MusicCoalescingEntityValueProvider

%new
- (NSString *)cello_EntityNameBestGuess
{
    // try and find the best cached name for current item
    // this will happen for all media types (artist, song, playlist) and all the names
    // values have different keys
    NSString *itemName = @"";
    for (NSString *propertyKey in [self _cachedPropertyValues]) {
        
        if ([propertyKey.lowercaseString containsString:@"name"] ||
            [propertyKey.lowercaseString containsString:@"title"]) {
            
            itemName = [self valueForEntityProperty:propertyKey];
            
            if ([propertyKey.lowercaseString isEqualToString:@"name"]) {
                break;
            }
            
        }
        
    }
    
    return itemName;
}

- (id)valueForEntityProperty:(NSString *)arg1
{
    if ([arg1 isEqualToString:@"musicWantsContextualActionsButton"]) {
        return @(NO);
    }
    
    return %orig(arg1);
}

%end




