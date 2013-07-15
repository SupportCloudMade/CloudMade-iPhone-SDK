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

#import "Utils.h"
#ifdef USE_IMAGE_CACHE	
	#import "ImagesCache.h"
#endif

const CFStringRef kCharsToForceEscape = CFSTR("!*'();:@&=+$,/?%#[]");

@implementation Utils

+(NSString*) removeTokenFromURL:(NSString*) url
{
	NSArray *listItems = [url componentsSeparatedByString:@"&"];
    NSAssert(listItems, @"URL format is unexpected!!!");
	PLog(@"%@\n",[listItems objectAtIndex:0]);
	return [listItems objectAtIndex:0];
}


+(UIImage*) downloadImage:(NSString*) strUrl
{
	NSURL *url = [NSURL URLWithString:strUrl];
	NSData *data = [NSData dataWithContentsOfURL:url];
	UIImage *image = [[UIImage alloc] initWithData:data];		
	return image;
}


+(UIImage*) getImage:(NSString*) strUrl
{
#ifndef USE_IMAGE_CACHE	
	return [Utils downloadImage:strUrl];
#else
	//UIImage* image = [[ImagesCache shareSingleton] getImageFromCache:strUrl];	
	UIImage* image = [[ImagesCache shareSingleton] getImageFromCache:[Utils removeTokenFromURL:strUrl]];
	if(!image)
	{
		image = [Utils downloadImage:strUrl];
		if(image)
		{
			[[ImagesCache shareSingleton] addImageToCache:image forKey:[Utils removeTokenFromURL:strUrl]];
		}
	}
	return image;
#endif	
}

+ (UIImage*)scaleAndRotateImage:(UIImage*) image  withWidth:(float) maxWidth  withHeight:(float) maxHeight 
{
	int kMaxResolution = 640; // Or whatever
	
	CGImageRef imgRef = image.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > kMaxResolution || height > kMaxResolution) {
		CGFloat ratio = width/height;
		if (ratio > 1) {
			bounds.size.width = kMaxResolution;
			bounds.size.height = bounds.size.width / ratio;
		}
		else {
			bounds.size.height = kMaxResolution;
			bounds.size.width = bounds.size.height * ratio;
		}
	}
	
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	UIImageOrientation orient = image.imageOrientation;
	switch(orient) {
			
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
	}
	
	UIGraphicsBeginImageContext(bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	}
	else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageCopy;
	
}


+(NSArray*) getCategories:(NSString*) fileName
{
	NSError* error;	
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *path = [bundle pathForResource: fileName ofType: nil];
	
	NSString* fileStr = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
	if(!fileStr)
	{
		PLog(@"%@\n",[error localizedDescription]);
		return nil;
	}
	return [fileStr componentsSeparatedByString:@","];	
}

+(NSString*) encodeStringForURL:(NSString*) string
{
	CFStringRef originalString = (CFStringRef) string;
	CFStringRef leaveUnescaped = CFSTR("");


	CFStringRef escapedStr;
	escapedStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
													 originalString,
													 leaveUnescaped,
													 kCharsToForceEscape,
													 kCFStringEncodingUTF8);
	NSMutableString *mutableStr = nil;

	if (escapedStr)
	{
		mutableStr = [NSMutableString stringWithString:(NSString *)escapedStr];
		CFRelease(escapedStr);
	}
	return mutableStr;
}


@end
