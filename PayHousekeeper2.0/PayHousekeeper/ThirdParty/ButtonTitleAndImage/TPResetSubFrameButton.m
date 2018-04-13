//
//  TPResetSubFrameButton.m
//  cft
//
//  Created by springxiao on 16/8/9.
//  Copyright © 2016年 holyli. All rights reserved.
//

#import "TPResetSubFrameButton.h"

@interface TPResetSubFrameButton ()
{
}

@end


@implementation TPResetSubFrameButton


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.imageX > 0)
    {
        [self setHLayoutFrame];
    }
    else if (self.imageY >0)
    {
        [self setVLayoutFrame];
    }
    
    if (self.imageFrame.size.width > 0)
    {
        self.imageView.frame = self.imageFrame;
    }
    
    if (self.labelFrame.size.width > 0)
    {
        self.titleLabel.frame = self.labelFrame;
    }
    
}

- (void)setHLayoutFrame
{
    if(self.imageX > 0)
    {
        self.imageView.frame  = CGRectMake(self.imageX, [self getImageY], self.imageView.image.size.width, self.imageView.image.size.height);
    }
    
    if (self.labelX > 0)
    {
        [self.titleLabel sizeToFit];
        self.titleLabel.frame = CGRectMake(self.labelX, [self getLabelY], self.titleLabel.width, self.titleLabel.height);
    }
    
    if (self.labelOffsetX > 0)
    {
        [self.titleLabel sizeToFit];
        self.titleLabel.frame = CGRectMake(self.imageView.right+self.labelOffsetX, [self getLabelY], self.titleLabel.width, self.titleLabel.height);
    }
}

- (void)setVLayoutFrame
{
    if(self.imageY > 0)
    {
        self.imageView.frame  = CGRectMake([self getImageX], self.imageY, self.imageView.image.size.width, self.imageView.image.size.height);
    }
    
    if (self.labelY > 0)
    {
        [self.titleLabel sizeToFit];
        self.titleLabel.frame = CGRectMake([self getLabelX], self.labelY, self.titleLabel.width, self.titleLabel.height);
    }
    
    if (self.labelOffsetY > 0)
    {
        [self.titleLabel sizeToFit];
        self.titleLabel.frame = CGRectMake([self getLabelX], self.imageView.bottom+self.labelOffsetY, self.titleLabel.width, self.titleLabel.height);
    }
}

- (CGFloat)getImageX
{
    if (self.imageX <= 0)
    {
        return  (self.width - self.imageView.image.size.width)/2;
    }
    else
    {
        return self.imageX;
    }
}

- (CGFloat)getImageY
{
    if (self.imageY <= 0)
    {
        return (self.height - self.imageView.image.size.height)/2;
    }
    return self.imageY;
}

- (CGFloat)getLabelX
{
    if (self.labelX <= 0)
    {
        return  (self.width - self.titleLabel.width)/2;
    }
    
    return  self.labelX;
}

- (CGFloat)getLabelY
{
    if (self.labelY <= 0)
    {
        return (self.height - self.titleLabel.height)/2;
    }
    return self.labelY;
}
@end
