//
//  SettingsTabController.m
//  Divinio Cricket
//
//  Copyright © 2018 Future Technologies in Sport. All rights reserved.
//  Author: Eric Bodnar
//

#import "SettingsTabController.h"

@interface SettingsTabController ()

@property (weak, nonatomic) IBOutlet UITableView * table;

@end

@implementation SettingsTabController

- (void) viewDidLoad {
        
    [super viewDidLoad];
    
    // Interested in environment updates
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTemperature:) name:kDeviceNoticeTemperature object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePressure:) name:kDeviceNoticePressure object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMoisture:) name:kDeviceNoticeMoisture object:nil];
    
    // Items in table are not selectable
    [self.table setAllowsSelection:NO];
    
}

#pragma mark - Table View Data Source and Delegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView { return ( kSettingsSections ); }

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch ( section ) {
        case kSettingsSectionDevice:        return @"Equipment";
        case kSettingsSectionOptions:       return @"Options";
        case kSettingsSectionEnvironment:   return @"Environment";
        case kSettingsSectionVersion:       return @"Version";
        default:                            return nil;
    }

}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {

    return nil;
    
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch ( section ) {
        case kSettingsSectionDevice:        return ( kDeviceSettings );
        case kSettingsSectionOptions:       return ( kOptionSettings );
        case kSettingsSectionEnvironment:   return ( kEnvironmentSettings );
        case kSettingsSectionVersion:       return ( kVersionSettings );
        default:                            return ( 0 );
    }
    
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *   cell    = nil;
    
    switch ( indexPath.section ) {
            
        case kSettingsSectionDevice: switch ( indexPath.row ) {
            case kDeviceSettingName:
                cell    = [tableView dequeueReusableCellWithIdentifier:@"settingsEditCell" forIndexPath:indexPath];
                [(SettingsEditCell *)cell setDelegate:self];
                [(SettingsEditCell *)cell setTitleText:@"Name"];
                [(SettingsEditCell *)cell setPlaceholderText:@"Bat name"];
                [(SettingsEditCell *)cell setTitleImage:[UIImage imageNamed:@"Edit"]];
                [(SettingsEditCell *)cell setTextField:self.deviceName];
                [(SettingsEditCell *)cell setId:kDeviceSettingName];
                [(SettingsEditCell *)cell setEmptyAllowed:NO];
              break;
            case kDeviceSettingMake:
                cell    = [tableView dequeueReusableCellWithIdentifier:@"settingsEditCell" forIndexPath:indexPath];
                [(SettingsEditCell *)cell setDelegate:self];
                [(SettingsEditCell *)cell setTitleText:@"Make"];
                [(SettingsEditCell *)cell setPlaceholderText:self.deviceMake];
                [(SettingsEditCell *)cell setTitleImage:[UIImage imageNamed:@"Make"]];
                [(SettingsEditCell *)cell setTextField:self.equipmentMake];
                [(SettingsEditCell *)cell setId:kDeviceSettingMake];
                break;
            case kDeviceSettingModel:
                cell    = [tableView dequeueReusableCellWithIdentifier:@"settingsEditCell" forIndexPath:indexPath];
                [(SettingsEditCell *)cell setDelegate:self];
                [(SettingsEditCell *)cell setTitleText:@"Model"];
                [(SettingsEditCell *)cell setPlaceholderText:self.deviceModel];
                [(SettingsEditCell *)cell setTitleImage:[UIImage imageNamed:@"Model"]];
                [(SettingsEditCell *)cell setTextField:self.equipmentModel];
                [(SettingsEditCell *)cell setId:kDeviceSettingModel];
                break;
            case kDeviceSettingNumber:
                cell  = [tableView dequeueReusableCellWithIdentifier:@"settingsDetailCell" forIndexPath:indexPath];
                [(SettingsDetailCell *)cell setTitleText:@"Number"];
                [(SettingsDetailCell *)cell setDetailText:self.deviceNumber];
                break;
        } break;
            
        case kSettingsSectionOptions: switch ( indexPath.row ) {
            case kOptionSettingTaps:
                cell    = [tableView dequeueReusableCellWithIdentifier:@"settingsOptionCell" forIndexPath:indexPath];
                [(SettingsOptionCell *)cell setDelegate:self];
                [(SettingsOptionCell *)cell setId:kOptionSettingTaps];
                [(SettingsOptionCell *)cell setTitleText:@"Tap rejection"];
                [(SettingsOptionCell *)cell setTitleImage:[UIImage imageNamed:@"Practice"]];
                [(SettingsOptionCell *)cell setState:self.tapRejection];
                break;
            case kOptionSettingTournament:
                cell    = [tableView dequeueReusableCellWithIdentifier:@"settingsOptionCell" forIndexPath:indexPath];
                [(SettingsOptionCell *)cell setDelegate:self];
                [(SettingsOptionCell *)cell setId:kOptionSettingTournament];
                [(SettingsOptionCell *)cell setTitleText:@"Tournament play"];
                [(SettingsOptionCell *)cell setTitleImage:[UIImage imageNamed:@"Play"]];
                [(SettingsOptionCell *)cell setState:(self.deviceFormat == kDevicePlayTournament ? YES : NO)];
                break;
        } break;

        case kSettingsSectionEnvironment: switch ( indexPath.row ) {
            case kEnvironmentTemperature:
                cell    = [tableView dequeueReusableCellWithIdentifier:@"settingsValueCell" forIndexPath:indexPath];
                [(SettingsValueCell *)cell setTitleText:@"Temperature"];
                [(SettingsValueCell *)cell setTitleImage:[UIImage imageNamed:@"Temperature"]];
                [(SettingsValueCell *)cell setDetailText:[self settingsTemperatureDetail]];
                break;
            case kEnvironmentMoisture:
                cell    = [tableView dequeueReusableCellWithIdentifier:@"settingsValueCell" forIndexPath:indexPath];
                [(SettingsValueCell *)cell setTitleText:@"Humidity"];
                [(SettingsValueCell *)cell setTitleImage:[UIImage imageNamed:@"Moisture"]];
                [(SettingsValueCell *)cell setDetailText:[self settingsMoistureDetail]];
                break;
            case kEnvironmentPressure:
                cell    = [tableView dequeueReusableCellWithIdentifier:@"settingsValueCell" forIndexPath:indexPath];
                [(SettingsValueCell *)cell setTitleText:@"Pressure"];
                [(SettingsValueCell *)cell setTitleImage:[UIImage imageNamed:@"Pressure"]];
                [(SettingsValueCell *)cell setDetailText:[self settingsPressureDetail]];
                break;
        } break;
            
        case kSettingsSectionVersion: switch ( indexPath.row ) {
            case kVersionSettingRevision:
                cell    = [tableView dequeueReusableCellWithIdentifier:@"settingsDetailCell" forIndexPath:indexPath];
                [(SettingsDetailCell *)cell setTitleText:@"Version"];
                [(SettingsDetailCell *)cell setDetailText:self.deviceVersion];
                if ( self.deviceUpdateAvailable ) {
                    [(SettingsDetailCell *)cell setActionText:@"Update"];
                    [(SettingsDetailCell *)cell addActionTarget:self action:@selector(doVersionUpdate:)];
                }
                break;
        } break;
    
    }
            
    return ( cell );

}

