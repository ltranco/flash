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
    SPQuad *piece1;
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
float p1X = 15, p2X = 90;
float p1Y = 350, p2Y = 350;
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
-(void) add3Pieces {
        //Piece 1
        //piece1 = [SPQuad quadWithWidth:tileSize height:tileSize color:0xff000];
        piece1 = [[SPImage alloc] initWithContentsOfFile:@"3x3.png"];
        piece2 = [[SPImage alloc] initWithContentsOfFile:@"3x3.png"];
        piece3 = [[SPImage alloc] initWithContentsOfFile:@"3x3.png"];
    
        piece1.x = p1X; piece1.y = p1Y + 100;
        piece1.name = @"3x3";
        piece3.name = @"3x3";

        piece1.width = 100;
        piece1.height = 100;
        piece3.width = 100;
        piece3.height = 100;
    
        //Piece 2
        piece2.name = @"3x3";
        piece2.width = 100;
        piece2.height = 100;
        piece2.x = p2X;
        piece2.y = p2Y + 100;
    
        [piece1 addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
        [piece2 addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
        [piece3 addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    
        //Adding children to the playscene and the playscene to the main scene
        [playScene addChild:piece1];
        [playScene addChild:piece2];
        [playScene addChild:piece3];
        [self addChild:playScene];
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
    int curX = x, curY = y;
    if([shape isEqualToString:@"3x3"]) {
        for(int i = 0; i < 3; i++) {
            for(int j = 0; j < 3; j++) {
                SPQuad *tile = (SPQuad *) board[curX][curY];
                tile.color = 0xaabbcc;
                curX++;
            }
            curY++;
            curX = x;
        }
    }
}

- (BOOL) didShape:(NSString*)shape FitStartingAtX:(int)x andY: (int)y {
    if([shape isEqualToString:@"3x3"] || [shape isEqualToString:@"2x2"]) {
        for(int i = x; i < x + 3; i++) {
            for(int j = y; j < y + 3; j++) {
                SPQuad *tile = (SPQuad *) board[i][j];
                if(tile.color != tileColor) {
                    return false;
                }
            }
        }
    }
    return true;
}

- (void) continueGame {
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

- (void)menuButtonTriggered:(SPEvent *)event {
    [playScene removeFromParent];
    Game *menuScene = [[Game alloc] init];
    [self addChild:menuScene];
}

@end
