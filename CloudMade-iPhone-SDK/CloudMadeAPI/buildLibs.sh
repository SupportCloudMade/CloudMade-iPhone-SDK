#!/bin/bash

# path for iOS4 xcodebuild utility
XCODEiOS4="/Developer/usr/bin"

# path for iPhone 3.1.3 OS xcodebuild utility
XCODEOS3_1_3="/Developer/Developer_3.2/usr/bin"

# current folder

#CURRENT_DIR="/Users/user/xxx/route-me"

WORK_DIR="/Users/user/trash"
CURRENT_DIR="$WORK_DIR/CloudMade-iPhone-SDK"

echo $(pwd)

PWD=$(pwd)

# some varialbles

DEV_BUILD_FOLDER="Release-iphoneos"
SIM_BUILD_FOLDER="Release-iphonesimulator"



function build()
{  
    cd $6
	$2/xcodebuild -project $1.xcodeproj -target $1 -configuration $4 -sdk $3 #arch=$7
	
	mkdir -p "$6/bin"
	mkdir -p "$6/bin/lib"
	cp $6/build/"$4-iphoneos"/*.a "$6/bin/lib/$5_dev.a"
	
	$2/xcodebuild -project $1.xcodeproj -target $1 -configuration $4 -sdk iphonesimulator4.3 


	mkdir -p "$6/bin"
	mkdir -p "$6/bin/lib"
	cp $6/build/"$4-iphonesimulator"/*.a "$6/bin/lib/$5_sim.a"

    lipo "$6/bin/lib/$5_dev.a" -arch i386 "$6/bin/lib/$5_sim.a" -create -output "$6/bin/lib/$5.a"

	#clean build folder
	rm -rf build	
}

cd $WORK_DIR

cd $WORK_DIR
if [ -d $CURRENT_DIR ]; then
	echo "======= DELETING PREVIOUS FILES ========="
	rm -rfd $CURRENT_DIR
fi

#git clone --branch master git@tanker:CloudMade-iPhone-SDK.git 
git clone --branch master git@tanker:CloudMade-iPhone-SDK.git 
#git clone git@10.1.0.157:iphone-dev.git CloudMade-iPhone-SDK
cd  $CURRENT_DIR
git submodule init
git submodule update
echo "Applying patch!!!"
mv samples/CloudMadeAPI/renamed_json.patch samples/CloudMadeAPI/Classes/JSON-Framework/
cd samples/CloudMadeAPI/Classes/JSON-Framework/
#git apply renamed_json.patch
cd -
cd samples/CloudMadeAPI
#rm -rfd $CURRENT_DIR/install

echo "Start unit tests ... "

#$XCODEiOS4/xcodebuild -project $1.xcodeproj -target CMLibraryTest -configuration Debug -sdk iphonesimulator4.2

echo "Unit tests result!!!"
echo "$?"

if [ "$?" -ne "0" ]; then
	echo "Unit tests failed!!!"
	cp ocunit.xml $CC_BUILD_ARTIFACTS
	BAD_PERSON_EMAIL = "git log -1 | grep  -o '[[:alnum:]+\.\_\-]*@[[:alnum:]+\.\_\-]*'"
	 echo "WTF!!! Why did you break the build!!!" | mail -s "iOS library build is broken!!!" $BAD_PERSON_EMAIL
	exit 1
fi

cp ocunit.xml $CC_BUILD_ARTIFACTS 

build $1 $XCODEiOS4 iphoneos4.3 Release libCloudMadeApi  $CURRENT_DIR/samples/CloudMadeAPI
build $2 $XCODEiOS4 iphoneos4.3 Release libMapView  $CURRENT_DIR/MapView
build $3 $XCODEiOS4 iphoneos4.3 Release libProj4    $CURRENT_DIR/Proj4
echo "Copying files ... "

cd $CURRENT_DIR && mkdir -p install && cd install && mkdir -p inc && mkdir -p inc/CloudMade && rsync -av --include "RMMarkerAdditions.h" --exclude "LibUtils.h" --exclude "RoutingRequest.h" --exclude "JsonRoutingParser.h"  --exclude "*Additions.h" --exclude "DDInvocationGrabber.h" --exclude "CMAnnotationView.h" --exclude "locationCenter.h" $CURRENT_DIR/samples/CloudMadeAPI/Classes/*.h inc/CloudMade && mkdir -p inc/route-me && cp $CURRENT_DIR/MapView/Map/*.h inc/route-me && mkdir -p inc/Proj4 && cp $CURRENT_DIR/Proj4/*.h inc/Proj4

mkdir -p libs && mkdir -p libs/CloudMade && mkdir -p libs/route-me && mkdir -p libs/Proj4 && cp $CURRENT_DIR/samples/CloudMadeAPI/bin/lib/libCloudMadeApi.a libs/CloudMade && cp $CURRENT_DIR/MapView/bin/lib/libMapView.a libs/route-me && cp $CURRENT_DIR/Proj4/bin/lib/libProj4.a libs/Proj4



echo 'Generating package ...'

cp -r $CURRENT_DIR/install/inc $CURRENT_DIR/samples/CloudMadeMap && cp -r $CURRENT_DIR/install/libs  $CURRENT_DIR/samples/CloudMadeMap && /Developer/usr/bin/packagemaker -d  $CURRENT_DIR/samples/CloudMadeAPI/cmInstall.pmdoc -v -o CloudMadeAPI.pkg

ls -l $CURRENT_DIR/install/CloudMadeAPI.pkg

cd $CURRENT_DIR/install && cp "$CURRENT_DIR/samples/CloudMadeAPI/CloudMade iPhone SDK Installer.dmg" . && hdid "$CURRENT_DIR/install/CloudMade iPhone SDK Installer.dmg" && cp CloudMadeAPI.pkg '/Volumes/CloudMade iPhone SDK Installer/CloudMade iPhone SDK Installer.pkg' && echo "Copying the package file" && hdiutil eject   '/Volumes/CloudMade iPhone SDK Installer'  #&& hdiutil convert 'CloudMade iPhone SDK Installer.dmg' -format UDZO -o 'CloudMade iPhone SDK Installer_.dmg' && rm 'CloudMade iPhone SDK Installer.dmg' && mv 'CloudMade iPhone SDK Installer_.dmg' 'CloudMade iPhone SDK Installer.dmg' 


cp 'CloudMade iPhone SDK Installer.dmg' $CC_BUILD_ARTIFACTS


echo 'Generating separate libs & includes'
cd $CURRENT_DIR/install && tar --create --verbose --file=libs.tar libs && gzip libs.tar && cp $CURRENT_DIR/install/libs.tar.gz $CC_BUILD_ARTIFACTS
cd $CURRENT_DIR/install && tar --create --verbose --file=inc.tar inc && gzip inc.tar && cp $CURRENT_DIR/install/inc.tar.gz $CC_BUILD_ARTIFACTS
 


echo 'Generating documentation ...'

cd $CURRENT_DIR  && cp $CURRENT_DIR/samples/CloudMadeAPI/CloudMade.doxygen $CURRENT_DIR/install/inc/CloudMade/doxygen.config && echo "INPUT =  $CURRENT_DIR/install/inc/CloudMade" >>install/inc/CloudMade/doxygen.config && echo "EXAMPLE_PATH =  $CURRENT_DIR/install/inc/CloudMade" >>install/inc/CloudMade/doxygen.config && echo "OUTPUT_DIRECTORY =  $CURRENT_DIR/CloudMadeDoxygen" >> install/inc/CloudMade/doxygen.config && /opt/local/bin/doxygen  install/inc/CloudMade/doxygen.config 
cd $CURRENT_DIR/CloudMadeDoxygen && tar --create --verbose --file=html.tar html && gzip -f html.tar
cp $CURRENT_DIR/CloudMadeDoxygen/html.tar.gz $CC_BUILD_ARTIFACTS 

cp -r $CURRENT_DIR/CloudMadeDoxygen/html $CC_BUILD_ARTIFACTS

echo 'Generating docset ...'

appledoc -p "CloudMade iOS SDK" -i $CURRENT_DIR/install/inc/CloudMade -o $CURRENT_DIR/install/inc/CloudMade/Help --docset -c $CURRENT_DIR/install/inc/CloudMade/doxygen.config -t "/Users/user/Library/Application Support/appledoc"

mv $CURRENT_DIR/install/inc/CloudMade/Help/docset $CURRENT_DIR/install/inc/CloudMade/Help/CloudMade_iOS.docset
cp -r $CURRENT_DIR/install/inc/CloudMade/Help/CloudMade_iOS.docset $CC_BUILD_ARTIFACTS

appledoc -p "CloudMade iOS SDK" -i $CURRENT_DIR/install/inc/CloudMade -o $CURRENT_DIR/install/inc/CloudMade/Help --xhtml -c $CURRENT_DIR/install/inc/CloudMade/doxygen.config -t "/Users/user/Library/Application Support/appledoc"

mv $CURRENT_DIR/install/inc/CloudMade/Help/cxhtml $CURRENT_DIR/install/inc/CloudMade/Help/CloudMade_iOS
cp -r $CURRENT_DIR/install/inc/CloudMade/Help/CloudMade_iOS $CC_BUILD_ARTIFACTS

cd $CURRENT_DIR/install/inc/CloudMade/Help && tar --create --verbose --file=CloudMade_iOS.tar CloudMade_iOS && gzip -f CloudMade_iOS.tar
cp $CURRENT_DIR/install/inc/CloudMade/Help/CloudMade_iOS.tar.gz $CC_BUILD_ARTIFACTS

rm -rfd $CURRENT_DIR
