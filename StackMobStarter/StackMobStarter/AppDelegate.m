/**
 * Copyright 2012-2013 StackMob
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AppDelegate.h"
/*
 Import the StackMob header.
 */
#import "StackMob.h"

@interface AppDelegate ()

/*
 We define the main component of the StackMob iOS SDK:
 
 An SMClient instance is used as the outlet to every other SDK component we might use.
*/
@property (strong, nonatomic) SMClient *client;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /*
     Initialization of the StackMob components.
     
     We also turn on the caching system so fetched objects are stored locally and loading them into memory does not require additional network calls.
     */
    self.client = [[SMClient alloc] initWithAPIVersion:@"0" publicKey:@"YOUR_PUBLIC_KEY"];
    
    return YES;
}

@end
