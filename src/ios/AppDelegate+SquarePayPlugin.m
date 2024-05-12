#import "AppDelegate+SquarePayPlugin.h"
@import SquareInAppPaymentsSDK;

@implementation AppDelegate(SquarePayPlugin)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [super application:application didFinishLaunchingWithOptions:launchOptions];
  NSLog(@"[SquarePayPlugin]********Application Did Launch**********");
  //testing
  [SQIPInAppPaymentsSDK setSquareApplicationID:@"sandbox-REPLACE"];
  return YES;
}

@end