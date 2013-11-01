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
 We define the 2 main components of the StackMob iOS SDK:
 
 An SMClient instance is used as the outlet to every other SDK component we might use.
 An SMCoreDataStore instance initializes our custom Core Data stack and gets it ready for persistence. It will also be our outlet for interacting with the caching and syncing systems.
 */
@property (strong, nonatomic) SMClient *client;
@property (strong, nonatomic) SMCoreDataStore *coreDataStore;

@end

@implementation AppDelegate

@synthesize managedObjectModel = _managedObjectModel;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /*
     Initialization of the StackMob components.
     
     We also turn on the caching system so fetched objects are stored locally and loading them into memory does not require additional network calls.
     */
    SM_CACHE_ENABLED = YES;
    self.client = [[SMClient alloc] initWithAPIVersion:@"0" publicKey:@"YOUR_PUBLIC_KEY"];
    self.coreDataStore = [self.client coreDataStoreWithManagedObjectModel:self.managedObjectModel];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

/*
 Modified method to call StackMob saveAndWait: when application terminates.
 */
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [[[SMClient defaultClient] coreDataStore] contextForCurrentThread];
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext saveAndWait:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/*
 StackMob only needs the developer to initialize the managed object model. The persistent store coordinator and managed object context are initialized by the StackMob iOS SDK.
 
 Here we initialize the managed object model if it is nil.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"StackMobStarterProject" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

@end
