//
//  MNDDownloadListViewController.m
//  Downloader
//
//  Created by Haldun Bayhantopcu on 20/10/13.
//  Copyright (c) 2013 Monoid. All rights reserved.
//

#import "MNDDownloadListViewController.h"
#import "MNDDownload.h"
#import "MNDDataModel.h"

@interface MNDDownloadListViewController () <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>
@property (strong, nonatomic) NSArray *downloads;
@end

@implementation MNDDownloadListViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self fetchDownloads];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(managedObjectContextDidSave:)
                                               name:NSManagedObjectContextDidSaveNotification
                                             object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)managedObjectContextDidSave:(NSNotification *)notification
{
  NSManagedObjectContext *mainContext = [[MNDDataModel sharedDataModel] mainContext];
  NSManagedObjectContext *context = (NSManagedObjectContext *)notification.object;
  
  if (context.persistentStoreCoordinator == mainContext.persistentStoreCoordinator) {
    [mainContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                  withObject:notification
                               waitUntilDone:NO];
  }
  
  [self fetchDownloads];
}

- (void)fetchDownloads
{
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Download"];
  fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startedAt" ascending:YES]];
  NSError *error;
  self.downloads = [[[MNDDataModel sharedDataModel] mainContext] executeFetchRequest:fetchRequest error:&error];
  
  if (error) {
    NSLog(@"fetch downloads error: %@", error);
  }
  
  [self.tableView reloadData];
}

- (IBAction)createDownload:(id)sender
{
  NSString *urlString = @"http://asset.powerfm.com.tr/CenkErdem/podcast/CENKERDEM01022013.mp3";
  
  NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
  context.persistentStoreCoordinator = [[MNDDataModel sharedDataModel] persistentStoreCoordinator];
  
  MNDDownload *download = [NSEntityDescription insertNewObjectForEntityForName:@"Download" inManagedObjectContext:context];
  download.downloadableIdentifier = @1;
  download.downloadableType = @"Podcast";
  download.url = urlString;
  download.startedAt = [NSDate date];
  
  [context save:nil];
  
  NSString *sessionIdentifier = [[[download objectID] URIRepresentation] description];
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:sessionIdentifier];
  NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                        delegate:self
                                                   delegateQueue:[NSOperationQueue mainQueue]];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];
  [downloadTask resume];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
  NSLog(@"finished download for %@", session);
}

/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
  NSString *sessionIdentifier = session.configuration.identifier;
  NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
  context.persistentStoreCoordinator = [[MNDDataModel sharedDataModel] persistentStoreCoordinator];
  NSURL *url = [NSURL URLWithString:sessionIdentifier];
  NSManagedObjectID *objectID =[context.persistentStoreCoordinator managedObjectIDForURIRepresentation:url];
  NSError *error;
  NSManagedObject *download = [context existingObjectWithID:objectID error:&error];
  
  if (error) {
    NSLog(@"cannot get download object: %@", error);
  } else {
    [download setValue:@(totalBytesWritten) forKey:@"bytesWritten"];
    [download setValue:@(totalBytesExpectedToWrite) forKey:@"expectedBytesWritten"];
    [context save:&error];
  }
}

/* Sent when a download has been resumed. If a download failed with an
 * error, the -userInfo dictionary of the error will contain an
 * NSURLSessionDownloadTaskResumeData key, whose value is the resume
 * data.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
  
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.downloads.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"DownloadCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  
  MNDDownload *download = self.downloads[indexPath.row];
  cell.textLabel.text = [NSString stringWithFormat:@"Download for %@ %@", download.downloadableIdentifier,
                         download.downloadableType];
  
  double progress = [download.bytesWritten doubleValue] / [download.expectedBytesWritten doubleValue];
  
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%4.2f", progress * 100.0];
  return cell;
}

@end
