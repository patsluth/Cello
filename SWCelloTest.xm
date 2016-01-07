////
////  SWCelloTest.xm
////  Cello
////
////  Created by Pat Sluth on 2015*12*27.
////
////
////
//
//
//#import "MusicMediaProductDetailViewController.h"
//
//
//%hook MusicMediaProductDetailViewController
//
//-(id)initWithContainerEntityProvider:(id)arg1
//tracklistEntityProvider:(id)arg2
//clientContext:(id)arg3
//existingJSProductNativeViewController:(id)arg4
//forContentCreation:(BOOL)arg5
//{
//    // Create our view controller without the tracklist, so it loads faster
//    self = %orig(arg1, nil, arg3, arg4, arg5);
//    
//    if (self) {
//        
//        
//        if (arg2 != nil) {
//            
//            
//            
//            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
//            dispatch_async(queue, ^{
//                
//                
//                // create identical view controller with full tracklist on background thread
//                id completeSelf = %orig(arg1, arg2, arg3, arg4, arg5);
//                
//                dispatch_sync(dispatch_get_main_queue(), ^{
//                    self.celloCommitViewController = completeSelf;
//                });
//            });
//            
//            
//        }
//
//        
//        
//    }
//    
//    return self;
//}
//
//%end
//
//
//
