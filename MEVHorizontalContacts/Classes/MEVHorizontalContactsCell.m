//
//  MEVHorizontalContactsCell.m
//  People Tracker
//
//  Created by Manuel Escrig Ventura on 24/02/15.
//  Copyright (c) 2015 Manuel Escrig Ventura. All rights reserved.
//


#import "MEVHorizontalContactsCell.h"
#import "MEVHorizontalContactsModel.h"

int const kBottomBarViewLabelHeight = 30;
int const kBottomBarViewMenuOptionsPadding = 10;


@interface MEVHorizontalContactsCell()

@property (nonatomic, strong) NSMutableArray *menuOptions;
@property (nonatomic, assign) BOOL isMenuShown;

@end


@implementation MEVHorizontalContactsCell

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    
    self.opaque = YES;
    
    _menuOptions = [NSMutableArray new];
    _isMenuShown = NO;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellSingleTap:)];
    [self addGestureRecognizer:singleTap];

    float maxWidth = CGRectGetHeight(self.bounds) - kBottomBarViewLabelHeight;
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, maxWidth, maxWidth)];
    _imageView.opaque = YES;
    _imageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) - kBottomBarViewLabelHeight/2);
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.backgroundColor = [UIColor lightGrayColor];
    _imageView.layer.cornerRadius = (maxWidth)/2;
    _imageView.layer.masksToBounds = YES;
    [self addSubview:_imageView];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - kBottomBarViewLabelHeight, CGRectGetWidth(self.bounds), kBottomBarViewLabelHeight)];
    _label.opaque = YES;
    _label.textColor = [UIColor whiteColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.font = [UIFont systemFontOfSize:12];
    [self addSubview:_label];
    
    return self;
}


#pragma mark - UI Actions

- (void)cellSingleTap:(UITapGestureRecognizer *)recognizer
{
    if([_cellDelegate respondsToSelector:@selector(cellSelectedAtIndexPath:)])
        [_cellDelegate cellSelectedAtIndexPath:self.cellIndexPath];
}

- (void)menuOptionSingleTap:(UIButton *)sender
{
    if([_cellDelegate respondsToSelector:@selector(menuOptionSelected:atIndexPath:)])
        [_cellDelegate menuOptionSelected:sender.tag atIndexPath:self.cellIndexPath];
}


#pragma mark - Setup Methods (Private)

- (void)setUpCellOptions
{
    [_menuOptions removeAllObjects];
    
    int numberOfItems;
    if([_cellDataSource respondsToSelector:@selector(numberOfItemsInCellIndexPath:)]) {
        numberOfItems = [_cellDataSource numberOfItemsInCellIndexPath:self.cellIndexPath];
    }
    
    float maxWidth = CGRectGetHeight(self.bounds) - kBottomBarViewLabelHeight;
    NSLog(@"maxWidth = %f", maxWidth);
    int y = maxWidth;
    y += kBottomBarViewMenuOptionsPadding;
    
    for (int index = 0; index < numberOfItems ; index++) {
        
        UIButton *button = [UIButton new];
        button.frame = CGRectMake(y,0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
        button.tag = index;
        button.alpha = 0;
        button.tintColor = [UIColor redColor];
        [button addTarget:self action:@selector(menuOptionSingleTap:) forControlEvents:UIControlEventTouchUpInside];

        if ([_cellDataSource respondsToSelector:@selector(textForItemAtIndex:inCellIndexPath:)]) {
            
            NSString *textLabel = [_cellDataSource textForItemAtIndex:index inCellIndexPath:self.cellIndexPath];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - kBottomBarViewLabelHeight, CGRectGetWidth(self.bounds), kBottomBarViewLabelHeight)];
            label.opaque = YES;
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:12];
            label.text = textLabel;
            [button addSubview:label];
        }
     
        if ([_cellDataSource respondsToSelector:@selector(imageForItemAtIndex:inCellIndexPath:)]) {
            
            UIImage *image = [_cellDataSource imageForItemAtIndex:index inCellIndexPath:self.cellIndexPath];
            image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, maxWidth, maxWidth)];
            imageView.image = image;
            imageView.opaque = YES;
            imageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) - kBottomBarViewLabelHeight/2);
            imageView.contentMode = UIViewContentModeCenter;
            imageView.layer.cornerRadius = (maxWidth)/2;
            imageView.layer.masksToBounds = YES;
            [button addSubview:imageView];
        }
        
        [_menuOptions addObject:button];
        [self addSubview:button];

        y += (maxWidth + kBottomBarViewMenuOptionsPadding);
    }
}


#pragma mark - Animation Methods (Public)

- (void)showMenuOptions
{
    NSLog(@"showMenuOptions");
    
    _isMenuShown = YES;
    
    [self setUpCellOptions];
    
    float delay = 0.1f;
    for (UIView *view in _menuOptions) {

        [view setUserInteractionEnabled:NO];
        [UIView animateWithDuration:0.01f
                              delay:0.1f + (delay * [_menuOptions indexOfObject:view])
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
            view.alpha = 1;
        } completion:^(BOOL finished) {
            [view setUserInteractionEnabled:YES];
        }];
    }
}


- (void)hideMenuOptions
{
    float delay = 0.05f;
    int pos = 0;
    for (int i = (int)[_menuOptions count]; i > 0 ; i--) {
        UIView *view = [_menuOptions objectAtIndex:i-1];
        [UIView animateWithDuration:0.1f
                              delay:delay * pos
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             view.alpha = 0;
                         } completion:^(BOOL finished) {
                             [view removeFromSuperview];
                             _isMenuShown = NO;
                         }];
        pos++;
    }
}


- (BOOL)isMenuShown
{
    return _isMenuShown;
}

#pragma mark - Overridden Properties (Public)

- (void)setContactModel:(MEVHorizontalContactsModel *)model
{
    self.contact = model;
    
    [_imageView setImage:[model image]];
    [_label setText:[model getName]];
}

@end
