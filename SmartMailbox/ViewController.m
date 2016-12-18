//
//  ViewController.m
//  SmartMailbox
//
//  Created by Daniel Wang on 12/15/16.
//  Copyright © 2016 Factory Method. All rights reserved.
//

#import "ViewController.h"
#import <ChameleonFramework/Chameleon.h>
#import <FCAlertView/FCAlertView.h>
#import <Fumble/Fumble-umbrella.h>
#import <Masonry/Masonry.h>
#import <UIImageView_PlayGIF/UIImageView+PlayGIF.h>

#import "UIView+NAUtils.h"



@interface ViewController ()

@property (strong, nonatomic) dispatch_queue_t centralQueue;
@property (strong, nonatomic) CBCentralManager* centralManager;
@property (assign, atomic) BOOL isShowingAlert;

@end



@implementation ViewController

+(CBUUID *) advertServiceUUID {
	static CBUUID* uuid = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		uuid = [CBUUID UUIDWithString:@"5048"];
	});
	return uuid;
}

-(void) viewDidLoad
{
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor flatWhiteColor];

	self.imageView = [self.view na_addSubview:[[UIImageView alloc] init]
							withConfiguration:
					  ^(UIImageView* v) {
						  v.backgroundColor = [UIColor randomFlatColor];
						  v.contentMode = UIViewContentModeScaleAspectFill;
						  v.gifPath = [[NSBundle mainBundle] pathForResource:@"36i4nzd2ookx"
																	  ofType:@"gif"];

						  [v mas_makeConstraints:^(MASConstraintMaker* make) {
							  make.edges.equalTo(self.view);
						  }];
					  }];

	self.centralQueue = dispatch_queue_create("fm.demo", NULL);
	self.centralManager =
	[CBCentralManager fm_centralManagerWithDelegate:nil
											  queue:self.centralQueue
											options:nil];

	[self.centralManager.rac_didUpdateStateSignal subscribeNext:^(NSNumber* state) {
		switch (self.centralManager.state)
		{
			case CBManagerStatePoweredOn:
			{
				@weakify(self);

				dispatch_async(dispatch_get_main_queue(), ^{
					@strongify(self);


					[self.centralManager scanForPeripheralsWithServices:
					 @[[ViewController advertServiceUUID]]
																options:
					 @{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];

					[self.imageView startGIF];
					self.title = @"Smart Mailbox";
				});
			}
				break;

			default:
				break;
		}
	}];

	self.isShowingAlert = NO;
	[[self.centralManager rac_didDiscoverPeripheralSignal] subscribeNext:
	 ^(RACTuple* tuple) {
		 RACTupleUnpack(CBPeripheral* peripheral,
						NSDictionary* __unused advertisementData,
						NSNumber* __unused RSSI) = tuple;

		 NSData* data = [[advertisementData objectForKey:@"kCBAdvDataServiceData"] objectForKey:[ViewController advertServiceUUID]];

		 if (!data)
			 return;

		 uint16_t __block value = *((uint16_t *)[data bytes]);

		 dispatch_async(dispatch_get_main_queue(), ^{
			 if (self.isShowingAlert)
				 return;

			 self.isShowingAlert = YES;

			 self.title = value == 0x20DE ? @"HPE-2" : @"HPE-1";
			 self.view.backgroundColor = value == 0x20DE ? [UIColor flatGreenColor] : [UIColor flatWhiteColor];
			 [self.imageView stopGIF];
			 [self.imageView setHidden:YES];

			 FCAlertView* alert = [[FCAlertView alloc] init];

			 [alert doneActionBlock:^{
				 self.isShowingAlert = NO;

				 self.title = @"Smart Mailbox";
				 [self.imageView startGIF];
				 [self.imageView setHidden:NO];
			 }];

			 NSString* subtitle = value == 0x20DE
			 ? @"From:\n\nHP Enterprise\n369 Addison Ave\nPalo Alto, CA 94301\n\nhttps://hpe.com"
			 : @"From:\n\nFactory Method\n1441 9th Ave #710\nSan Diego, CA 92101\n\nhttps://corp.fm";

			 [alert showAlertInView:self
						  withTitle:@"You've Got Mail"
					   withSubtitle:subtitle
					withCustomImage:[UIImage imageNamed:@"Mailbox"]
				withDoneButtonTitle:@"OK"
						 andButtons:nil];

			 NSLog(@"discovered: %@, %@", peripheral, advertisementData);
		 });
	 }];
}

@end