- (NSString *) settingsTemperatureDetail {
    
    NSNumber * value    = [self deviceTemperature];
    NSString * detail   = value ? [NSString stringWithFormat:@"%1.1f\u00B0C", [value floatValue]] : @"--";
    
    return ( detail );
    
}

- (NSString *) settingsMoistureDetail {
    
    NSNumber * value    = [self deviceMoisture];
    NSString * detail   = value ? [NSString stringWithFormat:@"%1.1f%%", [value floatValue]] : @"--";

    return ( detail );
    
}

- (NSString *) settingsPressureDetail {
    
    NSNumber * value    = [self devicePressure];
    NSString * detail   = value ? [NSString stringWithFormat:@"%1.1f bar", [value floatValue]] : @"--";
    
    return ( detail );
    
}

#pragma mark - Device characteristic updates

- (void) didReceiveTemperature:(NSNotification *)notification {
    
    NSIndexPath *       index   = [NSIndexPath indexPathForRow:kEnvironmentTemperature inSection:kSettingsSectionEnvironment];

    dispatch_async ( dispatch_get_main_queue(), ^{
        [self.table reloadRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationNone];
    } );
    
}

- (void) didReceivePressure:(NSNotification *)notification {
    
    NSIndexPath *       index   = [NSIndexPath indexPathForRow:kEnvironmentPressure inSection:kSettingsSectionEnvironment];
    
    dispatch_async ( dispatch_get_main_queue(), ^{
        [self.table reloadRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationNone];
    } );
    
}

- (void) didReceiveMoisture:(NSNotification *)notification {
    
    NSIndexPath *       index   = [NSIndexPath indexPathForRow:kEnvironmentMoisture inSection:kSettingsSectionEnvironment];

    dispatch_async ( dispatch_get_main_queue(), ^{
        [self.table reloadRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationNone];
    } );
    
}

# pragma mark - Settings cell delegates

- (void) settingsOptionCell:(SettingsOptionCell *)cell didChangeState:(bool)state {
    
    switch ( cell.id ) {
        case kOptionSettingTaps:        [self setTapRejection:state]; break;
        case kOptionSettingTournament:  [self setDeviceFormat:(state ? kDevicePlayTournament : kDevicePlayPractice)]; break;
    }
    
}

- (void) settingsEditCell:(SettingsEditCell *)cell didUpdateText:(NSString *)text {
    
    switch ( cell.id ) {
        case kDeviceSettingName:        [self setDeviceName:text]; break;
        case kDeviceSettingMake:        [self setEquipmentMake:text]; break;
        case kDeviceSettingModel:       [self setEquipmentModel:text]; break;
    }

}


- (void) doVersionUpdate:(id)sender {

    // ** update goes here **
    
}

@end
