//
//  CelloMediaEntityPreviewViewController.m
//  Cello
//
//  Created by Pat Sluth on 2015-12-23.
//
//

#import "CelloMediaEntityPreviewViewController.h"





@interface CelloMediaEntityPreviewViewController ()
{
}
@end





@implementation CelloMediaEntityPreviewViewController

- (id)init
{
    self = [super init];
    
    if (self) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        self.view = view;
    }
    
    return self;
}

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems
{
    return self.celloPreviewActionItems;
}

@end




