//
//  Card.m
//  Colour Memory
//
//  Created by gio on 27-11-15.
//  Copyright © 2015 giosalinas. All rights reserved.
//

#import "Card.h"
@interface Card ()
@end
@implementation Card

- (void)configureCardWithColor:(UIColor *)color
{
    self.color = color;
 
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 2.0f;
    
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    

}

-(void)flipCard
{
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut | self.flipped ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight;
    
    [UIView transitionWithView:self duration:0.2 options:options animations:^{
        if (self.flipped)
        {
            [self setBackgroundColor:[UIColor whiteColor]];
        }else
        {
            [self setBackgroundColor:self.color];
        }
    } completion:^(BOOL finished) {
        
    }];
 
    self.flipped = !self.flipped;
}

- (BOOL)isPairWithCard:(Card *)card
{
    return (card.color == self.color) && card != self;
}

- (void)addToDeck
{
    self.transform = CGAffineTransformTranslate(self.transform, 600, 0);
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.alpha = 1.0f;
        CGAffineTransform translate = CGAffineTransformTranslate(self.transform, -600, 0);
        self.transform = translate;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)removeFromDeck
{
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.alpha = 0.0f;
        CGAffineTransform rotate = CGAffineTransformRotate(self.transform, 1);
        CGAffineTransform translate = CGAffineTransformTranslate(self.transform, -100, 500);
        self.transform = CGAffineTransformConcat(rotate, translate);
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)reset
{
    self.alpha = 0.0f;
    self.color = nil;
    self.flipped = NO;
    self.transform = CGAffineTransformIdentity;
}

@end
