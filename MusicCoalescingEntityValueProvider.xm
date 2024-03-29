//
//  MusicCoalescingEntityValueProvider.xm
//  Cello
//
//  Created by Pat Sluth on 2015-12-21.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import "MusicCoalescingEntityValueProvider+SW.h"





%hook MusicCoalescingEntityValueProvider

%new
- (NSString *)cello_EntityNameBestGuess
{
    // try and find the best cached name for current item
    // this will happen for all media types (artist, song, playlist) and all the names
    // values have different keys
	NSString *itemName = [self valueForEntityProperty:@"name"];
	
	if (!itemName || [itemName isEqualToString:@""]) {
		itemName = [self valueForEntityProperty:@"title"];
	}
    
    return itemName;
}

%new
- (BOOL)isLocal
{
	id isLocal = [self valueForEntityProperty:@"isLocal"];
	id keepLocal = [self valueForEntityProperty:@"keepLocal"];
	
	if (isLocal != nil) {
		if ([keepLocal integerValue] == 1) {
			return YES;
		} else {
			return NO;
		}
	}
	if (keepLocal != nil) {
		if ([keepLocal integerValue] == 1) {
			return YES;
		} else {
			return NO;
		}
	}
	
	return NO;
}

- (id)valueForEntityProperty:(NSString *)arg1
{
    // hide contextual button
    if ([arg1 isEqualToString:@"musicWantsContextualActionsButton"]) {
        return @(NO);
    }
	
    return %orig(arg1);
}

%end




