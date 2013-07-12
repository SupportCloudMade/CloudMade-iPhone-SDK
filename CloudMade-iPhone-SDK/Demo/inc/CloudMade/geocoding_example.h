GeoCodingRequest* reverseGeocoding;

// creation
reverseGeocoding = [[GeoCodingRequest alloc] initWithApikey:@"518f15c781b5484cb89f78925904b783"
                                                 withOptions:nil tokenManager:_tokenManager];
reverseGeocoding.delegate = self; // ServiceRequestResult http://developers.cloudmade.com/documentation/iphone-api/v3/protocol_service_request_result-p.html

// request
[reverseGeocoding findObject:@"address" around:POSITION withDistance:nil];


// response

-(void) serviceServerResponse:(NSString*) jsonResponse
{
    GeoCodingJsonParser* jsonParser = [[GeoCodingJsonParser alloc] init];
    NSArray* objects = [jsonParser fillLocationsArray:jsonResponse]; 
    NSLog(@"response = %@\n",objects);
}