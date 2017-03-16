//
//  UIScrollView+TPKeyboardAvoidingAdditions.h
//  TPKeyboardAvoidingSample
//
//  Created by CompanyName on 30/09/2013.
//  Copyright 2013 CompanyName. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIScrollView (TPKeyboardAvoidingAdditions)<NSFileManagerDelegate>
- (BOOL)TPKeyboardAvoiding_focusNextTextField;
- (void)TPKeyboardAvoiding_scrollToActiveTextField;

- (void)TPKeyboardAvoiding_keyboardWillShow:(NSNotification*)notification;
- (void)TPKeyboardAvoiding_keyboardWillHide:(NSNotification*)notification;
- (void)TPKeyboardAvoiding_updateContentInset;
- (void)TPKeyboardAvoiding_updateFromContentSizeChange;
- (void)TPKeyboardAvoiding_assignTextDelegateForViewsBeneathView:(UIView*)view;
- (UIView*)TPKeyboardAvoiding_findFirstResponderBeneathView:(UIView*)view;
-(CGSize)TPKeyboardAvoiding_calculatedContentSizeFromSubviewFrames;
@end
