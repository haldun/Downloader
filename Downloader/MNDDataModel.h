//
//  MNDDataModel.h
//  Downloader
//
//  Created by Haldun Bayhantopcu on 20/10/13.
//  Copyright (c) 2013 Monoid. All rights reserved.
//

@import Foundation;
@import CoreData;

@interface MNDDataModel : NSObject

@property (readonly, nonatomic) NSManagedObjectContext *mainContext;
@property (readonly, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype)sharedDataModel;

@end
