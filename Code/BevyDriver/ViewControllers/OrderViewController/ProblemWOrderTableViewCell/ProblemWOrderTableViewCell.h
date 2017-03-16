//
//  ProblemWOrderTableViewCell.h
//  BevyDriver
//
//  Created by CompanyName on 9/16/15.
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 * This class is used to create a cell for problem order details table.
 */
@interface ProblemWOrderTableViewCell : UITableViewCell

@property(strong , nonatomic) IBOutlet UILabel *lblPickUpAddress, *lblPhoneNum, *lblAddressTitle;
@property(strong , nonatomic) IBOutlet  UIButton *btnPhoneNumber;
@property(strong , nonatomic) IBOutlet  UIButton *btnSecondPhoneNumber;
@end
