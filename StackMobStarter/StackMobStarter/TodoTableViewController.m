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
    [self.refreshControl beginRefreshing];
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
     Create a query on the todo schema, sorted by the created date.
     
     Then perform the query, assign the results to our objects property, and reload the table data.
     */
    
    SMQuery *query = [[SMQuery alloc] initWithSchema:@"todo"];
    
    [query orderByField:@"createddate" ascending:NO];
    
    [[[SMClient defaultClient] dataStore] performQuery:query onSuccess:^(NSArray *results) {
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
     
     * Create a dictionary and set the text field value for the todo's title field.
     * Create a new todo object via the datastore.
     
     */
    if (buttonIndex == 1) {
        
        NSDictionary *todoDict = [NSDictionary dictionaryWithObjectsAndKeys:[[alertView textFieldAtIndex:0] text], @"title", nil];
        
        [self.refreshControl beginRefreshing];
        
        [[[SMClient defaultClient] dataStore] createObject:todoDict inSchema:@"todo" onSuccess:^(NSDictionary *object, NSString *schema) {
            [self refreshTable];
        } onFailure:^(NSError *error, NSDictionary *object, NSString *schema) {
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
     We will display the title of the todo object corresponding to the current row.
     */
    cell.textLabel.text = [[self.objects objectAtIndex:indexPath.row] objectForKey:@"title"];
        
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
         Obtain the TodoDetailViewController instance, and assign the todo object for this row to the todoObject property. This will allow the new view to display the object data.
         */
        TodoDetailViewController *destViewController = segue.destinationViewController;
        destViewController.todoObject = [self.objects objectAtIndex:indexPath.row];
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
         
         * Obtain the todo object for the current row.
         * Delete the object based on its ID.
         
         */
        NSDictionary *todoObject = [self.objects objectAtIndex:indexPath.row];
        NSString *todo_id = [todoObject objectForKey:@"todo_id"];
        
        [[[SMClient defaultClient] dataStore] deleteObjectId:todo_id inSchema:@"todo" onSuccess:^(NSString *objectId, NSString *schema) {
            NSLog(@"Delete success");
            [self refreshTable];
        } onFailure:^(NSError *error, NSString *objectId, NSString *schema) {
            NSLog(@"Error saving: %@", error);
        }];
    }
}



@end
