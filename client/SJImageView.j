@import <Foundation/Foundation.j>

@implementation SJImageView : CPImageView
{
  id delegate @accessors;
}

- (void)mouseDown:(CPEvent)anEvent
{
  if([self delegate] && [[self delegate] respondsToSelector:@selector(imageViewMouseDown:)]) {
    [[self delegate] imageViewMouseDown:anEvent];
  }
  [super mouseDown:anEvent];
}


@end