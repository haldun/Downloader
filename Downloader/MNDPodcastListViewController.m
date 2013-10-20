//
//  MNDPodcastListViewController.m
//  Downloader
//
//  Created by Haldun Bayhantopcu on 20/10/13.
//  Copyright (c) 2013 Monoid. All rights reserved.
//

#import "MNDPodcastListViewController.h"
#import "MNDPodcast.h"
#import "MNDDataModel.h"
#import "MNDDownload.h"

@interface MNDPodcastListViewController ()

@property (strong, nonatomic) NSArray *podcasts;

@end

@implementation MNDPodcastListViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self fetchDownloads];
}

- (void)fetchDownloads
{
  NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
  context.persistentStoreCoordinator = [[MNDDataModel sharedDataModel] persistentStoreCoordinator];
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Download"];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloadableType = %@", @"Podcast"];
  fetchRequest.predicate = predicate;
  
  NSError *error;
  NSArray *downloads = [context executeFetchRequest:fetchRequest error:&error];
  
  if (error) {
    NSLog(@"%@", error);
    return;
  }
  
  // TODO MxN here!
  for (MNDDownload *download in downloads) {
    for (MNDPodcast *podcast in self.podcasts) {
      if ([download.downloadableIdentifier isEqualToNumber:podcast.identifier]) {
        NSLog(@"found an active download for podcast: %@", podcast.identifier);
        podcast.activeDownload = download;
      }
    }
  }
  
  [self.tableView reloadData];
}

- (NSArray *)podcasts
{
  if (!_podcasts) {
    _podcasts = @[
                  [[MNDPodcast alloc] initWithIdentifier:@1
                                                   title:@"Podcast 1"
                                                     url:@"http://asset.powerfm.com.tr/CenkErdem/podcast/CENKERDEM01022013.mp3"],
                  [[MNDPodcast alloc] initWithIdentifier:@2
                                                   title:@"Podcast 2"
                                                     url:@"http://asset.powerfm.com.tr/CenkErdem/podcast/CENKERDEM01032012.mp3"],
                  [[MNDPodcast alloc] initWithIdentifier:@3
                                                   title:@"Podcast 3"
                                                     url:@"http://asset.powerfm.com.tr/CenkErdem/podcast/CENKERDEM01032013.mp3"],
                  [[MNDPodcast alloc] initWithIdentifier:@4
                                                   title:@"Podcast 4"
                                                     url:@"http://asset.powerfm.com.tr/CenkErdem/podcast/CENKERDEM01042013.mp3"],
                  [[MNDPodcast alloc] initWithIdentifier:@5
                                                   title:@"Podcast 5"
                                                     url:@"http://asset.powerfm.com.tr/CenkErdem/podcast/CENKERDEM01052013.mp3"],
                  [[MNDPodcast alloc] initWithIdentifier:@6
                                                   title:@"Podcast 6"
                                                     url:@"http://asset.powerfm.com.tr/CenkErdem/podcast/CENKERDEM01062011.mp3"],
                  ];
  }
  return _podcasts;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.podcasts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"PodcastCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  MNDPodcast *podcast = self.podcasts[indexPath.row];
  cell.textLabel.text = podcast.title;
  
  if (podcast.activeDownload) {
    cell.detailTextLabel.text = @"has active download";
  }
  
  return cell;
}

@end
