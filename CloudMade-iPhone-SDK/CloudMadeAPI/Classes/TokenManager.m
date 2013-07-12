//
//  TokenManager.m
//  CloudMadeApi
//
//  Created by Dmytro Golub on 11/5/09.
//  Copyright 2009 CloudMade. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TokenManager.h"

//TODO: has to be deleted 


#define kTokenFileName @"accessToken"
#define RMCloudMadeAccessTokenRequestFailed @"RMCloudMadeAccessTokenRequestFailed" 
#define CMTokenAuthorizationServer @"http://auth.cloudmade.com"


@implementation TokenManager


@synthesize accessToken = _accessToken , accessKey = _apikey;

-(id) initWithApikey:(NSString*) apikey
{
	self = [super init];
	_apikey = apikey;
	return self;
}


+ (NSString*)pathForSavedAccessToken:(NSString*) apikey
{
	NSArray *paths;
	paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0) // Should only be one...
	{
		NSString *cachePath = [paths objectAtIndex:0];
		return [cachePath stringByAppendingPathComponent:apikey];
	}
	return nil;
}

-(BOOL) readTokenFromFile
{
	NSString* pathToSavedAccessToken = [TokenManager pathForSavedAccessToken:_apikey];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:pathToSavedAccessToken])
	{
		//- (id)initWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error
		NSError* error;
		_accessToken = [[NSString alloc] initWithContentsOfFile:pathToSavedAccessToken encoding:NSASCIIStringEncoding error:&error];
		if(!_accessToken)
		{
			PLog(@"can't read file %@ %@\n",pathToSavedAccessToken,error.localizedDescription);
			//logMsg("can't read file %@ %@\n");
			[[NSFileManager defaultManager] removeItemAtPath:pathToSavedAccessToken error:nil];
			return FALSE;
		}
		
	}
	else
	{
		return FALSE;
	}
#ifdef __NETWORK_LOGGING__	
	logMsg2("%s Taken token from file %s !!!\n",__FUNCTION__,[pathToSavedAccessToken UTF8String]);
#endif	
	return TRUE;
}

-(void) requestToken
{
	
	if([self readTokenFromFile])
		return;
	
	
	NSString* url = [NSString stringWithFormat:@"%@/token/%@",CMTokenAuthorizationServer,_apikey] ;
	
	NSData* data = nil;
	PLog(@"%s, url = %@\n",__FUNCTION__,url);
#ifdef __NETWORK_LOGGING__	
	logMsg2("%s try to request token!!!\nurl = %s\n",__FUNCTION__,[url UTF8String]);
#endif	
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
															cachePolicy:NSURLRequestUseProtocolCachePolicy
														timeoutInterval:5.0];
	[ theRequest setHTTPMethod: @"POST" ];
	
	// create the connection with the request
	// and start loading the data
	//NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	NSURLResponse* response;
	NSError*       error = nil; 
	BOOL done = FALSE;
	int attempt = 0;
	do
	{
		//TODO: Check response code
		data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
		if(data && [(NSHTTPURLResponse*)response statusCode] == 200)
		{
			NSString* pathToSavedAccessToken = [TokenManager pathForSavedAccessToken:_apikey];
			_accessToken = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
			[_accessToken writeToFile:pathToSavedAccessToken atomically:YES encoding:NSASCIIStringEncoding error:nil];
			done = TRUE;
		}
		else
		{
			if([(NSHTTPURLResponse*)response statusCode] == 403 && !attempt)
			{
				PLog(@"Token wasn't obtained.Response code = %d\n",[(NSHTTPURLResponse*)response statusCode]);
#ifdef __NETWORK_LOGGING__				
				logMsg2("%s Token wasn't obtained.Response code = %d\n",__FUNCTION__,[(NSHTTPURLResponse*)response statusCode]);
#endif				
				attempt++;
			}
			else
			{
				PLog(@"Token wasn't obtained %@\n",error.localizedDescription);
#ifdef __NETWORK_LOGGING__				
				logMsg2("%s Token wasn't obtained\n Post notification!!!\n",__FUNCTION__);
#endif				
				//TODO: raise exception??? Send notification seems to be more apropriate
				[[NSNotificationCenter defaultCenter] postNotificationName:RMCloudMadeAccessTokenRequestFailed object:error];
				done = TRUE;
			}
			
		}
	}
	while(!done);
}

-(NSString*) appendRequestWithToken:(NSString*) url
{
	NSCharacterSet* chSet = [NSCharacterSet characterSetWithCharactersInString:@"?"];
	NSRange range = [url rangeOfCharacterFromSet:chSet];
	NSString* newUrl; 
	if( range.location !=  NSNotFound ) // url has parameters already
	{
		newUrl = [NSString stringWithFormat:@"%@&token=%@",url,self.accessToken];
	}
	else // url does't have parameters 
	{
		newUrl = [NSString stringWithFormat:@"%@?token=%@",url,self.accessToken];
	}
	return newUrl;	
}

-(NSString*) accessToken
{
	if(!_accessToken)
		[self requestToken];
	return _accessToken;
}

@end
