//
//  MNDPodcast.h
//  Downloader
//
//  Created by Haldun Bayhantopcu on 20/10/13.
//  Copyright (c) 2013 Monoid. All rights reserved.
//

@import Foundation;

@class MNDDownload;

@interface MNDPodcast : NSObject

@property (copy, nonatomic) NSNumber *identifier;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *url;
@property (strong, nonatomic) MNDDownload *activeDownload;

- (instancetype)initWithIdentifier:(NSNumber *)identifier title:(NSString *)title url:(NSString *)url;

@end
