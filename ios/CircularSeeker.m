//
//  CircularSeeker.m
//  CircularSeekerLib
//
//  Created by mac 2018 on 8/20/20.
//

#import "React/RCTViewManager.h"
@interface RCT_EXTERN_MODULE(CircularSeeker, RCTViewManager)
RCT_EXPORT_VIEW_PROPERTY(thumbColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(seekBarColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(currentAngle, float)
RCT_EXPORT_VIEW_PROPERTY(startAngle, float)
RCT_EXPORT_VIEW_PROPERTY(endAngle, float)
RCT_EXPORT_VIEW_PROPERTY(maxVal, int)
RCT_EXPORT_VIEW_PROPERTY(minVal, int)

RCT_EXPORT_VIEW_PROPERTY(onUpdate, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onComplete, RCTDirectEventBlock)
@end
