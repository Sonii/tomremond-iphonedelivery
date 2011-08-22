@interface CKMessageCell : UIView
-(UIView *)balloonView;
@end

@interface MarkView : UIImageView
-(id)init:(int)state cell:(CKMessageCell*)cell status:(uint16_t)status;
@end
// vim: ft=objc ts=4 expandtab
