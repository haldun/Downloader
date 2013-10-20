//
//  MNDDownload.h
//  Downloader
//
//  Created by Haldun Bayhantopcu on 20/10/13.
//  Copyright (c) 2013 Monoid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MNDDownload : NSManagedObject

@property (nonatomic, retain) NSNumber * downloadableIdentifier;
@property (nonatomic, retain) NSString * downloadableType;
@property (nonatomic, retain) NSNumber * bytesWritten;
@property (nonatomic, retain) NSNumber * expectedBytesWritten;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSDate * startedAt;

@end
