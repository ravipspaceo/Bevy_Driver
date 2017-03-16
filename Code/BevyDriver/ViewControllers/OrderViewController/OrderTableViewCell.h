//
//  OrderTableViewCell.h
//  Bevy
//
//  Created by CompanyName on 1/2/15.
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 * This class is used to create a cell for order table.
 */
@interface OrderTableViewCell : UITableViewCell
@property(strong , nonatomic) IBOutlet UILabel *lblPickUpAddress, *lblPhoneNum, *lblAddressTitle;
@property(strong , nonatomic) IBOutlet  UIButton *btnPhoneNumber;

@property(strong , nonatomic) IBOutlet  UIButton *btnSecondPhoneNumber;

@end
