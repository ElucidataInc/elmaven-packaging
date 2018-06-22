#!/bin/bash

version=''
num_version=''

read -p "enter the branch name/version : " version

read -p "enter the version number : " num_version

# TODO: use a regex instead
if [ $version == '' ]; then
	exit -1
fi;

if [ $num_version == '' ]; then 
	exit -1;
fi;


OS=$(uname)
PARENT_DIR=$PWD
BREAKPAD_TOOLS=$PWD/breakpad_tools/
MAVEN_DIR="$PARENT_DIR/maven_repo/"
MAVEN_SRC="$PARENT_DIR/maven_repo/ElMaven/"
MAVEN_BIN="$PARENT_DIR/maven_repo/ElMaven/bin/"
BIN="$PARENT_DIR/bin/"
MAVEN_REPO="https://github.com/ElucidataInc/ElMaven.git"
NODE_MAC="$PARENT_DIR/node_mac/"
NODE_WIN="$PARENT_DIR/node_win/"
ARCHIVE_FILE="maven.7z"
CONIFG="$PWD/config/"
PACKAGE_DATA="$PWD/packages/com.vendor.product/data/"
PACKAGE_META="$PWD/packages/com.vendor.product/meta/"
INSTALLER="El-Maven-$version"
success=$'\xe2\x9c\x93\0a'
failed=$'\xe2\x9c\x97\0a'
ERROR_MSG=''

clone()
{
	if [ ! -d $MAVEN_DIR ]; then
		mkdir $MAVEN_DIR
	fi;

	cd $MAVEN_DIR
	# will not clone if the repo is already present
	git clone --quiet $MAVEN_REPO &>/dev/null

}

compile()
{
	# the source repo does not exist. This might happen if cloning
	# of repo failed
	if [ ! -d $MAVEN_SRC ]; then
		return -1
	fi;

	cd $MAVEN_SRC

	git checkout develop &>/dev/null
	if [ $? != 0 ]; then
		ERROR_MSG='checkout to develop failed. Make sure your working dir/staging area is clean'
		return -1;
	fi;

	git pull &>/dev/null
	if [ $? != 0 ]; then
		ERROR_MSG='git pull failed.'
		return -1;
	fi;

	git checkout $version &>/dev/null
	if [ $? != 0 ]; then
		ERROR_MSG='git checkout failed. Make sure the the branch/version $version exists'
		return -1;
	fi;


	./uninstall.sh &>/dev/null

	find . -name "Makefile" -delete

	qmake CONFIG+=debug &>/dev/null
	if [ $? != 0 ]; then
		ERROR_MSG='qmake failed. Make sure it is in system path'
		return -1
	fi;

	echo "building ......."
	make --silent -j4 &>/dev/null
	if [ $? != 0 ]; then
		ERROR_MSG="make failed"
		return -1
	fi;

	return 0
}

collect_runtime_plugins()
{
	cd $PARENT_DIR

	if [ ! -d $BIN ]; then
		mkdir $BIN
	fi;

	cd $BIN
	rm -rf *
	cp -r $MAVEN_BIN* .
	

	if [ $OS == "Darwin" ]; then


		macdeployqt El_Maven* peakdetector* CrashReporter* MavenTests* &>/dev/null

		if [ $? != 0 ]; then 
			return -1
		fi; 

	else
		libs=$(ldd El_Maven*)
		if [ $? != 0 ]; then
			return -1
		fi;

		while read -r line; do
    		lib=$(echo $line | sed -n 's/.*=>\s*\(.*dll\).*/\1/p')
    		if [[ $lib == *"bin"* ]]; then
        		cp $lib $BIN
    		fi;
		done <<< "$libs"


		mv El_Maven* ElMaven.exe

		windeployqt.exe --no-translations ElMaven.exe &>/dev/null
		if [ $? != 0 ]; then 
			return -1
		fi;

		#generate qt.conf
		touch qt.conf
		echo "[Paths]\nPrefix = .\n" > qt.conf

	fi;

	return 0
}


strip_upload_symbols()
{
	cd $BIN
	$BREAKPAD_TOOLS/windows/strip_symbols.sh $BREAKPAD_TOOLS ElMaven.exe ElMaven
	rm .*pdb
	rm -r symbols


}

copy_node()
{
	if [ $OS == "Darwin" ]; then
		cp -r $NODE_MAC $BIN

	else
		cp -r $NODE_WIN/* $BIN

	fi;

	return 0
}

generate_archive()
{
	cd $PARENT_DIR

	if [ -f $ARCHIVE_FILE ]; then
		rm $ARCHIVE_FILE
	fi;


	if [ -f $PACKAGE_DATA/$ARCHIVE_FILE ]; then
		rm $PACKAGE_DATA/$ARCHIVE_FILE
	fi;


	if [ $OS == "Darwin" ]; then
		archivegen $ARCHIVE_FILE $BIN &>/dev/null
		if [ $? != 0 ]; then
			ERROR_MSG="Make sure archivegen is in system path"
			return -1
		fi;
	else
		archivegen.exe $ARCHIVE_FILE $BIN &>/dev/null
		if [ $? != 0 ]; then
			return -1
		fi;
	fi;

	cp $ARCHIVE_FILE $PACKAGE_DATA

	return 0
}


update_version()
{

	cd $PARENT_DIR

	python update_version.py $num_version
	if [ $? != 0 ]; then 
		return -1;
	fi;

}

create_installer()
{
	cd $PARENT_DIR

	if [ $OS == "Darwin" ]; then
		binarycreator --ignore-translations -c config/config.xml -p packages/ $INSTALLER &>/dev/null
		if [ $? != 0 ]; then
			ERROR_MSG="Make sure binarycreator is in system path"
			return -1
		fi;
	else
		binarycreator -c config/config.xml -p packages/ $INSTALLER &>/dev/null
		if [ $? != 0 ]; then
			ERROR_MSG="Make sure binarycreator is in system path"			
			return -1
		fi;
	fi;

	return 0

}

clone

compile
if [ $? != 0 ]; then
	echo "build $failed "
	echo "Log: $ERROR_MSG"
	exit -1
else
	echo "build $success"
fi;

collect_runtime_plugins
if [ $? != 0 ]; then
	echo "collecting plugins $failed"
	exit -1
else
	echo "collecting plugins $success"
fi;


copy_node
if [ $? != 0 ]; then
	echo "copying node $failed"
	exit -1
else
	echo "copying node $success"
fi;

generate_archive
if [ $? != 0 ]; then
	echo "generating the archive $failed"
	exit -1
else
	echo "generating the archive $success"
fi;

update_version
if [ $? != 0 ]; then
	echo "updating the version $failed"
	exit -1
else
	echo "updating the version $success"
fi;

create_installer
if [ $? != 0 ]; then
	echo "creating the installer $failed"
	exit -1
else
	echo "creating the installer $success"
fi;

