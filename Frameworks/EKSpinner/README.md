EKSpinner
==========

This is an extension for the [Cappuccino](http://www.cappuccino.org) framework to display 'loading-indicator-spinners' dynamically to any background color without having to create gif-animations.

A live demonstration can be seen [here](http://www.thisagree.com/EKSpinner).


## Installation

Simply put the 'EKSpinner' folder in your 'Frameworks' directory and add the following line to the top of your application's AppController:

	@import "Frameworks/EKSpinner/EKSpinner.j"


## Usage

This is an example for adding a EKSpinner to your view:

	var spinner = [[EKSpinner alloc] initWithFrame:CGRectMake(40, 40, 18, 18) andStyle:@"medium_white"];
	[spinner setIsSpinning:YES];
	[contentView addSubview:spinner];

For stopping the spinner simply set the `isSpinning` method to `NO`.

The default animation interval is 100ms but you can also set your own by using the method

	[spinner setInterval:200];

This has to be done before the the spinner was activated by `setSpinning: YES`.
Notify that the faster the interval the more system performance the spinner will need.


## Styles:

The following styles are provided:

__14x14__
	small_white
	small_gray
	small_black

__18x18__
	medium_white
	medium_gray
	medium_black

__30x30__
	big_white
	big_gray
	big_black

