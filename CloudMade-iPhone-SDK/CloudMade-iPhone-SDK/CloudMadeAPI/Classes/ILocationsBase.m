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

#import <Foundation/Foundation.h>
#import "ILocationsBase.h"
#ifndef IPHONE_API_SAMPLES 			
#import "UserSettings.h"
#endif


NSString* g_strToken;

@implementation ILocationsBase

@synthesize errorStatus;

-(id) init
{
	[super init];
	serverResponse.status = NO;
	serverPhotoResponse.status = NO;
	elementIsProcessing = FALSE;
	errorStatus = FALSE;
	locationsArray = [[NSMutableArray alloc] init];
	return self;
}

-(NSString*) transformToUTF8:(NSString*) object 
{
	NSString* encode_object = [NSString stringWithUTF8String:[object cStringUsingEncoding:NSUTF8StringEncoding]]; 
	//return [encode_object stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	return encode_object;
}


+(NSString*) addToken:(NSString*) token toUrl:(NSString*) url 
{
	NSCharacterSet* chSet = [NSCharacterSet characterSetWithCharactersInString:@"?"];
	NSRange range = [url rangeOfCharacterFromSet:chSet];
	NSString* newUrl; 
	if( range.location !=  NSNotFound ) // url has parameters already
	{
		newUrl = [NSString stringWithFormat:@"%@&token=%@",url,token];
	}
	else // url does't have parameters 
	{
		newUrl = [NSString stringWithFormat:@"%@?token=%@",url,token];
	}
	return newUrl;
}


+(NSString*) addTokenToUrl:(NSString*) url
{
	NSCharacterSet* chSet = [NSCharacterSet characterSetWithCharactersInString:@"?"];
	NSRange range = [url rangeOfCharacterFromSet:chSet];
	NSString* newUrl; 
	if( range.location !=  NSNotFound ) // url has parameters already
	{
#ifndef IPHONE_API_SAMPLES 			
		newUrl = [NSString stringWithFormat:@"%@&token=%@",url,[UserSettings shareSingleton].userToken];
#else
		newUrl = [NSString stringWithFormat:@"%@&token=%@",url,g_strToken];		
#endif
	}
	else // url does't have parameters 
	{
#ifndef IPHONE_API_SAMPLES 					
		newUrl = [NSString stringWithFormat:@"%@?token=%@",url,[UserSettings shareSingleton].userToken];
#else
		newUrl = [NSString stringWithFormat:@"%@?token=%@",url,g_strToken];		
#endif
		
	}
	return newUrl;
}


- (NSArray*) createObjectsFromXML:(NSData*) data
{
	NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
	parser.delegate = self;
	if([parser parse])
	{
		return locationsArray;
	}
	return nil;
}

+(NSString*) getImageName:(NSString*) strUrl withDelimiter:(NSString*) delimiter
{
	NSRange range = [strUrl rangeOfString:delimiter options:NSBackwardsSearch];
	if(NSNotFound == range.location)
		return strUrl;
	range.location+=1;
	range.length = strUrl.length - range.location;
	unichar* ptrBuf = malloc(sizeof(unichar)* range.length);
	[strUrl getCharacters:ptrBuf range:range];
	NSString* result =  [[NSString alloc] initWithCharacters:ptrBuf length: range.length];
	PLog(@"location is %@\n",result);
	free(ptrBuf);
	return result;
}

