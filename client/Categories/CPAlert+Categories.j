@import <Foundation/CPObject.j>

var _WINDOW_SHEET_DID_END_CALLBACK = nil;

@implementation CPAlert (SJAlertAdditions)

- (void)beginSheetModalForWindow:(CPWindow)aWindow modalDelegate:(id)modalDelegate didEndCallback:(func)alertDidEndCallback contextInfo:(id)contextInfo
{
    if (!([_window styleMask] & CPDocModalWindowMask))
    {
        _needsLayout = YES;
        [self _createWindowWithStyle:CPDocModalWindowMask];
    }

    [self layout];

    _modalDelegate = modalDelegate;
    _didEndSelector = nil;
    _WINDOW_SHEET_DID_END_CALLBACK = alertDidEndCallback;
    
    [CPApp beginSheet:_window modalForWindow:aWindow modalDelegate:self didEndSelector:@selector(_alertDidEnd:returnCode:contextInfo:) contextInfo:contextInfo];
}

- (void)_alertDidEnd:(CPWindow)aWindow returnCode:(int)returnCode contextInfo:(id)contextInfo
{
    if ([_delegate respondsToSelector:@selector(alertDidEnd:returnCode:)])
            [_delegate alertDidEnd:self returnCode:returnCode];
    
    if (_WINDOW_SHEET_DID_END_CALLBACK)
      _WINDOW_SHEET_DID_END_CALLBACK(returnCode, contextInfo);
      
    if (_didEndSelector)
        objj_msgSend(_modalDelegate, _didEndSelector, self, returnCode, contextInfo);

    _modalDelegate = nil;
    _didEndSelector = nil;
    _WINDOW_SHEET_DID_END_CALLBACK = nil;
}

@end