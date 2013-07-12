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

#import "postDataToServer.h"

#ifndef IPHONE_API_SAMPLES
#import "UserSettings.h"
#endif

extern NSString* g_strToken;

@interface PostDataToServer (Private)
-(NSMutableURLRequest*) composeRequest:(NSString*) data withURL:(NSString*) url withMethod:(NSString*) method;
@end



@implementation PostDataToServer

@synthesize elementIndex;

-(id) initWithToken:(NSString*) token
{
	self = [super init];
	_token = token;
	return self;
}


-(NSMutableURLRequest*) composeRequest:(NSString*) data withURL:(NSString*) url withMethod:(NSString*) method
{
	NSString *post = [NSString stringWithFormat:@"%@",data];
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];	
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];

    NSString* postRequestUrl = [ILocationsBase addToken:_token toUrl:url];		
	PLog(@"compose request URL = %@\n",postRequestUrl);	
	[request setURL:[NSURL URLWithString:postRequestUrl]];
	[request setHTTPMethod:method];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	return request;
}

-(BOOL) postDataToServer:(NSString*) xml :(NSString*) url :(id) target :(SEL) action :(int) elementIdx
{
	ptrFunc = action;
	ptrCalle = target;
	elementIndex = elementIdx;
	
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:[self composeRequest :xml withURL:url withMethod:@"POST" ] delegate:self];
	if (theConnection) {
		// Create the NSMutableData that will hold
		// the received data
		// receivedData is declared as a method instance elsewhere
		receivedData=[[NSMutableData data] retain];
		return TRUE;
	} else {
		// inform the user that the download could not be made
		return FALSE;
	}		
}

-(void) post:(NSString*) url
{
	Location* location = [Location alloc];
	location.strName = @"Saint Sophia Cathedral";
	location.strDesc = @"Saint Sophia Cathedral";
	location.fLatitude = 50.2710;
	location.fLongitude = 30.3052;
	location.strTag = @"church,cathedral,Kiev";
	NSMutableArray* objs = [NSMutableArray arrayWithCapacity:2];
	[objs addObject:location];
	NSString* xml = [self transformObjectsToXML:objs]; 
	PLog(@"\n\n%@\n",xml);
	//[self postDataToServer:xml :url];
}

-(BOOL) deleteItem:(NSString*) itemID withURL:(NSString*) url
{
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:[self composeRequest :itemID withURL:url withMethod:@"DELETE" ] delegate:self];
	if (theConnection) {
		receivedData=[[NSMutableData data] retain];
		return TRUE;
	} else {
		// inform the user that the download could not be made
		return FALSE;
	}		
}

-(ServerResponse) getResponse
{
    [self createObjectsFromXML:receivedData];
	return serverResponse;
}

-(ServerPhotoResponse) getPhotoResponse
{
    [self createObjectsFromXML:receivedData];
	return serverPhotoResponse;
}

- (NSString *)multipartBoundary
{
	// The boundary has 27 '-' characters followed by 16 hex digits
	return [NSString stringWithFormat:@"---------------------------%08X%08X",rand(), rand()];
}

-(void) postImage:(NSString*) url :(UIImage*) image withQuality:(float) quality :(id) target :(SEL) action 
{

	ptrCalle = target;
	ptrFunc = action;
	
	//NSData * imageData = UIImagePNGRepresentation(image);
	NSData * imageData = UIImageJPEGRepresentation(image,quality);

	
	NSMutableURLRequest *theRequest = [[[NSMutableURLRequest alloc] init] autorelease];	
	[theRequest setHTTPMethod:@"POST"];

    
	NSString* postLength = [NSString stringWithFormat:@"%d",[imageData length]];
	NSString *boundary = [NSString stringWithString:@"----------------------------9d4c5056713d"];
    [theRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];	
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[theRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];

	
	//	//adding the body:
	NSMutableData *postBody = [NSMutableData data];
	NSString* strHeaders = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"userfile\"; filename=\"genome.png\"\r\n",boundary];
	[postBody appendData:[strHeaders dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:imageData];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[theRequest setHTTPBody:postBody];
	
//#ifndef IPHONE_API_SAMPLES 		
//	NSString* postRequestUrl = [NSString stringWithFormat:@"%@?token=%@",url,[UserSettings shareSingleton].userToken];	
//#else
	NSString* postRequestUrl = [NSString stringWithFormat:@"%@?token=%@",url,_token];	
//#endif	
	[theRequest setURL:[NSURL URLWithString:postRequestUrl]];	
	NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (conn)
	{
		receivedData = [[NSMutableData data] retain];
	}	
}

-(void) deleteImage:(NSString*) imageName
{
	NSString* url = [NSString stringWithFormat:@"%@delete_image?image=%@",LOCATION_BASE_URL,imageName];
	PLog(@"delete location with URL %@\n",url);
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:[self composeRequest :@"" withURL:url withMethod:@"DELETE" ] delegate:self];	
	if (theConnection) {
		receivedData=[[NSMutableData data] retain];
		return ;
	} else {
		// inform the user that the download could not be made
		return ;
	}		
}

-(BOOL) deleteItem:(NSString*) itemID
{
	return [self deleteItem:itemID withURL:[NSString stringWithFormat:@"%@deletelocation",LOCATION_BASE_URL]];
}

@end
