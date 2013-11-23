//
//  HBViewController.m
//  ColorPicker
//
//  Created by Angie Lal on 11/23/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import "HBViewController.h"

@interface HBViewController ()
{
    CGFloat _hue;
    CGFloat _saturation;
    CGFloat _brightness;
}
@property (weak, nonatomic) IBOutlet UIView *colorWell;

@end

@implementation HBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateColor
{
    UIColor *newColor = [UIColor colorWithHue:_hue saturation:_saturation brightness:_brightness alpha:1.0];
    self.colorWell.backgroundColor = newColor;
}
- (IBAction)handleHueSlider:(UISlider *)sender {
    _hue = sender.value;
    [self updateColor];
}

- (IBAction)handleSaturationSlider:(UISlider *)sender {
    _saturation = sender.value;
    [self updateColor];

}

- (IBAction)handleBrightnessSlider:(UISlider *)sender {
    _brightness = sender.value;
    [self updateColor];

}

@end
