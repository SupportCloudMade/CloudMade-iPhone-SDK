/*
 * Copyright 2009 CloudMade.
 *
 * Licensed under the GNU Lesser General Public License, Version 3.0;
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.gnu.org/licenses/lgpl-3.0.txt
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "GetDataFromServer.h"
#import "Location.h"
#import "Utils.h" 
//#ifndef IPHONE_API_SAMPLES 			
//#import "UserSettings.h"
//#endif



@implementation GetDataFromServer

@synthesize delegate;

-(id) initWithToken:(NSString*) token
{
	self = [super init];
	_token = token;
	return self; 
}

+(NSString*) getImageUrl:(int) nIdx
{
	return [NSString stringWithFormat:@"%s00%i.png",IMAGE_URL,nIdx];
}

-(void) findLocations:(NSString*) request
{
	NSString* strUrl = [NSString stringWithFormat:@"%@tag/%@",LOCATION_BASE_URL,request]; 
    NSString* getRequestUrl = [ILocationsBase addToken:_token toUrl:strUrl];
	PLog(@"%@\n",getRequestUrl);
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:getRequestUrl]
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:60.0];
	// create the connection with the request
	// and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection) {
		// Create the NSMutableData that will hold
		// the received data
		// receivedData is declared as a method instance elsewhere
		receivedData=[[NSMutableData data] retain];
	} else {
		// inform the user that the download could not be made
	}		
}

/**
 @deprecated 
*/ 
-(void) getData:(NSString*) strUrl target:(id)target action:(SEL) action
{  
	ptrFunc = action;
	ptrCalle = target;
	//NSString* getRequestUrl = [NSString stringWithFormat:@"%@?token=%@",strUrl,[UserSettings shareSingleton].userToken];
    NSString* getRequestUrl = [ILocationsBase addTokenToUrl:strUrl];	
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:getRequestUrl]
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:60.0];
	// create the connection with the request
	// and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection) {
		// Create the NSMutableData that will hold
		// the received data
		// receivedData is declared as a method instance elsewhere
		receivedData=[[NSMutableData data] retain];
	} else {
		// inform the user that the download could not be made
	}		

}

-(NSArray*) getLocationsArray
{
  if(errorStatus)
	  return nil;
  return [self createObjectsFromXML:receivedData];
}


-(NSArray*) getIcons
{
	NSMutableArray* arrayOfIcons = [[NSMutableArray alloc] init];
	for(int i=0;i<NUMBER_OF_ICONS;++i)
	{
		NSString* url = [GetDataFromServer getImageUrl:i];
		UIImage* image =  [Utils getImage:url];
		[arrayOfIcons addObject:image];
	}
	return arrayOfIcons;
}


- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
	
    // inform the user
	
   	if(delegate)
		[delegate locationRequestError:error];	
	
    PLog(@"Connection failed! Error - %@ %@",
		 [error localizedDescription],
		 [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
   	if(delegate)
		[delegate locationsFound:[self createObjectsFromXML:receivedData]];
    [connection release];
    [receivedData release];
}


@end
