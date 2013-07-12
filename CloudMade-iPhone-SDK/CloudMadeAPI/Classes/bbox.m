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

#import "bbox.h"


@implementation BBox

@synthesize westernLongitude;
@synthesize southernLatitude;
@synthesize easternLongitude;
@synthesize northernLatitude;


-(NSString*) asString
{
	//return [NSString stringWithFormat:@"%f+%f,%f+%f",westernLongitude,southernLatitude,easternLongitude,northernLatitude];
	return [NSString stringWithFormat:@"%f,%f,%f,%f",southernLatitude,westernLongitude,northernLatitude,easternLongitude];	
}

@end
