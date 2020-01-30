//
//  TableViewController.m
//  todo2
//
//  Created by Oliver Lennartsson on 2020-01-22.
//  Copyright © 2020 Oliver Lennartsson. All rights reserved.
//

//TODO: Fixa så att man i dubbelklickad alertview kan "prioritera" och visa ett mark i sidan för det
//TODO: Fixa en till sektion med avslutade tasks och gör så att man kan genom alertview trycka på complete för att skicka tasken till en annan sektion.

#import "TableViewController.h"
#import "DatabaseHelper.h"
#import "Items.h"
@import Firebase;
@import FirebaseDatabase;

@interface TableViewController () <UIAlertViewDelegate>

@property (nonatomic) NSMutableArray *items;
@property (nonatomic) NSMutableArray *completed;
@property (nonatomic) NSMutableArray *sections;
@property (nonatomic) FIRDatabaseReference *ref;
@property (nonatomic) FIRDatabaseHandle *handle;
@property (nonatomic) NSString *savedItemFromDB;
@property (nonatomic) DatabaseHelper *dbHelper;
@end

@implementation TableViewController

#pragma mark - viewDidLoad

- (void)viewDidLoad {
    [super viewDidLoad];
    // Databas referens
    self.ref = [[FIRDatabase database] reference];
    self.dbHelper = [[DatabaseHelper alloc]init];
    
    // Ladda in object från databas i tableview
    [[self.ref child:@"tasks"]observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        // Snygga till senare, for-loop
        NSDictionary *databaseDics = snapshot.value;
        NSMutableDictionary *dicWithKey = [[NSMutableDictionary alloc]init];
        dicWithKey[@"name"] = databaseDics[@"name"];
        dicWithKey[@"time"] = databaseDics[@"time"];
        dicWithKey[@"creator"] = databaseDics[@"creator"];
        dicWithKey[@"key"] = snapshot.key;
        //[databaseDics setObject:@"key" forKey:snapshot.key];
        
        NSLog(@"name : %@", dicWithKey[@"name"]);
        [self.items addObject:dicWithKey];
        
        [self.tableView reloadData];
       }];
     
    
    NSLog(@"arraylength %lu", self.items.count);
    //sektionarray
    self.sections = @[@"Uncompleted", @"Completed"].mutableCopy;
    //Test item
    self.items = @[@{@"name" : @"do this", @"time" : @"2012-10-09 09:05", @"creator" : @"Legolas" }].mutableCopy;
    // UI
    self.navigationItem.title = @"TO-DO's";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor orangeColor]}];
    //Ändra textfont senare
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewTodo:)];
    
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - add items
-(void)addNewTodo:(UIBarButtonItem*)sender {
    
    sender.tintColor = UIColor.orangeColor;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"New TO-DO task" message:@"Enter a new TO-DO!" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Write new task";
    }];
    // Add-button
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * ok) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"CET"]];
        
        NSString *currentTime = [formatter stringFromDate:[NSDate date]];
        NSString *newTaskTextField = [alertController textFields][0].text;
        
        NSDictionary *item = @{@"name" : newTaskTextField, @"time" : currentTime, @"creator" : @"Tijana"};
        
        NSLog(@"%@", [formatter stringFromDate:[NSDate date]]);
        // Add item to array
        //[self.items addObject:item];
        // Add item to database
        //[[[self.ref child:@"tasks"] childByAutoId]setValue:item];
        [self.dbHelper addItemToDatabase:item];
        
        
        NSLog(@"Added item %@", newTaskTextField);
        
        /*[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.items.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];*/
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * cancel) {
    }];
    
    [alertController addAction:ok];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - didSelectRowAtIndexPath

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *specificTask = self.items[indexPath.row][@"name"];
    NSDictionary *specificDic = self.items[indexPath.row];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Task" message:specificTask preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * cancel) {
            //cancel
    }];
    
    UIAlertAction *priority = [UIAlertAction actionWithTitle:@"Mark as important" style:UIAlertActionStyleDefault handler:^(UIAlertAction * cancel) {
            
            NSMutableDictionary *item = [self.items[indexPath.row] mutableCopy];
            BOOL completed = [item[@"completed"]boolValue];
            item[@"completed"] = @(!completed);
            
            self.items[indexPath.row] = item;
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = ([item[@"completed"]boolValue]) ? UITableViewCellAccessoryDetailButton : UITableViewCellAccessoryNone;
            cell.backgroundColor = ([item[@"completed"]boolValue]) ? UIColor.clearColor : UIColor.clearColor;
        
        
    }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Task completed" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * ok) {
        // skicka tasken till annan sektion.
        [self.completed addObject:specificDic];
        [tableView reloadData];
        //[self.items removeObject:specificDic];
        
    }];
    
    [alertController addAction:ok];
    [alertController addAction:priority];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return [self.sections objectAtIndex:section];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.completed.count < 1){
        return 1;
        
    }
    else {
        return 2;
    }
}

#pragma mark - numbers of rows in section

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"todoItemCells" forIndexPath:indexPath];
    
    NSDictionary *item = self.items[indexPath.row];
    
    cell.textLabel.textColor = UIColor.whiteColor;
    cell.detailTextLabel.textColor = UIColor.whiteColor;
    cell.textLabel.text = item[@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Created by %@ %@", item[@"creator"], item[@"time"]];

    if([item[@"completed"]boolValue ]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    if (indexPath.section==0) {
        NSDictionary *theCellData = [self.items objectAtIndex:indexPath.row];
        NSString *cellValue =theCellData[@"name"];
        cell.textLabel.text = cellValue;
    }
    else {
        NSDictionary *theCellData = [self.completed objectAtIndex:indexPath.row];
        NSString *cellValue = theCellData[@"name"];
        cell.textLabel.text = cellValue;
    }
    
        return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
 */


#pragma mark - Delete from tableview
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSDictionary *removeObjectFromDb = self.items[indexPath.row];
        NSString *removeObjectKey = removeObjectFromDb[@"key"];
        //remove from array
        [self.items removeObject:self.items[indexPath.row]];
        //remove from db
        FIRDatabaseReference *deleteObjectRef = [[self.ref child:@"tasks"]child:removeObjectKey];
        [deleteObjectRef removeValue];
        //[self.tableView reloadData];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
- (void)viewWillAppear:(BOOL)animated{
    
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
