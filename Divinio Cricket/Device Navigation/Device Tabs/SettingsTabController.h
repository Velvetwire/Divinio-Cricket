//
//  SettingsTabController.h
//  Divinio Cricket
//
//  Copyright © 2018 Future Technologies in Sport. All rights reserved.
//  Author: Eric Bodnar
//

#import "ConnectionPageController.h"

#import "SettingsDetailCell.h"
#import "SettingsOptionCell.h"
#import "SettingsValueCell.h"
#import "SettingsEditCell.h"

typedef NS_ENUM( NSInteger, SettingsSection ) {
    kSettingsSectionDevice,
    kSettingsSectionOptions,
    kSettingsSectionEnvironment,
    kSettingsSectionVersion,
    kSettingsSections
};

typedef NS_ENUM( NSInteger, DeviceSetting ) {
    kDeviceSettingName,
    kDeviceSettingMake,
    kDeviceSettingModel,
    kDeviceSettingNumber,
    kDeviceSettings
};

typedef NS_ENUM( NSInteger, OptionSetting ) {
    kOptionSettingTaps,
    kOptionSettingTournament,
    kOptionSettings
};

typedef NS_ENUM( NSInteger, EnvironmentSetting ) {
    kEnvironmentTemperature,
    kEnvironmentMoisture,
    kEnvironmentPressure,
    kEnvironmentSettings
};

typedef NS_ENUM( NSInteger, VersionSetting ) {
    kVersionSettingRevision,
    kVersionSettings
};

@interface SettingsTabController : ConnectionPageController <UITableViewDataSource, UITableViewDelegate, SettingsEditCellDelegate, SettingsOptionCellDelegate>

@end
