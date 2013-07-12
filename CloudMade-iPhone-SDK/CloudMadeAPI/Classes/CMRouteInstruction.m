//
//  RouteInstruction.m
//  NavigationView
//
//  Created by Dmytro Golub on 4/11/09.
//  Copyright 2009 Cloudmade. All rights reserved.
//

#import "CMRouteInstruction.h"


@implementation CMRouteInstruction

@synthesize instruction;
@synthesize distance;
@synthesize location;
@synthesize turnInstruction;


/*
 C	continue (go straigth)
 TL	turn left
 TSLL	turn slight left
 TSHL	turn sharp left
 TR	turn right
 TSLR	turn slight right
 TSHR	turn sharp rigth
 TU	U-turn
 */

-(CMRouteTurnInstruction) extractTurnInstruction:(NSDictionary*) instructionInfo
{
	if([instructionInfo objectForKey:@"turn_type"] == nil)
		return CMContinueInstruction;
	
	if([[instructionInfo objectForKey:@"turn_type"] isEqualToString:@"C"])
		return CMContinueInstruction;
	if([[instructionInfo objectForKey:@"turn_type"] isEqualToString:@"TL"])
		return CMTurnLeftInstruction;
	if([[instructionInfo objectForKey:@"turn_type"] isEqualToString:@"TSLL"])
		return CMTurnSlightLeftInstruction;
	if([[instructionInfo objectForKey:@"turn_type"] isEqualToString:@"TSHL"])
		return CMTurnSharpLeftInstruction;
	if([[instructionInfo objectForKey:@"turn_type"] isEqualToString:@"TR"])
		return CMTurnRightInstruction;
	if([[instructionInfo objectForKey:@"turn_type"] isEqualToString:@"TSLR"])
		return CMTurnSlightRightInstruction;
	if([[instructionInfo objectForKey:@"turn_type"] isEqualToString:@"TSHR"])
		return CMTurnSharpRightInstruction;
	if([[instructionInfo objectForKey:@"turn_type"] isEqualToString:@"TU"])
		return CMMakeUTurnInstruction;
	if([[instructionInfo objectForKey:@"turn_type"] isEqualToString:@"EXIT1"])
		return CMTakeExit1Instruction;
	
	if([[instructionInfo objectForKey:@"turn_type"] isEqualToString:@"EXIT2"])
		return CMTakeExit2Instruction;
	if([[instructionInfo objectForKey:@"turn_type"] isEqualToString:@"EXIT3"])
		return CMTakeExit3Instruction;
	if([[instructionInfo objectForKey:@"turn_type"] isEqualToString:@"EXIT4"])
		return CMTakeExit4Instruction;
	if([[instructionInfo objectForKey:@"turn_type"] isEqualToString:@"EXIT5"])
		return CMTakeExit5Instruction;
	if([[instructionInfo objectForKey:@"turn_type"] isEqualToString:@"EXIT6"])
		return CMTakeExit6Instruction;

	if([[instructionInfo objectForKey:@"turn_type"] isEqualToString:@"EXIT7"])
		return CMTakeExit7Instruction;
	if([[instructionInfo objectForKey:@"turn_type"] isEqualToString:@"EXIT8"])
		return CMTakeExit8Instruction;
	if([[instructionInfo objectForKey:@"turn_type"] isEqualToString:@"EXIT9"])
		return CMTakeExit9Instruction;
	if([[instructionInfo objectForKey:@"turn_type"] isEqualToString:@"EXIT10"])
		return CMTakeExit10Instruction;
	if([[instructionInfo objectForKey:@"turn_type"] isEqualToString:@"EXIT11"])
		return CMTakeExit11Instruction;
	
	return CMTakeExit12Instruction;
}

-(NSString*) imageFileName
{
	if(self.turnInstruction == CMContinueInstruction)
		return [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"C.png"];

	if(self.turnInstruction == CMTurnLeftInstruction)
		return [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"TL.png"];
		
	if(self.turnInstruction == CMTurnSlightLeftInstruction)
		return [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"TSLL.png"];

	if(self.turnInstruction == CMTurnSharpLeftInstruction)
		return [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"TSHL.png"];

	if(self.turnInstruction == CMTurnRightInstruction)
		return [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"TR.png"];

	if(self.turnInstruction == CMTurnSlightRightInstruction)
		return [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"TSLR.png"];
		
	if(self.turnInstruction == CMTurnSharpRightInstruction)
		return [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"TSHR.png"];

	if(self.turnInstruction == CMMakeUTurnInstruction)
		return [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"TU.png"];
		
	if(self.turnInstruction == CMTakeExit1Instruction)
		return [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"EXIT1.png"];
		
	if(self.turnInstruction == CMTakeExit2Instruction)
		return [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"EXIT2.png"];

	if(self.turnInstruction == CMTakeExit3Instruction)
		return [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"EXIT3.png"];
			
	if(self.turnInstruction == CMTakeExit4Instruction)
		return [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"EXIT4.png"];

	if(self.turnInstruction == CMTakeExit5Instruction)
		return [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"EXIT5.png"];
		
	if(self.turnInstruction == CMTakeExit6Instruction)
		return [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"EXIT6.png"];

	if(self.turnInstruction == CMTakeExit7Instruction)
		return [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"EXIT7.png"];
		
	if(self.turnInstruction == CMTakeExit8Instruction)
		return [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"EXIT8.png"];
				
	if(self.turnInstruction == CMTakeExit9Instruction)
		return [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"EXIT9.png"];
					
	if(self.turnInstruction == CMTakeExit10Instruction)
		return [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"EXIT10.png"];
						
	if(self.turnInstruction == CMTakeExit11Instruction)
		return [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"EXIT11.png"];
							
	return [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"EXIT12.png"];
}

@end
