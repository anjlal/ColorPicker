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
@property (weak, nonatomic) IBOutlet UISlider *hueSlider;
@property (weak, nonatomic) IBOutlet UISlider *saturationSlider;
@property (weak, nonatomic) IBOutlet UISlider *brightnessSlider;
@property (weak, nonatomic) IBOutlet UILabel *hueLabel;
@property (weak, nonatomic) IBOutlet UILabel *saturationLabel;
@property (weak, nonatomic) IBOutlet UILabel *brightnessLabel;
@property (weak, nonatomic) IBOutlet UIImageView *hueGradientImageView;
@property (weak, nonatomic) IBOutlet UIImageView *saturationGradientImageView;
@property (weak, nonatomic) IBOutlet UIImageView *brightnessGradientImageView;

@property (strong, nonatomic) NSNumberFormatter *percentageFormatter;

@property (strong, nonatomic) UILongPressGestureRecognizer *gestureRecognizer;

@property (strong, nonatomic) UIView *colorSwatch;
@property (weak, nonatomic) IBOutlet UIView *dropZone;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *colors;

@end

@implementation HBViewController

#define HBCellReuseIdentifier @"Cell"

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.colors = [NSMutableArray array];

    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:HBCellReuseIdentifier];
    self.percentageFormatter = [[NSNumberFormatter alloc]init];

    self.percentageFormatter.numberStyle = NSNumberFormatterPercentStyle;

    self.percentageFormatter.maximumFractionDigits = 0;

    self.hueGradientImageView.image = [self renderSpectrumImage];

    _hue = 0.25;
    _saturation = 0.5;
    _brightness = 1.0;

    [self updateSliders];
    [self updateColor];

    self.gestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    self.gestureRecognizer.minimumPressDuration = 0.25;
    [self.colorWell addGestureRecognizer:self.gestureRecognizer];

}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{

    CGPoint location = [recognizer locationInView:self.view];
    CGPoint convertedLocation = [recognizer locationInView:self.dropZone];

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (!self.colorSwatch) {
            CGRect swatchFrame = CGRectMake(0, 0, 60, 60);
            self.colorSwatch = [[UIView alloc] initWithFrame:swatchFrame];

            self.colorSwatch.layer.shadowColor = [UIColor blackColor].CGColor;
            self.colorSwatch.layer.shadowOffset = CGSizeMake(0, 3);
            self.colorSwatch.layer.shadowRadius = 4.0;
            self.colorSwatch.layer.shadowOpacity = 0.5;
            self.colorSwatch.layer.borderWidth = 5.0;
            self.colorSwatch.layer.borderColor = [UIColor whiteColor].CGColor;
        }
        [self.view addSubview:self.colorSwatch];
        self.colorSwatch.backgroundColor = self.colorWell.backgroundColor;
        self.colorSwatch.transform = CGAffineTransformMakeScale(0, 0);
        [UIView animateWithDuration:0.25 animations:^{
            self.colorSwatch.transform = CGAffineTransformIdentity;
            self.colorSwatch.alpha = 1.0;
        }];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (CGPointEqualToPoint(self.dropZone.center, self.colorSwatch.center)) {
            [self.colors insertObject:self.colorWell.backgroundColor atIndex:0];

            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
        }
        [UIView animateWithDuration:0.25 animations:^{
            self.colorSwatch.transform = CGAffineTransformMakeScale(0, 1);
        } completion:^(BOOL finished) {
            [self.colorSwatch removeFromSuperview];
        }];
    }


    // Does snapping
    if ([self.dropZone pointInside:convertedLocation withEvent:nil])
    {
        self.colorSwatch.center = self.dropZone.center;
    }
    else {
        self.colorSwatch.center = location;
    }

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

    self.hueLabel.text = [NSString stringWithFormat:@"%.0f°", _hue * 360];
    self.saturationLabel.text = [self.percentageFormatter stringFromNumber:@(_saturation)];
    self.brightnessLabel.text = [self.percentageFormatter stringFromNumber:@(_brightness)];

    self.saturationGradientImageView.image = [self renderSaturationImage];
    self.brightnessGradientImageView.image = [self renderBrightnessImage];



}

- (UIImage *)renderSaturationImage
{
    CGSize imageSize = CGSizeMake(CGRectGetWidth(self.saturationGradientImageView.bounds), 2);

    NSArray* gradientColors = @[
                                (id)[UIColor colorWithHue:_hue saturation:0.0 brightness:1.0 alpha:1.0].CGColor,
                                (id)[UIColor colorWithHue:_hue saturation:1.0 brightness:1.0 alpha:1.0].CGColor];
    CGFloat gradientLocations[] = {0, 1};

    return [self renderGradientLocations:gradientLocations colors:gradientColors imageSize:imageSize];
}

- (UIImage *)renderBrightnessImage
{
    CGSize imageSize = CGSizeMake(CGRectGetWidth(self.brightnessGradientImageView.bounds), 2);

    NSArray* gradientColors = @[
                                (id)[UIColor colorWithHue:_hue saturation:_saturation brightness:0.0 alpha:1.0].CGColor,
                                (id)[UIColor colorWithHue:_hue saturation:_saturation brightness:1.0 alpha:1.0].CGColor];
    CGFloat gradientLocations[] = {0, 1};



    return [self renderGradientLocations:gradientLocations colors:gradientColors imageSize:imageSize];
}


- (UIImage *)renderSpectrumImage
{
    CGSize imageSize = self.hueGradientImageView.bounds.size;

    //// Gradient Declarations
    NSArray* gradientColors = @[
                                (id)[UIColor redColor].CGColor,
                                (id)[UIColor orangeColor].CGColor,
                                (id)[UIColor yellowColor].CGColor,
                                (id)[UIColor greenColor].CGColor,
                                (id)[UIColor cyanColor].CGColor,
                                (id)[UIColor blueColor].CGColor,
                                (id)[UIColor magentaColor].CGColor,
                                (id)[UIColor redColor].CGColor
                                ];

    CGFloat gradientLocations[] = {0, 0.11, 0.25, 0.38, 0.51, 0.68, 0.84, 1};

    return [self renderGradientLocations:gradientLocations colors:gradientColors imageSize:imageSize];
}


- (UIImage *)renderGradientLocations:(CGFloat*)gradientLocations colors:(NSArray *)gradientColors imageSize:(CGSize)imageSize
{

    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);

    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradientColors, gradientLocations);

    //// Rectangle Drawing

    CGRect rect = CGRectMake(0, 0, imageSize.width, imageSize.height);

    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect:rect];

    CGContextSaveGState(context);
    [rectanglePath addClip];

    CGPoint gradientOrigin = CGPointMake(0, 1);
    CGPoint gradientEnd = CGPointMake(imageSize.width, 1);

    CGContextDrawLinearGradient(context, gradient, gradientOrigin, gradientEnd, 0);
    CGContextRestoreGState(context);


    //// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);

    return UIGraphicsGetImageFromCurrentImageContext();
}

- (void)updateSliders {
    self.hueSlider.value = _hue;
    self.saturationSlider.value = _saturation;
    self.brightnessSlider.value = _brightness;
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.colors.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:HBCellReuseIdentifier forIndexPath:indexPath];
    cell.backgroundColor = self.colors[indexPath.row];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *color = self.colors[indexPath.row];
    [color getHue:&_hue saturation:&_saturation brightness:&_brightness alpha:NULL];

    [self updateColor];
    [self updateSliders];

}

@end
