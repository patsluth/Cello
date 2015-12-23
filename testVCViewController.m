//
//  testVCViewController.m
//  Cello
//
//  Created by Pat Sluth on 2015-12-22.
//
//

#import "testVCViewController.h"

@interface testVCViewController ()

@end

@implementation testVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems
{
    NSLog(@"PAT TES");
    // setup a list of preview actions
    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"Post to Facebook" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
        
    }];
    
    UIPreviewAction *action2 = [UIPreviewAction actionWithTitle:@"Message" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
        
    }];
    
    UIPreviewAction *action3 = [UIPreviewAction actionWithTitle:@"Email" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
    }];
    
    return @[action1, action2, action3];
}

@end
