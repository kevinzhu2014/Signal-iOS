//
//  Copyright (c) 2017 Open Whisper Systems. All rights reserved.
//

#import "AttachmentSharing.h"
#import "TSAttachmentStream.h"
#import "Threading.h"
#import "UIUtil.h"

@implementation AttachmentSharing

+ (void)showShareUIForAttachment:(TSAttachmentStream *)stream {
    OWSAssert(stream);

    [self showShareUIForURL:stream.mediaURL];
}

+ (void)showShareUIForURL:(NSURL *)url {
    OWSAssert(url);

    [AttachmentSharing showShareUIForActivityItems:@[
        url,
    ]];
}

+ (void)showShareUIForText:(NSString *)text
{
    OWSAssert(text);
    
    [AttachmentSharing showShareUIForActivityItems:@[
                                                     text,
                                                     ]];
}

+ (void)showShareUIForActivityItems:(NSArray *)activityItems
{
    OWSAssert(activityItems);

    DispatchMainThreadSafe(^{
        UIActivityViewController *activityViewController =
            [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:@[]];

        [activityViewController setCompletionWithItemsHandler:^(UIActivityType __nullable activityType,
            BOOL completed,
            NSArray *__nullable returnedItems,
            NSError *__nullable activityError) {

            DDLogDebug(@"%@ applying signal appearence", self.logTag);
            [UIUtil applySignalAppearence];

            if (activityError) {
                DDLogInfo(@"%@ Failed to share with activityError: %@", self.logTag, activityError);
            } else if (completed) {
                DDLogInfo(@"%@ Did share with activityType: %@", self.logTag, activityType);
            }
        }];

        // Find the frontmost presented UIViewController from which to present the
        // share view.
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIViewController *fromViewController = window.rootViewController;
        while (fromViewController.presentedViewController) {
            fromViewController = fromViewController.presentedViewController;
        }
        OWSAssert(fromViewController);
        [fromViewController presentViewController:activityViewController
                                         animated:YES
                                       completion:^{
                                           DDLogDebug(@"%@ applying default system appearence", self.logTag);
                                           [UIUtil applyDefaultSystemAppearence];
                                       }];
    });
}

@end
