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
    SPSprite *piece2;
    SPImage *img;
    NSInteger xCoordinates[10];
    NSInteger yCoordinates[10];
}

- (id)init {
    if ((self = [super init])) {
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
        [piece1 addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
        [playScene addChild:piece1];
        
        //Test tiles2
        piece2 = [[SPSprite alloc] init];
        SPQuad *q1 = [SPQuad quadWithWidth:tileSize height:tileSize color:0xaabbcc];
        SPQuad *q2 = [SPQuad quadWithWidth:tileSize height:tileSize color:0xaabbcc];
        SPQuad *q3 = [SPQuad quadWithWidth:tileSize height:tileSize color:0xaabbcc];
        q1.x = 300; q1.y = 300;
        q2.x = 350; q2.y = 300;
        q3.x = 300; q3.y = 350;
        [piece2 addChild:q1];
        [piece2 addChild:q2];
        [piece2 addChild:q3];
        //[piece2 addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
        //[playScene addChild:piece2];
    
        img = [[SPImage alloc] initWithContentsOfFile:@"button_medium.png"];
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
    /*
    if(stop) {
        int minDiffX = Sparrow.stage.width;
        int minDiffY = Sparrow.stage.height;
        int valX = 0;
        int valY = 0;
        for(int i = 0; i < 10; i++) {
            if(abs(piece1.x - (int) xCoordinates[i]) < minDiffX) {
                minDiffX = abs(piece1.x - (int) xCoordinates[i]);
                valX = (int) xCoordinates[i];
            }
            if(abs(piece1.y - (int) yCoordinates[i]) < minDiffY) {
                minDiffY = abs(piece1.y - (int) yCoordinates[i]);
                valY = (int) yCoordinates[i];
            }
        }
        piece1.x = valX;
        piece1.y = valY;
    }*/
    
    if (drag) {
        SPPoint *dragLocation = [drag locationInSpace:self];
        /*piece2.x = dragLocation.x;
        piece2.y = dragLocation.y;
        NSLog(@"%f %f", piece2.x, piece2.y);*/
        SPQuad *test = (SPQuad *) event.target;
        test.x = dragLocation.x;
        test.y = dragLocation.y;
    }
}

- (void)menuButtonTriggered:(SPEvent *)event {
    [playScene removeFromParent];
    Game *menuScene = [[Game alloc] init];
    [self addChild:menuScene];
}

@end
