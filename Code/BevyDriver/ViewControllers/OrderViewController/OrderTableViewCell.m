//
//  OrderTableViewCell.m
//  Bevy
//
//  Created by CompanyName on 1/2/15.
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import "OrderTableViewCell.h"

@implementation OrderTableViewCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.lblPickUpAddress.frame = CGRectMake(self.lblPickUpAddress.frame.origin.x, self.lblPickUpAddress.frame.origin.y, self.frame.size.width-37, self.lblPickUpAddress.frame.size.height);

    // Configure the view for the selected state
}

@end
