//
//  Game.m
//  flash
//
//  Created by Long Tran on 6/5/15.
//  Copyright (c) 2015 Long Tran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Sparrow/Sparrow.h>
#import "Game.h"
#import "Play.h"

@implementation Game {
    SPSprite *mainMenu;
    float offsetY;
}

- (id)init
{
    if ((self = [super init]))
    {
        
        //Make simple adjustments for iPhone 5+ screens:
        offsetY = (Sparrow.stage.height - 480) / 2;
        
        //Init mainMenu
        mainMenu = [[SPSprite alloc] init];
        
        //Main menu buttons
        SPTextField *title = [SPTextField textFieldWithWidth:320 height:70 text:@"Play" fontName:@"Helvetica" fontSize:70 color:0xFFFFFF];
        SPTexture *butonTexture = [SPTexture textureWithContentsOfFile:@"button_medium.png"];
        SPButton *button = [SPButton buttonWithUpState:butonTexture text:@"Play"];
        button.x = (Sparrow.stage.width - button.width)/2;
        button.y = title.y+title.height+10;
        [button addEventListener:@selector(onButtonPressed:) atObject:self forType:SPEventTypeTriggered];
        [mainMenu addChild:button];
        
        //Add mainMenu
        [self addChild:mainMenu];
    }
    
    return self;
}

- (void) onButtonPressed:(SPEvent *) event {
    Play *playScene = [[Play alloc] init];
    [mainMenu removeFromParent];
    [self addChild:playScene];
}
@end