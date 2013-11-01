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

#import "TodoDetailViewController.h"
/*
 Import the StackMob and Todo headers.
 */
#import "StackMob.h"
#import "Todo.h"

@implementation TodoDetailViewController

/*
 Synthesize the todoObjectID and context properties we defined.
 */
@synthesize todoObject = _todoObject;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /*
     Set the text field with the current title of the todo.
     */
    self.todoTextField.text = [self.todoObject objectForKey:@"title"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (IBAction)saveTodo:(id)sender {
    
    /*
     Update workflow:
     
     * Update the title of the todo with the text of the text field, if it differs from the current title.
     * Save the object, which persists the update to StackMob, and on success pop back to the main todo table.
     
     */
    
    if (![[self.todoObject objectForKey:@"title"] isEqualToString:self.todoTextField.text]) {
        NSMutableDictionary *updateDict = [self.todoObject mutableCopy];
        [updateDict setObject:self.todoTextField.text forKey:@"title"];
        
        [[[SMClient defaultClient] dataStore] updateObjectWithId:[self.todoObject objectForKey:@"todo_id"] inSchema:@"todo" update:updateDict onSuccess:^(NSDictionary *object, NSString *schema) {
            NSLog(@"Save success");
            [self.navigationController popViewControllerAnimated:YES];
        } onFailure:^(NSError *error, NSDictionary *object, NSString *schema) {
            NSLog(@"Error saving: %@", error);
        }];

    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)deleteTodo:(id)sender {
    
    /*
     Delete workflow:
     
     * Delete the object, which persists the delete to StackMob, and on success pop back to the main todo table.
     
     */
    
    [[[SMClient defaultClient] dataStore] deleteObjectId:[self.todoObject objectForKey:@"todo_id"] inSchema:@"todo" onSuccess:^(NSString *objectId, NSString *schema) {
        NSLog(@"Delete success");
        [self.navigationController popViewControllerAnimated:YES];
    } onFailure:^(NSError *error, NSString *objectId, NSString *schema) {
        NSLog(@"Error saving: %@", error);
    }];
    
}
@end
