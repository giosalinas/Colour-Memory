//
//  GameViewController.m
//  Colour Memory
//
//  Created by gio on 27-11-15.
//  Copyright © 2015 giosalinas. All rights reserved.
//

#import "GameViewController.h"
#import "Card.h"
#import "HighScoresViewController.h"

@interface GameViewController ()
@property (nonatomic, strong) Card *selectedCard;
@property (nonatomic, strong) IBOutlet UILabel *currentPoints;
@property (nonatomic, assign) NSInteger pairedCards;
@property (nonatomic, strong) UIButton *playButton;
@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 60)];
    [self.playButton setTitle:@"Start Game" forState:UIControlStateNormal];
    [self.playButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(startGame) forControlEvents:UIControlEventTouchUpInside];
    
    self.playButton.center = self.view.center;
    
    self.playButton.backgroundColor = [UIColor whiteColor];
    self.playButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.playButton.layer.borderWidth = 2.0f;
    self.playButton.layer.cornerRadius = 5;
    self.playButton.layer.masksToBounds = YES;
    
    [self.view addSubview:self.playButton];
    
    [self resetGame];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)resetGame
{
    UIView *cardsView = [self.view viewWithTag:20];

    for (Card *card in [cardsView subviews])
    {
        [card reset];
    }
}

- (void)newGame
{
    __weak GameViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.view addSubview:weakSelf.playButton];
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.playButton.alpha = 1.0f;
            CGAffineTransform translate = CGAffineTransformTranslate(weakSelf.playButton.transform, 0, -500);
            weakSelf.playButton.transform = translate;
        } completion:^(BOOL finished){
        }];
    });
}

- (void)startGame
{
    self.pairedCards = 0;
    self.selectedCard = nil;
    self.currentPoints.text = @"0";
    
    __weak GameViewController *weakSelf = self;
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    NSOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:^{
        UIView *cardsView = [weakSelf.view viewWithTag:20];
        for (Card *card in [cardsView subviews])
        {
            [card addToDeck];
        }
    }];
    
    NSOperation *removeButton = [NSBlockOperation blockOperationWithBlock:^{
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.playButton.alpha = 0.0f;
            CGAffineTransform translate = CGAffineTransformTranslate(weakSelf.playButton.transform, 0, 500);
            weakSelf.playButton.transform = translate;
            
        } completion:^(BOOL finished){
            [weakSelf.playButton removeFromSuperview];
        }];
    }];
    
    [completionOperation addDependency:removeButton];
    [queue addOperation:removeButton];
    
    NSOperation *resetCards = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf resetGame];
    }];
    
    [completionOperation addDependency:resetCards];
    [queue addOperation:resetCards];

    
    NSOperation *generateColorsOP = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf generateColors];
    }];
    
    [completionOperation addDependency:generateColorsOP];
    [queue addOperation:generateColorsOP];
    
    [queue addOperation:completionOperation];
}

- (void)generateColors
{
    // generate colors and config card
    UIView *cardsView = [self.view viewWithTag:20];
    NSArray *cards = [cardsView subviews];
    
    for (int i = 0; i < 8; i++)
    {
        int r = arc4random() % 255;
        int g = arc4random() % 255;
        int b = arc4random() % 255;

        UIColor *randomColor = [[UIColor alloc] initWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0];
        BOOL firstCardHasColor = NO;
        BOOL pairCardHasColor = NO;
        
        while (!firstCardHasColor || !pairCardHasColor)
        {
            NSInteger index = arc4random()%(cards.count);
            Card *card = [cards objectAtIndex:index];
            
            if (!firstCardHasColor && !card.color)
            {
                [card configureCardWithColor:randomColor];
                firstCardHasColor = YES;
            }
            else if (!pairCardHasColor && !card.color)
            {
                [card configureCardWithColor:randomColor];
                pairCardHasColor = YES;
            }
            
        }
        
    }    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [touches enumerateObjectsUsingBlock:^(UITouch * _Nonnull obj, BOOL * _Nonnull stop) {
        id touchedView = [obj view];
        if ([touchedView isKindOfClass:[Card class]])
        {
            if (![(Card *)touchedView flipped])
                [(Card *)touchedView flipCard];
            else
                return;
            
            if (self.selectedCard)
                [self cardSelected:touchedView];
            else
                self.selectedCard = touchedView;

            *stop = YES;
        }
    }];
}

- (void)cardSelected:(Card *)card
{
    if ([card isPairWithCard:self.selectedCard])
    {
        // make 2 points
        NSInteger points = [self.currentPoints.text integerValue];
        points += 2;
        [self.currentPoints setText:[NSString stringWithFormat:@"%ld", (long)points]];

        [self.selectedCard performSelector:@selector(removeFromDeck) withObject:nil afterDelay:1.0];
        [card performSelector:@selector(removeFromDeck) withObject:nil afterDelay:1.0];
        
        self.pairedCards += 1;
        
        if (self.pairedCards > 7)
            [self performSelector:@selector(gameOver) withObject:nil afterDelay:1.0];
        
    }
    else
    {
        // rest 1 point
        NSInteger points = [self.currentPoints.text integerValue];
        points -= 1;
        [self.currentPoints setText:[NSString stringWithFormat:@"%ld", (long)points]];
        
        [self.selectedCard performSelector:@selector(flipCard) withObject:nil afterDelay:.5];
        [card performSelector:@selector(flipCard) withObject:nil afterDelay:.5];
    }
    
    self.selectedCard = nil;
}

- (void)gameOver
{
    [self addNameToRanking];
}

- (void)addNameToRanking
{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Ranking" message:@"Enter your name:" preferredStyle:UIAlertControllerStyleAlert];
    
    __weak GameViewController *weakSelf = self;
    __weak UIAlertController *alertRef = alertView;
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   NSString *name = ((UITextField *)[alertRef.textFields objectAtIndex:0]).text;
                                                   
                                                   if (name.length > 0)
                                                   {
                                                       UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                       HighScoresViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"vcHighScores"];
                                                       [vc savePlayerWithName:name andPoints:self.currentPoints.text];
                                                       [self.navigationController pushViewController:vc animated:YES];
                                                       [weakSelf newGame];
                                                   }
                                                   else
                                                   {
                                                       [weakSelf invalidInput];
                                                   }
                                               }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                       [weakSelf newGame];
                                                   }];
    
    [alertView addAction:ok];
    [alertView addAction:cancel];
    
    [alertView addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {}];
    
    [self presentViewController:alertView animated:YES completion:nil];
}

- (void)invalidInput
{
    __weak GameViewController *weakSelf = self;

    UIAlertController *wrongName = [UIAlertController alertControllerWithTitle:@"Error" message:@"Not a valid name" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *OK = [UIAlertAction actionWithTitle:@"Try again" style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                       [weakSelf addNameToRanking];
                                                   }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                       [weakSelf newGame];
                                                   }];
    
    [wrongName addAction:OK];
    [wrongName addAction:cancel];
    
    [self presentViewController:wrongName animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
