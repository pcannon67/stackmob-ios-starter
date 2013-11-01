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

#import <UIKit/UIKit.h>

/*
 When a user taps on a row from the main table view, we transition to an instance of the todo detail view controller. It is passed the todo object corresponding to the row that was tapped so we can update or delete it if needed.
 */
@interface TodoDetailViewController : UIViewController <UITextFieldDelegate>

/*
 We declare a property to hold the todo object.
 */
@property (strong, nonatomic) NSDictionary *todoObject;
@property (weak, nonatomic) IBOutlet UITextField *todoTextField;

/*
 These actions are hooked up to the two buttons in our Storyboard's Todo Detail view.
 */
- (IBAction)saveTodo:(id)sender;
- (IBAction)deleteTodo:(id)sender;

@end
