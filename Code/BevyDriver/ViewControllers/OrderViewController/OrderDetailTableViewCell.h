//
//  OrderDetailTableViewCell.h
//  Bevy
//
//  Created by CompanyName on 1/2/15.
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NPRImageView.h"

/**
 * This class is used to create a cell for order details table.
 */
@interface OrderDetailTableViewCell : UITableViewCell
@property (strong , nonatomic) IBOutlet NPRImageView *imgProduct;
@property (strong , nonatomic) IBOutlet UILabel *lblPrductTitle;
@property (strong , nonatomic) IBOutlet UILabel *lblSubTitle;
@property (strong , nonatomic) IBOutlet UILabel *lblQty,*lblPrice,*lblTag;
@property (strong , nonatomic) IBOutlet UIButton *btnCheck;

@end
