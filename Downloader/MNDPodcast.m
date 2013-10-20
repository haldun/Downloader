//
//  MNDPodcast.m
//  Downloader
//
//  Created by Haldun Bayhantopcu on 20/10/13.
//  Copyright (c) 2013 Monoid. All rights reserved.
//

#import "MNDPodcast.h"

@implementation MNDPodcast

- (instancetype)initWithIdentifier:(NSNumber *)identifier title:(NSString *)title url:(NSString *)url
{
  self = [super init];
  if (self) {
    _identifier = [identifier copy];
    _title = [title copy];
    _url = [url copy];
  }
  return self;
}

@end
