//
//  Tile.m
//  flash
//
//  Created by Long Tran on 6/6/15.
//  Copyright (c) 2015 Long Tran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tile.h"

@end

@implementation Tile {
    int x;
    int y;
}
-(id) initWithxCoor:(int) xCor yCoor:(int) yCor {
    self = [super init];
    x = xCor;
    y = yCor;
    return self;
}

-(int) getX {
    return x;
}

-(int) getY {
    return y;
}
@end
