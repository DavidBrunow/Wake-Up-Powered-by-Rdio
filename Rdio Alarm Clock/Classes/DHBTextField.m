//
//  DHBTextField.m
//  Rdio Alarm
//
//  Created by David Brunow on 3/16/13.
//
//

#import "DHBTextField.h"

@implementation DHBTextField

-(id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup:frame];
    }
    return self;
}

////////////////////////////////////////////////////
// Private Implementation
////////////////////////////////////////////////////

- (void)setup:(CGRect)frame {
    // init here
    // Set up cursor
    self.cursor = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 3.0f, frame.size.height)];
    [self addSubview:self.cursor];
    [self.cursor setBackgroundColor:[UIColor colorWithRed:81.0f/255.0f green:106.0f/255.0f blue:237.0f/255.0f alpha:1.0f]];
    self.cursor.hidden = NO;
}

////////////////////////////////////////////////////
// Base Class Overrides
////////////////////////////////////////////////////
- (BOOL)textFieldShouldBeginEditing:(UITextView *)textView{
    [textView becomeFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextView *)textView{
    //resign for exapmple
    return YES;
}



-(BOOL)becomeFirstResponder {
    bool success = [super becomeFirstResponder];
    
    self.cursor.alpha = 1.0f;
    
    [UIView animateWithDuration:0.5f
                          delay:0.6f
                        options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionCurveEaseInOut)
                     animations:^{
                         self.cursor.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){}];
    
    //[super becomeFirstResponder];
    
    
    return success;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    // Hides Cursor when not editing
    self.cursor.hidden = YES;
    [self bringSubviewToFront:self.cursor];
    return [super textRectForBounds:bounds];
}

// This overrides the default editing rect for UITextField.
- (CGRect)editingRectForBounds:(CGRect)bounds {
    
    UITextRange *range = [self selectedTextRange];

    if([self offsetFromPosition:self.beginningOfDocument toPosition:range.start] < self.text.length) {
        if([self offsetFromPosition:self.beginningOfDocument toPosition:range.start] > 0 && self.text.length > 0) {
            [self endEditing:YES];
        } else if([self offsetFromPosition:self.beginningOfDocument toPosition:range.start] == 0 && self.text.length > 1) {
            [self endEditing:YES];
        }
    }
    
    // Shows then cursor in editing mode but only if no text is selected.  If text is selected then the default handles are shown.
    self.cursor.hidden = !range.empty;
    
    CGRect rect = [self caretRectForPosition:range.start];
    rect.origin.x = ([self caretRectForPosition:range.start]).origin.x;
    rect.size.width = 3.0f;
    self.cursor.frame = rect;
    
    return [super editingRectForBounds:bounds];
}

- (CGRect)caretRectForPosition:(UITextPosition *)position
{
    CGRect rect = [super caretRectForPosition:position];
    rect.size.width = 0.0f;
    return rect;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    //[self endEditing:YES];
    //return NO;
    return [super canPerformAction:action withSender:sender];
}

 
@end
