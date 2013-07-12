/*
 *  RouteSimplification.mm
 *  CloudMadeApi
 *
 *  Created by Dmytro Golub on 1/18/10.
 *  Copyright 2010 CloudMade. All rights reserved.
 *
 */

#include <CoreLocation/CoreLocation.h>
#include <vector>

typedef std::vector<CLLocationCoordinate2D> GeoVector;
typedef CLLocationCoordinate2D GeoPoint;

GeoVector GDouglasPeucker( GeoVector source , float kink );


float distanceBetweenPointAndLine(GeoPoint loc,GeoVector line)
{
	
	GeoPoint p0 = line[0];
	GeoPoint pL = line[line.size()-1];
/*	
	GeoPoint v = {loc.latitude - p0.latitude,loc.longitude - p0.longitude};
	GeoPoint l = {pL.latitude - p0.latitude,pL.longitude - p0.longitude};
	
	float dot = (v.latitude*l.latitude + v.latitude*l.latitude);
	
	float distance = 0;
	
	if( dot <=0 )
	{
		float dx = (p0.latitude - loc.latitude);
		float dy = (p0.longitude - loc.longitude);
		distance = dx*dx + dy*dy;
	}
	else if ((dot*dot) >= ((pL.latitude - p0.latitude)*(pL.latitude - p0.latitude) + (pL.longitude - p0.longitude)*(pL.longitude - p0.longitude)) )
	{
		float dx = (pL.latitude - loc.latitude);
		float dy = (pL.longitude - loc.longitude);
		distance = dx*dx + dy*dy;
	}
	else
	{
		float dx = (p0.latitude - loc.latitude);
		float dy = (p0.longitude - loc.longitude);
		distance = (dx*dx + dy*dy) - dot*dot;		
	}
	
	return distance;
*/	
	float dx =  (pL.latitude - p0.latitude);
	float dy = ( pL.longitude - p0.latitude);
	float tmpDistance = ( p0.longitude - pL.latitude )*loc.latitude 
	+ dx * loc.longitude + (p0.latitude * pL.longitude - pL.latitude * p0.longitude);
	
	float distance = tmpDistance/sqrt( dx*dx + dy*dy);
	return fabs(distance);
}



GeoVector DouglasPeucker(const GeoVector& poly,float eps)
{
	float dmax = 0;
	int idx = 0;
	
	//PLog(@"result vector count = %d\n",poly.size());	
	
	for( int i=1;i<poly.size();++i )
	{
		float distance = distanceBetweenPointAndLine(poly[i], poly);
		if(dmax < distance)
 		{
			dmax = distance;
			idx = i;
		}
	}
	
	GeoVector resultVector;
	
	if (dmax > eps)
	{
		GeoVector res1 = DouglasPeucker(GeoVector(poly.begin(),poly.begin()+idx),eps);
		GeoVector res2 = DouglasPeucker(GeoVector(poly.begin()+idx+1,poly.end()),eps);
		resultVector.resize(res1.size() + res2.size());
        resultVector = res1;
		resultVector.insert(resultVector.begin()+res1.size(),res2.begin(),res2.end());
	}
	else
	{
		resultVector = poly;
	}
	return resultVector;
}


extern "C"  CLLocationCoordinate2D* simplifyRoute(CLLocationCoordinate2D* route,int *nCount,float distance)
{
	GeoVector points = GeoVector(route,route+(*nCount));
	//GeoVector res = DouglasPeucker(points,36);
	GeoVector res = GDouglasPeucker(points, distance);	
	
	//PLog(@"Before %d after %d\n",points.size(),res.size());
	GeoVector::iterator it = res.begin();
	
	CLLocationCoordinate2D* simplifiedRoute = (CLLocationCoordinate2D*)malloc(sizeof(CLLocationCoordinate2D) * res.size()); 
	
	for(int i=0;i<res.size();++i)
	{
		simplifiedRoute[i] = res[i];
	}
	*nCount = res.size();
	return simplifiedRoute;
}




 /* Stack-based Douglas Peucker line simplification routine 
 returned is a reduced GLatLng array 
 After code by  Dr. Gary J. Robinson,
 Environmental Systems Science Centre,
 University of Reading, Reading, UK
 */


