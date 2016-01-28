//
//  SWCelloContextualActionsPSListController.mm
//  CelloPrefs
//
//  Created by Pat Sluth on 2015-04-25.
//
//

#import <Preferences/Preferences.h>

#import "libsw/libSluthware/SWPrefs.h"





@interface SWCelloContextualActionsPSViewController : PSEditableListController
{
}

@property (strong, nonatomic) SWPrefs *prefs;

@end





@implementation SWCelloContextualActionsPSViewController

#pragma mark - Init

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.editing = YES;
	self.table.editing = YES;
	[self setEditingButtonHidden:YES animated:NO];
}

- (id)specifiers
{
    if (!_specifiers) {
        
        NSMutableArray *celloSpecifiers = [@[] mutableCopy];
		
		
		// Get current preference value's
		NSString *key = [self.specifier.properties valueForKey:@"key"];
		NSDictionary *preferenceValue = [self.prefs.preferences valueForKey:key];
		NSMutableArray *enabledActions = [[preferenceValue valueForKey:@"enabled"] mutableCopy];
		NSMutableArray *disabledActions = [[preferenceValue valueForKey:@"disabled"] mutableCopy];
	
		
        // Enabled options
        PSSpecifier *enabledGroup = [PSSpecifier groupSpecifierWithName:@"enabled"];
        [celloSpecifiers addObject:enabledGroup];
        
        for (NSDictionary *action in enabledActions) {
            
            PSSpecifier *spec = [PSSpecifier preferenceSpecifierNamed:[action valueForKey:@"title"]
                                                               target:self
                                                                  set:NULL
                                                                  get:NULL
                                                               detail:Nil
                                                                 cell:PSTitleValueCell
                                                                 edit:Nil];
            spec.identifier = [action valueForKey:@"key"];
            [celloSpecifiers addObject:spec];
            
        }
        
        // Disabled options
        PSSpecifier *disabledGroup = [PSSpecifier groupSpecifierWithName:@"disabled"];
        [celloSpecifiers addObject:disabledGroup];
        
        for (NSDictionary *action in disabledActions) {
            
            PSSpecifier *spec = [PSSpecifier preferenceSpecifierNamed:[action valueForKey:@"title"]
                                                               target:self
                                                                  set:NULL
                                                                  get:NULL
                                                               detail:Nil
                                                                 cell:PSTitleValueCell
                                                                 edit:Nil];
            spec.identifier = [action valueForKey:@"key"];
            [celloSpecifiers addObject:spec];
            
        }
        
        _specifiers = [celloSpecifiers copy];
    }
    
    return _specifiers;
}

#pragma mark - UITableView

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
	// Get current preference value's
	NSString *key = [self.specifier.properties valueForKey:@"key"];
	NSMutableDictionary *preferenceValue = [[self.prefs.preferences valueForKey:key] mutableCopy];
    NSMutableArray *enabledActions = [[preferenceValue valueForKey:@"enabled"] mutableCopy];
    NSMutableArray *disabledActions = [[preferenceValue valueForKey:@"disabled"] mutableCopy];
    
    // Get references to source and destination arrays
    NSMutableArray *sourceArray = (sourceIndexPath.section == 0) ? enabledActions : disabledActions;
    NSMutableArray *destinationArray = (destinationIndexPath.section == 0) ? enabledActions : disabledActions;
    
    // Move our value to the correct position in our destination array
    id sourceValue = [sourceArray objectAtIndex:sourceIndexPath.row];
    [sourceArray removeObject:sourceValue];
    [destinationArray insertObject:sourceValue atIndex:destinationIndexPath.row];
    
    // Update data source
	[preferenceValue setValue:[enabledActions copy] forKey:@"enabled"];
	[preferenceValue setValue:[disabledActions copy] forKey:@"disabled"];
	[self.prefs savePreferenceValue:[preferenceValue copy] forKey:key synchronize:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (cell) {
        cell.showsReorderControl = YES;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - SWPrefs

/**
 *  Lazy Load prefs
 *
 *  @return prefs
 */
- (SWPrefs *)prefs
{
	if (!_prefs) {
		
		NSString *preferencePath = @"/var/mobile/Library/Preferences/com.patsluth.cello.plist";
		NSString *defaultsPath = [self.bundle pathForResource:@"prefsDefaults" ofType:@".plist"];
		
		_prefs = [[SWPrefs alloc] initWithPreferenceFilePath:preferencePath
												defaultsPath:defaultsPath
												 application:@"com.patsluth.cello"];
	}
	
	return _prefs;
}

@end




