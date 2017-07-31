//
//  SettingsController.m
//  AbbottMobile
//
//  Created by Alexander Voronov on 17/6/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import "SettingsController.h"
#import "Underscore.h"

@implementation SettingsController

- (Setting *)fetchSettingsByKey:(NSString *)key
{
    SFQuerySpec *querySpec = [self buildSmartQuery:[self settingsValueByKeyQuery:key]];
    NSArray *settings = [self fetchEntitiesWithQuerySpec:querySpec];
    NSDictionary *settingsItem = Underscore.array(settings).flatten.first;
    return [self parseEntity:settingsItem];
}

- (NSString *)settingsValueByKeyQuery:(NSString *)key
{
    NSString *tableName = [Setting tableName];
    NSString *select = [NSString stringWithFormat:@"SELECT {%@:_soup} FROM {%@}", tableName, tableName];
    NSString *where = [NSString stringWithFormat:@"WHERE {%@:%@} = '%@'", tableName, [Setting keyFieldName], key];
    return [NSString stringWithFormat:@"%@ %@", select, where];
}

- (NSArray *)upsertSettings:(NSArray *)settings
{
    NSArray *settingsObjs = Underscore.arrayMap(settings, ^(Setting *setting) {
        return [NSDictionary dictionaryWithObjects:@[setting.key, setting.value] forKeys:@[[Setting keyFieldName], [Setting valueFieldName]]];
    });
    return [self.smartStore upsertEntries:settingsObjs toSoup:[Setting tableName] withExternalIdPath:@"key" error:nil];
}

#pragma mark - Parseable implementation

- (id<Entity>)parseEntity:(NSDictionary *)entityObj
{
    Setting *setting = [Setting new];
    setting.key = entityObj[[Setting keyFieldName]];
    setting.value = entityObj[[Setting valueFieldName]];
    return [setting autorelease];
}

@end