GeoVector GDouglasPeucker( GeoVector source , float kink )
{
    int	n_source, n_stack, n_dest, start, end, i, sig;    
    float dev_sqr, max_dev_sqr, band_sqr;
    float x12, y12, d12, x13, y13, d13, x23, y23, d23;
    float F = ((M_PI / 180.0) * 0.5 );
	std::vector<int> index(source.size());// = new Array(); /* aray of indexes of source points to include in the reduced line */
	std::vector<int> sig_start(source.size()) ;//= new Array(); /* indices of start & end of working section */
    std::vector<int> sig_end(source.size()) ;//= new Array();	
	
    /* check for simple cases */
	
    if ( source.size() < 3 ) 
        return(source);    /* one or two points */
	
    /* more complex case. initialize stack */
	
	n_source = source.size();
    band_sqr = kink * 360.0 / (2.0 * M_PI * 6378137.0);	/* Now in degrees */
    band_sqr *= band_sqr;
    n_dest = 0;
    sig_start[0] = 0;
    sig_end[0] = n_source-1;
    n_stack = 1;
	
    /* while the stack is not empty  ... */
    while ( n_stack > 0 ){
		
        /* ... pop the top-most entries off the stacks */
		
        start = sig_start[n_stack-1];
        end = sig_end[n_stack-1];
        n_stack--;
		
        if ( (end - start) > 1 ){  /* any intermediate points ? */        
			
			/* ... yes, so find most deviant intermediate point to
			 either side of line joining start & end points */                                   
            
            x12 = (source[end].longitude - source[start].longitude);
            y12 = (source[end].latitude - source[start].latitude);
            if (fabs(x12) > 180.0) 
                x12 = 360.0 - fabs(x12);
            x12 *= cos(F * (source[end].latitude + source[start].latitude));/* use avg lat to reduce lng */
            d12 = (x12*x12) + (y12*y12);
			
            for ( i = start + 1, sig = start, max_dev_sqr = -1.0; i < end; i++ ){                                    
				
                x13 = (source[i].longitude - source[start].longitude);
                y13 = (source[i].latitude - source[start].latitude);
                if (fabs(x13) > 180.0) 
                    x13 = 360.0 - fabs(x13);
                x13 *= cos (F * (source[i].latitude + source[start].latitude));
                d13 = (x13*x13) + (y13*y13);
				
                x23 = (source[i].longitude - source[end].longitude);
                y23 = (source[i].latitude - source[end].latitude);
                if (fabs(x23) > 180.0) 
                    x23 = 360.0 - fabs(x23);
                x23 *= cos(F * (source[i].latitude + source[end].latitude));
                d23 = (x23*x23) + (y23*y23);
				
                if ( d13 >= ( d12 + d23 ) )
                    dev_sqr = d23;
                else if ( d23 >= ( d12 + d13 ) )
                    dev_sqr = d13;
                else
                    dev_sqr = (x13 * y12 - y13 * x12) * (x13 * y12 - y13 * x12) / d12;// solve triangle
				
                if ( dev_sqr > max_dev_sqr  ){
                    sig = i;
                    max_dev_sqr = dev_sqr;
                }
            }
			
            if ( max_dev_sqr < band_sqr ){   /* is there a sig. intermediate point ? */
                /* ... no, so transfer current start point */
                index[n_dest] = start;
                n_dest++;
            }
            else{
                /* ... yes, so push two sub-sections on stack for further processing */
                n_stack++;
                sig_start[n_stack-1] = sig;
                sig_end[n_stack-1] = end;
                n_stack++;
                sig_start[n_stack-1] = start;
                sig_end[n_stack-1] = sig;
            }
        }
        else{
			/* ... no intermediate points, so transfer current start point */
			index[n_dest] = start;
			n_dest++;
        }
    }
	
    /* transfer last point */
    index[n_dest] = n_source-1;
    n_dest++;
	
    /* make return array */
    GeoVector r;//(n_dest);// = new Array();
    for(int i=0; i < n_dest; i++)
	{
		r.push_back(source[index[i]]);
	}
	//PLog(@"result array siz() = %d\n",r.size());
    return r;
}

 
