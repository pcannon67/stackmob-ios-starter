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

#import "TodoTableViewController.h"
/*
 Import the StackMob, Todo and Detail View Controller headers.
 */
#import "StackMob.h"
#import "Todo.h"
#import "TodoDetailViewController.h"

@interface TodoTableViewController ()

/*
 We define an array to hold the fetched Todo objects.
 */
@property (strong, nonatomic) NSArray *objects;

/*
 We define two methods for refreshing the table view and inserting a new todo object.
 */
- (void)refreshTable;
- (void)insertNewTodo:(id)sender;

@end

@implementation TodoTableViewController

/*
 Synthesize the objects property we defined.
 */
@synthesize objects = _objects;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    /*
     When the view appears, we refresh the table.
     */
    [self refreshTable];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
     We add a right bar button which, when pressed will call the insertNewTodo: method.
     */
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewTodo:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    /*
     We initialize our refresh control and assign the refreshTable method to get called when the refresh is initiated. Then we initiate the refresh process.
     */
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    self.refreshControl  = refreshControl;
    [refreshControl beginRefreshing];
    [self refreshTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 Responsible for fetching all todo objects from StackMob and reloading the table view.
 */
- (void)refreshTable
{
    /*
     The first thing we do is acquire an initialized managed object context from our SMCoreDataStore instance.
     
     Then we create a fetch request for the Todo entity, sorted by the created date.
     
     Finally, we execute the fetch request, assign the results to our objects property, and reload the table data.
     */
    
    NSManagedObjectContext *context = [[[SMClient defaultClient] coreDataStore] contextForCurrentThread];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createddate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    [context executeFetchRequest:fetchRequest onSuccess:^(NSArray *results) {
        [self.refreshControl endRefreshing];
        self.objects = results;
        [self.tableView reloadData];
        
    } onFailure:^(NSError *error) {
        
        [self.refreshControl endRefreshing];
        NSLog(@"An error %@, %@", error, [error userInfo]);
    }];
}

/*
 Kicks off the "Add new todo" process by prompting the user to type the title of the new todo. When the user presses "Create", alertView:clickedButtonAtIndex: (below) is called.
 */
- (void)insertNewTodo:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add New Todo" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alertView textFieldAtIndex:0] setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
    
    [alertView show];
}

/*
 When the user presses any button on the alert, this delegate method is called.
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    /*
     If the user pressed "Create":
     
     * Obtain an initialized managed object context.
     * Create a new todo object in our context.
     * Assign it an ID and a title from the alert text field.
     * Save the context to persist the todo to StackMob, and on success refresh the table.
     
     */
    if (buttonIndex == 1) {
        
        NSManagedObjectContext *context = [[[SMClient defaultClient] coreDataStore] contextForCurrentThread];
        Todo *newTodo = [NSEntityDescription insertNewObjectForEntityForName:@"Todo" inManagedObjectContext:context];
        // assignObjectId is provided by the StackMob iOS SDK, and generates a random string ID for the object. This needs to be done for every new object before it is saved.
        newTodo.todoId = [newTodo assignObjectId];
        newTodo.title = [[alertView textFieldAtIndex:0] text];
        
        [self.refreshControl beginRefreshing];
        
        // An asynchronous Core Data save method provided by the StackMob iOS SDK.
        [context saveOnSuccess:^{
            [self refreshTable];
        } onFailure:^(NSError *error) {
            NSLog(@"Error saving todo: %@", error);
        }];
    }
    
}

#pragma mark - Table view data source
/*
 We will only have one section in our table view.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/*
 There will be as many rows as there are Todo objects.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.objects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    /*
     We will display the title of the Todo object corresponding to the current row.
     */
    Todo *todo = (Todo *)[self.objects objectAtIndex:indexPath.row];
    cell.textLabel.text = todo.title;
        
    return cell;
}

#pragma mark - Storyboard Transition
/*
 This method is called when we tap on a row in our table view. It allows us to do any work before transitioning to the new view.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
	if ([segue.identifier isEqualToString:@"TodoDetail"])
	{
        /*
         Obtain the TodoDetailViewController instance, and assign the Core Data managed object ID for this row to the todoObjectID property. This will allow the new view to load the managed object data.
         */
        TodoDetailViewController *destViewController = segue.destinationViewController;
        destViewController.todoObjectID = [[self.objects objectAtIndex:indexPath.row] objectID];
	}
}

/*
 Enables functionality such as "swipe to delete".
 */
- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return(YES);
}

/*
 Called after swiping to delete and pressing the "Delete" button.
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        /*
         If the "Delete" button was pressed:
         
         * Obtain an initialized managed object context.
         * Obtain the Todo managed object for the current row.
         * Delete the object in the context.
         * Save the context and on success refresh the table.
         
         */
        NSManagedObjectContext *context = [[[SMClient defaultClient] coreDataStore] contextForCurrentThread];
        
        Todo *todoObject = [self.objects objectAtIndex:indexPath.row];
        [context deleteObject:todoObject];
        
        // An asynchronous Core Data save method provided by the StackMob iOS SDK.
        [context saveOnSuccess:^{
            NSLog(@"Delete success");
            [self refreshTable];
        } onFailure:^(NSError *error) {
            NSLog(@"Error saving: %@", error);
        }];
    }
}



@end