-(NSString*) transformObjectsToXML:(NSArray*) objects
{
	NSString* strRes = [[NSString alloc]initWithString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><Location>"];
	for(Location* obj in objects)
	{
		NSString* node;		
		NSString* imageUrl = [ILocationsBase getImageName:obj.strURL withDelimiter:@"/"];
		NSString* photoUrl = (obj.strPhotoName == nil)?(DEFAULT_PHOTO_NAME):[ILocationsBase getImageName:obj.strPhotoName withDelimiter:@"="];
		
		obj.strDesc = obj.strDesc?obj.strDesc:DEFAULT_DESC;
		obj.strTag = obj.strTag?obj.strTag:DEFAULT_TAG;
		
		if(obj.strID)
		{
			node = [[NSString alloc] initWithFormat:@"<item><id>%@</id><name>%@</name><longitude>%f</longitude><latitude>%f</latitude><description>%@</description><marker>%@</marker><filename>%@</filename><tag>%@</tag></item>",
					obj.strID,obj.strName,obj.fLongitude,obj.fLatitude,obj.strDesc,imageUrl,photoUrl,obj.strTag];
		}
		else	
           node = [[NSString alloc] initWithFormat:@"<item><name>%@</name><longitude>%f</longitude><latitude>%f</latitude><description>%@</description><marker>%@</marker><filename>%@</filename><tag>%@</tag></item>",
						  obj.strName,obj.fLongitude,obj.fLatitude,obj.strDesc,imageUrl,photoUrl,obj.strTag];
		

		strRes = [strRes stringByAppendingString:node];
	}
    strRes = [strRes stringByAppendingString:@"</Location>"];	
	//return [strRes cStringUsingEncoding:NSUTF8StringEncoding];
	return [NSString stringWithUTF8String:[strRes UTF8String]]; 
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
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
	free(pData);
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
    // do something with the data
    // receivedData is declared as a method instance elsewhere
	unsigned char* pData = malloc([receivedData length]);
    PLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	[receivedData getBytes:pData];
	//pData[[receivedData length]] = '\0';
	NSString* desc = [NSString stringWithUTF8String:(const char*)pData];
    PLog(@"connectionDidFinishLoading \n\ndata %@",desc);	
	
	[ptrCalle performSelector:ptrFunc withObject:self];

	free(pData);
    [connection release];
    [receivedData release];
}

// parsing of the XML

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qualifiedName 
	attributes:(NSDictionary *)attributeDict
{
	if([elementName isEqualToString:@"item"])
	{
		if(elementIsProcessing == TRUE)
			PLog(@"What's the fuck ...\n");
		elementIsProcessing = TRUE;
	}
	if([elementName isEqualToString:@"id"])	
		currentProcessingTag = L_ID;
	if([elementName isEqualToString:@"name"])	
		currentProcessingTag = L_NAME;
	if([elementName isEqualToString:@"longitude"])	
		currentProcessingTag = L_LNG;
	if([elementName isEqualToString:@"latitude"])	
		currentProcessingTag = L_LAT;
	if([elementName isEqualToString:@"description"])	
		currentProcessingTag = L_DESC;
	if([elementName isEqualToString:@"tag"])	
		currentProcessingTag = L_TAGS;
	if([elementName isEqualToString:@"marker"])
		currentProcessingTag = L_IMG;
	if([elementName isEqualToString:@"result"])
		currentProcessingTag = L_RESPONSE;
	if([elementName isEqualToString:@"rid"])
		currentProcessingTag = L_RID;
	if([elementName isEqualToString:@"filename"])
		currentProcessingTag = 	L_FILENAME;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if([elementName isEqualToString:@"item"])
	{
		elementIsProcessing = FALSE;
        Location* loc = [Location alloc];
 		loc.strName = strName;
		loc.strDesc = strDesc;
		loc.strID = strID;
		loc.strTag = strTag;
		loc.fLatitude = fLat;
		loc.fLongitude = fLng;
		loc.strURL = strURL;
		loc.strPhotoName = serverPhotoResponse.filename;
		[locationsArray addObject:loc];
		//[loc dealloc];
		strName = @"";
		strTag = @"";
		strDesc = @"";
	}
	currentProcessingTag = L_NONE;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	switch(currentProcessingTag)
	{
		case L_LAT:
			fLat = [string floatValue];
			break;
		case L_LNG:
			fLng = [string floatValue];
			break;
		case L_NAME:
		{
			if(strName)
				strName = [strName stringByAppendingString:string];
			else
				strName = string;
		}
			break;
		case L_DESC:
		{
			if(strDesc)
			{
				strDesc = [strDesc stringByAppendingString:string];
			}
			else
			{
				strDesc = string;
			}
		}
			break;
		case L_ID:
			strID = string;
			break;
		case L_TAGS:
			if(strTag)
			{
				strTag = [strTag stringByAppendingString:string];
			}
			else
				strTag = string;
			break;
		case L_IMG:
			strURL = string;
			break;
		case L_RESPONSE:
			serverResponse.status = [string boolValue];			
			serverPhotoResponse.status = [string boolValue];			
			break;
		case L_RID:
			serverResponse.nID = [string intValue];
			break;
		case L_FILENAME:
			serverPhotoResponse.filename = string;
			[serverPhotoResponse.filename retain];
			break;
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	
}

- (NSArray*) getLocationsArray
{
	return locationsArray;
}

-(void) handleServerResponse:(NSData*) data
{
	
}

@end
