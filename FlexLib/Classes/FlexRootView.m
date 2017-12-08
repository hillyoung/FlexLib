/**
 * Copyright (c) 2017-present, zhenglibao, Inc.
 * email: 798393829@qq.com
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */


#import "FlexRootView.h"
#import "YogaKit/UIView+Yoga.h"
#import "FlexNode.h"
#import "FlexModalView.h"
#import "ViewExt/UIView+Flex.h"

static void* gObserverHidden    = (void*)1;
static void* gObserverText      = (void*)2;
static void* gObserverAttrText  = (void*)3;

@interface FlexRootView()
{
    BOOL _bInLayouting;
    NSMutableSet<UIView*>* _observedViews;
}
@end
@implementation FlexRootView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _bInLayouting = NO ;
        _observedViews = [NSMutableSet set];
        self.yoga.isEnabled = YES;
    }
    return self;
}


+(FlexRootView*)loadWithNodeFile:(NSString*)resName
                           Owner:(NSObject*)owner
{
    if(resName==nil){
        resName = NSStringFromClass([owner class]);
    }
    
    NSString* path;
    
    if([resName hasPrefix:@"/"]){
        // it's absolute path
        path = resName ;
    }else{
        path = [[NSBundle mainBundle]pathForResource:resName ofType:@"xml"];
    }
    
    if(path==nil){
        NSLog(@"Flexbox: resource %@ not found.",resName);
        return nil;
    }
    
    FlexRootView* root = [[FlexRootView alloc]init];
    FlexNode* node = [FlexNode loadNodeFile:path];
    if(node != nil){
        UIView* sub = [node buildViewTree:owner
                                 RootView:root];
        
        if(sub != nil && ![sub isKindOfClass:[FlexModalView class]])
        {
            [root addSubview:sub];
        }
    }
    root.yoga.isEnabled = YES;
    return root;
}

- (void)dealloc
{
    for(UIView* subview in _observedViews)
    {
        [self removeWatchView:subview];
    }
}
-(void)registSubView:(UIView*)subView
{
    if([_observedViews containsObject:subView])
        return;
    
    [_observedViews addObject:subView];
    
    [subView addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:gObserverHidden];
    [subView addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:gObserverText];
    [subView addObserver:self forKeyPath:@"attributedText" options:NSKeyValueObservingOptionNew context:gObserverAttrText];
}
-(void)removeWatchView:(UIView*)view
{
    if(view==nil)
        return;
    
    [view removeObserver:self forKeyPath:@"hidden"];
    [view removeObserver:self forKeyPath:@"text"];
    [view removeObserver:self forKeyPath:@"attributedText"];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UIView*)object change:(NSDictionary *)change context:(void *)context
{
    if(_bInLayouting)
        return;
    
    if(object != nil){
        
        if( context == gObserverHidden ){
            BOOL n = [[change objectForKey:@"new"] boolValue];
            object.yoga.isIncludedInLayout = !n;
        }
        
        [object.yoga markDirty];
    }
    [self setNeedsLayout];
}
#pragma mark - layout methods

-(void)layoutSubviews
{
    if(_bInLayouting)
        return;

    [self configureLayoutWithBlock:^(YGLayout* layout){
        
        CGRect rc = self.superview.frame ;
        
        if(self.flexibleWidth)
            layout.width = YGPointValue(NAN);
        else
            layout.width = YGPointValue(rc.size.width) ;
        
        if(self.flexibleHeight)
            layout.height = YGPointValue(NAN);
        else
            layout.height = YGPointValue(rc.size.height) ;
    }];
    
    YGDimensionFlexibility option = 0 ;
    if(self.flexibleWidth)
        option |= YGDimensionFlexibilityFlexibleWidth ;
    if(self.flexibleHeight)
        option |= YGDimensionFlexibilityFlexibleHeigth ;
    
    CGRect rcOld = self.frame;
    _bInLayouting = YES;
    [self.yoga applyLayoutPreservingOrigin:NO dimensionFlexibility:option];
    _bInLayouting = NO ;
    
    if(!CGRectEqualToRect(rcOld, self.frame)){
        [self.superview subFrameChanged:self Rect:self.frame];
    }
}

-(CGSize)calculateSize:(CGSize)szLimit
{
    [self configureLayoutWithBlock:^(YGLayout* layout){
        
        if(self.flexibleWidth)
            layout.width = YGPointValue(NAN);
        else
            layout.width = YGPointValue(szLimit.width) ;

        if(self.flexibleHeight)
            layout.height = YGPointValue(NAN);
        else
            layout.height = YGPointValue(szLimit.height) ;
    }];
    
    if(self.flexibleWidth)
        szLimit.width = NAN ;
    if(self.flexibleHeight)
        szLimit.height = NAN ;
    
    CGSize sz=[self.yoga calculateLayoutWithSize:szLimit];
    return sz;
}
-(CGSize)calculateSize
{
    CGRect rc = self.superview.frame ;
    return [self calculateSize:rc.size];
}


@end