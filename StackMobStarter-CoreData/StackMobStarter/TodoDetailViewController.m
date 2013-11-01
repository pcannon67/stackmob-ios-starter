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

@interface TodoDetailViewController ()

/*
 We declare a managed object context property.
 */
@property (strong, nonatomic) NSManagedObjectContext *context;

@end

@implementation TodoDetailViewController

/*
 Synthesize the todoObjectID and context properties we defined.
 */
@synthesize todoObjectID = _todoObjectID;
@synthesize context = _context;


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
     First we obtain an initialized managed object context.
     Next we create a Todo instance from the managed object ID passed from the main todo table.
     Finally, we set the text field with the current title of the todo.
     */
    self.context = [[[SMClient defaultClient] coreDataStore] contextForCurrentThread];
    Todo *todoObject = (Todo *)[self.context objectWithID:self.todoObjectID];
    self.todoTextField.text = todoObject.title;
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
     
     * Obtain the Todo managed object instance.
     * Update the title of the todo with the text of the text field, if it differs from the current title.
     * Save the context, which persists the update to StackMob, and on success pop back to the main todo table.
     
     */
    
    Todo *todoObject = (Todo *)[self.context objectWithID:self.todoObjectID];
    if (![todoObject.title isEqualToString:self.todoTextField.text]) {
        todoObject.title = self.todoTextField.text;
        
        // An asynchronous Core Data save method provided by the StackMob iOS SDK.
        [self.context saveOnSuccess:^{
            NSLog(@"Save success");
            [self.navigationController popViewControllerAnimated:YES];
        } onFailure:^(NSError *error) {
            NSLog(@"Error saving: %@", error);
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)deleteTodo:(id)sender {
    
    /*
     Delete workflow:
     
     * Obtain the Todo managed object instance.
     * Delete the object in the context.
     * Save the context, which persists the delete to StackMob, and on success pop back to the main todo table.
     
     */
    
    Todo *todoObject = (Todo *)[self.context objectWithID:self.todoObjectID];
    [self.context deleteObject:todoObject];
    
    // An asynchronous Core Data save method provided by the StackMob iOS SDK.
    [self.context saveOnSuccess:^{
        NSLog(@"Delete success");
        [self.navigationController popViewControllerAnimated:YES];
    } onFailure:^(NSError *error) {
        NSLog(@"Error saving: %@", error);
    }];
    
}
@end
