//
//  Card.h
//  Colour Memory
//
//  Created by gio on 27-11-15.
//  Copyright © 2015 giosalinas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Card : UIView
@property (nonatomic, assign) BOOL flipped;
@property (nonatomic, strong) UIColor *color;

-(void)flipCard;

- (void)configureCardWithColor:(UIColor *)color;
- (BOOL)isPairWithCard:(Card *)card;

- (void)addToDeck;
- (void)removeFromDeck;


- (void)reset;
@end
