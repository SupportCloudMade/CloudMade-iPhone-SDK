//
//  ServiceRequest.m
//  NavigationView
//
//  Created by Dmytro Golub on 2/9/09.
//  Copyright 2009 Cloudmade. All rights reserved.
//

#import "ServiceRequest.h"


@implementation ServiceRequest

@synthesize delegate;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // this method is called when the server has determined that it 
    // has enough information to create the NSURLResponse
	
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
	
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) response;	
	PLog(@"Server response %d\n",[httpResponse statusCode]);
	
	switch ([httpResponse statusCode])
	{
		case 400:case 401:case 403:case 404:case 500:case 504:
		{
			//serviceServerError
			if([(id)delegate respondsToSelector:@selector(serviceServerError:)])
				[delegate serviceServerError:[NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]]];
			//@throw [NSException exceptionWithName: @"Server response" reason:@"Wrong parameters!!!" userInfo:nil];
		}
			break; 
		default:
			break;
	}
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
	
	//unsigned char* pData = malloc([data length]);
    //PLog(@"Succeeded! Received %d bytes of data",[data length]);
//	[data getBytes:pData];
  //  PLog(@"didReceiveData:\n %s\n\n", (char *)pData);	
	//free(pData);
    [receivedData appendData:data];
}



- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
	
    // inform the user
    PLog(@"Connection failed! Error - %@ %@",
		 [error localizedDescription],
		 [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
/*	
    // do something with the data
    // receivedData is declared as a method instance elsewhere
	unsigned char* pData = malloc([receivedData length]);
    PLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	[receivedData getBytes:pData];
	pData[[receivedData length]] = '\0';
    //PLog(@"connectionDidFinishLoading \n\ndata %s", (char *)pData);
	
	[delegate serviceServerResponse:[[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding]];
	
	free(pData);
    [connection release];
    [receivedData release];
*/ 
}


@end
