//
//  Play.m
//  AppScaffold
//
//  Created by Brian Ensor on 4/15/11.
//  Copyright 2011 Brian Ensor Apps. All rights reserved.
//

#import "Play.h"
#import "Game.h"

@implementation Play {
    SPSprite *playScene;
    SPQuad *piece1;
    SPImage *img;
    NSInteger xCoordinates[10];
    NSInteger yCoordinates[10];
    NSMutableArray *board;
}

- (id)init {
    if ((self = [super init])) {
        board = [[NSMutableArray alloc] initWithCapacity:10];
        for(int i = 0; i < 10; i++) {
            [board insertObject:[[NSMutableArray alloc] initWithCapacity:10] atIndex:i];
        }
        
        playScene = [[SPSprite alloc] init];
        
        //Titles, buttons
        SPTexture *butonTexture = [SPTexture textureWithContentsOfFile:@"button_medium.png"];
        SPButton *menuButton = [SPButton buttonWithUpState:butonTexture text:@"Menu"];
        menuButton.fontColor = 0xFFFFFF;
        menuButton.fontSize = 30;
        menuButton.x = (Sparrow.stage.width-menuButton.width)/2;
        menuButton.y = 20;
        [menuButton addEventListener:@selector(menuButtonTriggered:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
        
        //Tiles
        int tileSize = 30;
        int padding = 5, startY = 80, startX = (Sparrow.stage.width - (9 * padding + 10 * tileSize))/2;
    
        for(int i = 0; i < 10; i++) {
            for(int j = 0; j < 10; j++) {
                SPQuad *quad = [SPQuad quadWithWidth:tileSize height:tileSize];
                quad.x = startX;
                quad.y = startY;
                board[i][j] = quad;
                quad.color = 0xff5050;
                [playScene addChild:quad];
                xCoordinates[j] = startX;
                startX += tileSize + padding;
            }
            startX = (Sparrow.stage.width - (9 * padding + 10 * tileSize))/2;
            yCoordinates[i] = startY;
            startY += tileSize + padding;
        }
        
        //Test tiles
        piece1 = [SPQuad quadWithWidth:tileSize height:tileSize color:0xff000];
        piece1.x = startX; piece1.y = startY + 100;
        piece1.name = @"p1";
        [piece1 addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
        [playScene addChild:piece1];
        
        //Test tiles2
        img = [[SPImage alloc] initWithContentsOfFile:@"3x3.png"];
        img.width = 100;
        img.height = 100;
        img.x = 15;
        

        [img addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
        [playScene addChild:img];
        
        [playScene addChild:menuButton];
        [self addChild:playScene];
    }
    return self;
}

-(void) onTouch: (SPTouchEvent *) event {
    SPTouch *drag = [[event touchesWithTarget:self andPhase:SPTouchPhaseMoved] anyObject];
    SPTouch *stop = [[event touchesWithTarget:self andPhase:(SPTouchPhaseEnded)] anyObject];
    SPQuad *dispatcher = (SPQuad *) event.target;
            NSLog(@"%@", dispatcher.name);
    if(stop) {
        int minDiffX = Sparrow.stage.width;
        int minDiffY = Sparrow.stage.height;
        int valX = 0;
        int valY = 0;
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
        //dispatcher.x = valX
        //dispatcher.y = valY;

        for(int i = 0; i < 10; i++) {
            for(int j = 0; j < 10; j++) {
                SPQuad *tile = (SPQuad *) board[i][j];
                if(tile.x == valX && tile.y == valY) {
                    tile.color = 0x0;
                }
            }
        }
    }
    
    if (drag) {
        SPPoint *dragLocation = [drag locationInSpace:self];
        dispatcher.x = dragLocation.x;
        dispatcher.y = dragLocation.y;
    }
}

- (void)menuButtonTriggered:(SPEvent *)event {
    [playScene removeFromParent];
    Game *menuScene = [[Game alloc] init];
    [self addChild:menuScene];
}

@end
