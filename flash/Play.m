//
//  Play.m
//  flash
//
//  Created by Long Tran on 6/5/15.
//  Copyright (c) 2015 Long Tran. All rights reserved.
//

#import "Play.h"
#import "Game.h"

@implementation Play {
    //Playing scene
    SPSprite *playScene;
    
    //Pieces
    SPImage *piece1;
    SPImage *piece2;
    SPImage *piece3;
    
    //Coordinates and board
    NSInteger xCoordinates[10];
    NSInteger yCoordinates[10];
    NSMutableArray *board;
}

int tileSize = 30;
int padding = 5;
int piecesPlaced = 0;
float p1X = 15, p2X = 130, p3X = 225;
float p1Y = 450, p2Y = 450, p3Y = 450;
uint tileColor = 0xff5050;

- (id)init {
    if ((self = [super init])) {
        //Initialize 2D array of board
        board = [[NSMutableArray alloc] initWithCapacity:10];
        for(int i = 0; i < 10; i++) {
            [board insertObject:[[NSMutableArray alloc] initWithCapacity:10] atIndex:i];
        }
        
        //Initialize playing scene
        playScene = [[SPSprite alloc] init];
        
        //Menu button
        SPTexture *butonTexture = [SPTexture textureWithContentsOfFile:@"button_medium.png"];
        SPButton *menuButton = [SPButton buttonWithUpState:butonTexture text:@"Menu"];
        menuButton.fontColor = 0xFFFFFF;
        menuButton.fontSize = 30;
        menuButton.x = (Sparrow.stage.width - menuButton.width)/2;
        menuButton.y = 20;
        [menuButton addEventListener:@selector(menuButtonTriggered:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
        
        //10x10 tiles
        int startY = 80, startX = (Sparrow.stage.width - (9 * padding + 10 * tileSize))/2;
        for(int i = 0; i < 10; i++) {
            for(int j = 0; j < 10; j++) {
                SPQuad *quad = [SPQuad quadWithWidth:tileSize height:tileSize];
                quad.x = startX;
                quad.y = startY;
                board[i][j] = quad;
                quad.color = tileColor;
                [playScene addChild:quad];
                xCoordinates[j] = startX;
                startX += tileSize + padding;
            }
            startX = (Sparrow.stage.width - (9 * padding + 10 * tileSize))/2;
            yCoordinates[i] = startY;
            startY += tileSize + padding;
        }
        
        [playScene addChild:menuButton];
    }
    return self;
}
-(NSString*) getRandomPiece {
    NSArray *pieces = @[@"1x2", @"1x3", @"2x1", @"2x2", @"3x3"];
    return [pieces objectAtIndex: arc4random_uniform((int)pieces.count)];
}

-(void) add3Pieces {
    piece1 = [self createPiece:[self getRandomPiece] atX:p1X atY:p1Y];
    piece2 = [self createPiece:[self getRandomPiece] atX:p2X atY:p2Y];
    piece3 = [self createPiece:[self getRandomPiece] atX:p3X atY:p3Y];
    
    //Adding children to the playscene and the playscene to the main scene
    [playScene addChild:piece1];
    [playScene addChild:piece2];
    [playScene addChild:piece3];
    [self addChild:playScene];
}

-(SPImage*) createPiece:(NSString *)shape atX:(int)x atY:(int)y {
    int shapeWidth = [[shape substringWithRange:NSMakeRange(0, 1)] intValue];
    int shapeHeight = [[shape substringWithRange:NSMakeRange(2, 1)] intValue];
    SPImage* p = [[SPImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@.png", shape]];
    p.name = shape;
    p.x = x; p.y = y;
    p.width = shapeHeight * tileSize + (shapeWidth - 1) * padding;
    p.height = shapeWidth * tileSize + (shapeWidth - 1) * padding;
    [p addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    return p;
}

-(void) onTouch: (SPTouchEvent *) event {
    //Different touch events and the dispatcher
    SPTouch *drag = [[event touchesWithTarget:self andPhase:SPTouchPhaseMoved] anyObject];
    SPTouch *stop = [[event touchesWithTarget:self andPhase:(SPTouchPhaseEnded)] anyObject];
    SPQuad *dispatcher = (SPQuad *) event.target;
    
    //When touch event stops
    if(stop) {
        int minDiffX = Sparrow.stage.width;
        int minDiffY = Sparrow.stage.height;
        int valX = 0;
        int valY = 0;
        int startX = 0;
        int startY = 0;
        //Find the cooridates of the closest tile
        for(int i = 0; i < 10; i++) {
            if(abs(dispatcher.x - (int) xCoordinates[i]) < minDiffX) {
                minDiffX = abs(dispatcher.x - (int) xCoordinates[i]);
                valX = (int) xCoordinates[i];
            }
            if(abs(dispatcher.y - (int) yCoordinates[i]) < minDiffY) {
                minDiffY = abs(dispatcher.y - (int) yCoordinates[i]);
                valY = (int) yCoordinates[i];
            }
        }
        
        //Find the reference to the SPQuad object at the closest's tile
        for(int i = 0; i < 10; i++) {
            for(int j = 0; j < 10; j++) {
                SPQuad *tile = (SPQuad *) board[i][j];
                if(tile.x == valX && tile.y == valY) {
                    startX = i; startY = j;
                    break;
                }
            }
        }
        
        //Check if this piece fits in the current board
        if([self didShape:dispatcher.name FitStartingAtX:startX andY:startY]) {
            [self placePiece:dispatcher.name AtX:startX andAtY:startY];
            piecesPlaced++;
            [dispatcher removeFromParent];
            [self continueGame];
        }
    }
    
    //Handle drag event
    if (drag) {
        SPPoint *dragLocation = [drag locationInSpace:self];
        dispatcher.x = dragLocation.x;
        dispatcher.y = dragLocation.y;
    }
}
- (void) placePiece:(NSString *)shape AtX:(int)x andAtY:(int) y {
    int shapeWidth = [[shape substringWithRange:NSMakeRange(0, 1)] intValue];
    int shapeHeight = [[shape substringWithRange:NSMakeRange(2, 1)] intValue];
    for(int i = x; i < x + shapeWidth; i++) {
        for(int j = y; j < y + shapeHeight; j++) {
            SPQuad *tile = (SPQuad *) board[i][j];
            tile.color = 0xaabbcc;
        }
    }
}

- (BOOL) didShape:(NSString*)shape FitStartingAtX:(int)x andY: (int)y {
    int shapeWidth = [[shape substringWithRange:NSMakeRange(0, 1)] intValue];
    int shapeHeight = [[shape substringWithRange:NSMakeRange(2, 1)] intValue];
    for(int i = x; i < x + shapeWidth; i++) {
        for(int j = y; j < y + shapeHeight; j++) {
            SPQuad *tile = (SPQuad *) board[i][j];
            if(tile.color != tileColor) {
                return false;
            }
        }
    }
    return true;
}

- (void) continueGame {
    [self clearRowCol];
    if(![self isAWin]) {
        if(piecesPlaced == 3) {
            piecesPlaced = 0;
            [self add3Pieces];
        }
    }
    else {
        [self removeFromParent];
    }
}

- (BOOL) isAWin {
    return false;
}

- (void) animateTile: (SPQuad*)tile {
    SPTween* tween = [SPTween tweenWithTarget:tile time:0.2f transition:SP_TRANSITION_LINEAR];
    [tween setDelay:0.5f];
    [tween animateProperty:@"width" targetValue:50.0f];
    [tween animateProperty:@"height" targetValue:50.0f];
    [Sparrow.juggler addObject:tween];
    [tween animateProperty:@"width" targetValue:30.0f];
    [tween animateProperty:@"height" targetValue:30.0f];
}

- (void) clearRowCol {
    for(int i = 0; i < 10; i++) {
        int count = 0;
        for(int j = 0; j < 10; j++) {
            SPQuad *tile = (SPQuad *) board[i][j];
            if(tile.color != tileColor) {
                count++;
            }
        }
        if(count == 10) {
            for(int col = 0; col < 10; col++) {
                SPQuad *tile = (SPQuad *) board[i][col];
                tile.color = tileColor;
            }
        }
    }
    for(int j = 0; j < 10; j++) {
        int count = 0;
        for(int i = 0; i < 10; i++) {
            SPQuad *tile = (SPQuad *) board[i][j];
            if(tile.color != tileColor) {
                count++;
            }
        }
        if(count == 10) {
            for(int row = 0; row < 10; row++) {
                SPQuad *tile = (SPQuad *) board[row][j];
                tile.color = tileColor;
            }
        }
    }
}

- (void)menuButtonTriggered:(SPEvent *)event {
    [playScene removeFromParent];
    Game *menuScene = [[Game alloc] init];
    [self addChild:menuScene];
}

@end