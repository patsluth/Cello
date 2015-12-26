//
//  SWCelloMediaEntityPreviewViewController.h
//  Cello
//
//  Created by Pat Sluth on 2015-12-25.
//
//

#ifndef SWCelloMediaEntityPreviewViewController_h
#define SWCelloMediaEntityPreviewViewController_h

@protocol SWCelloMediaEntityPreviewViewController <NSObject>

@required

@property (strong, nonatomic) NSArray<id<UIPreviewActionItem>> *celloPreviewActionItems;

@end

#endif /* SWCelloMediaEntityPreviewViewController_h */




