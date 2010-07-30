/*
 * EKSpinner.j
 * 
 * The MIT License
 * 
 * Copyright (c) 2009 Elias Klughammer
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 */

@implementation EKSpinner : CPImageView
{
	int _frames;
	int _interval;
	BOOL _isSpinning;
	CPTimer _timer;
	int _imageNumber;
	CPArray _imageStack;
}

- (id)initWithFrame:(CGRect)aFrame andStyle:(CPString)aStyle
{
	self = [super initWithFrame:aFrame];
	if (self) {
		[self setImageScaling:CPScaleNone];
		
		if (aStyle.search(/small/) < 0) {
			[self setFrames:12];
		} else {
			[self setFrames:8];
		}
		
		_imageStack = [[CPArray alloc] init];
		
		for (i=1; i<=[self frames]; i++) {
			var img = [[CPImage alloc] initWithContentsOfFile:@"Frameworks/EKSpinner/Resources/" + aStyle + "_" + i + ".png" size:CGSizeMake(aFrame.size.width, aFrame.size.height)];
			_imageStack = [_imageStack arrayByAddingObject:img];
		}
	}
	
	return self;
}

- (void)setFrames:(int)theFrames
{
	[self setValue:theFrames forKey:@"_frames"];
}

- (int)frames
{
	return [self valueForKey:@"_frames"];
}

- (void)setInterval:(int)aInterval
{
	[self setValue:aInterval forKey:@"_interval"];
}

- (int)interval
{
	return [self valueForKey:@"_interval"];
}

- (BOOL)isSpinning
{
	return [self valueForKey:@"_isSpinning"];
}

- (void)setIsSpinning:(BOOL)anOption
{
	if (anOption) {
		if (![self isSpinning]) {
			if ([self interval]) {
				var animationInterval = [self interval] / 1000;
			} else {
				var animationInterval = 0.1;
			}
			[self setImageNumber:1];
			var theTimer = [CPTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(changeSpinnerImage) userInfo:nil repeats:YES];
			[self setValue:theTimer forKey:@"_timer"];
			[self setValue:YES forKey:@"_isSpinning"];
		}
	} else {
		if ([self isSpinning]) {
			[self setValue:NO forKey:@"_isSpinning"];
			[[self valueForKey:@"_timer"] invalidate];
			[self setImage:nil];
		}
	}
}

- (void)setImageNumber:(int)aNumber {
	[self setValue:aNumber forKey:@"_imageNumber"];
}

- (int)imageNumber {
	return [self valueForKey:@"_imageNumber"];
}

- (void)changeSpinnerImage {
	
	[self setImage:[_imageStack objectAtIndex:[self imageNumber]-1]];
	
	if ([self imageNumber] == [self frames]) {
		[self setImageNumber:1];
	} else {
		[self setImageNumber:[self imageNumber]+1];
	}
}

@end