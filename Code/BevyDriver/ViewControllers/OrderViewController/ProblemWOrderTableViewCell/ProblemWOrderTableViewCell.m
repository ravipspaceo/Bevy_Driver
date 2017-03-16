//
//  ProblemWOrderTableViewCell.m
//  BevyDriver
//
//  Created by CompanyName on 9/16/15.
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import "ProblemWOrderTableViewCell.h"

@implementation ProblemWOrderTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.lblPickUpAddress.adjustsFontSizeToFitWidth = YES;
    // Configure the view for the selected state
}

@end
