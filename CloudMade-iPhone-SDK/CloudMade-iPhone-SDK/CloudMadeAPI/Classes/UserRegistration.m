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

#import "UserRegistration.h"
#import "HelperConstant.h"
#ifndef IPHONE_API_SAMPLES    
    #import "UserSettings.h"
#endif //IPHONE_API_SAMPLES 


@implementation UserRegistration

@synthesize  delegate;
@synthesize  errorStatus;
//#ifdef IPHONE_API_SAMPLES    
@synthesize userToken;
@synthesize expiringTime;
//#endif //IPHONE_API_SAMPLES 

-(id) init
{
	errorStatus = FALSE;
	return self;
}

-(void) authorizeUser:(NSString*)userName withPassword:(NSString*)pass withAPIKEY:(NSString*)apikey
{
	NSString* strUrl = [NSString stringWithFormat:@"%@?name=%@&password=%@&apikey=%@",AUTHORIZATION_BASE_URL,userName,pass,apikey];
	PLog(@"\n strUrl = %@\n",strUrl);
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:10.0];
	
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
		case 400:case 401:case 403:case 404:case 500:
			errorStatus = YES;
			//@throw [NSException exceptionWithName: @"Server response" reason:@"Wrong parameters!!!" userInfo:nil];
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
	
	unsigned char* pData = malloc([data length]);
    PLog(@"Succeeded! Received %d bytes of data",[data length]);
	[data getBytes:pData];
    PLog(@"didReceiveData:\n %s\n\n", (char *)pData);	
	
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
   //NSURLErrorDomain
    PLog(@"Connection failed! Error - %@ %@\n Error code %i\n",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey],
	      error.code);
	[delegate authorizationRequestError:error];
}

-(void) fillCredentials:(NSData*) data
{
	NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
	parser.delegate = self;
    [parser parse];	
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
	//unsigned char* pData = malloc([receivedData length]);
    PLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	//pData[[receivedData length]] = '\0';
    //PLog(@"connectionDidFinishLoading \n\ndata %s", (char *)pData);
	if( !errorStatus )
		[self fillCredentials:receivedData]; 	
	
	[delegate authorizationServerResponse:self];
	//free(pData);
    [connection release];
    [receivedData release];
}



-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	currentParsedElement = elementName;
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	currentParsedElement = @"";	
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if( [currentParsedElement isEqualToString:USER_TOKEN])
	{
//#ifndef IPHONE_API_SAMPLES    
//		[UserSettings shareSingleton].userToken = string;
//#else        
		self.userToken = string;
//#endif        
	}
	else 
		if( [currentParsedElement isEqualToString:EXPIRING_TIME])
		{
//#ifndef IPHONE_API_SAMPLES            
//			[UserSettings shareSingleton].tokenExpiringTime = [NSDate dateWithTimeIntervalSince1970:[string floatValue]];
//#else                    
		self.expiringTime = [NSDate dateWithTimeIntervalSince1970:[string floatValue]];
//#endif        			
		}
}

 
@end
