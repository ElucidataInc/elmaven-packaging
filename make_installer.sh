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

WINDOWS=0
MAC=0
UNKNOWN_OS=0
OS=$(echo $OSTYPE | tr '[:upper:]' '[:lower:]')
if  [[ $OS == *"msys"* ]]; then
	WINDOWS=1

elif [[  $OS == *"darwin"* ]]; then
	MAC=1

else
	UNKOWN_OS=1

fi;


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

	qmake CONFIG+=release CONFIG+=force_debug_info NOTESTS=yes &>/dev/null
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
	rsync -av $MAVEN_BIN . --exclude "linux"

	if [ $MAC -eq 1 ]; then

        #prepare dSYM file
		bin_path=$(find . -name "El_Maven*" -maxdepth 1 -print | ggrep -o "El_Maven.*")
		bin_name=$(echo $bin_path | ggrep -o -P ".*(?=.app)")
        dsymutil "$bin_path/Contents/MacOS/$bin_name" -o "$bin_name.dSYM" 
		macdeployqt El_Maven* &>/dev/null
		macdeployqt peakdetector* &>/dev/null
		macdeployqt CrashReporter* &>/dev/null
		macdeployqt MavenTests* &>/dev/null

		if [ $? != 0 ]; then 
			return -1
		fi;
	fi;

	if [ $WINDOWS -eq 1 ]; then

		libs=$(ldd El_Maven* peakdetector.exe)
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


                # since Qt5.9.7, windeployqt has stopped working. Going to use some copy paste magic instead
                # to get all the extra plugins required.

                qt_plugins_path=$(qmake -query QT_INSTALL_PLUGINS)
                echo $qt_plugins_path

                cp -r "$qt_plugins_path/platforms" .
                cp -r "$qt_plugins_path/imageformats" .
                cp -r "$qt_plugins_path/printsupport" .
                cp -r "$qt_plugins_path/sqldrivers" .
                cp -r "$qt_plugins_path/bearer" .
                #windeployqt.exe --no-translations ElMaven.exe &>/dev/null
                #if [ $? != 0 ]; then
                #	return -1
                #fi;

		#generate qt.conf
		touch qt.conf
		echo "[Paths]\nPrefix = .\n" > qt.conf

	fi;

	return 0
}


strip_upload_symbols()
{
	cd $BIN
	echo "stripping symbols"

	if [ $WINDOWS -eq 1 ]; then
		$BREAKPAD_TOOLS/windows/strip_symbols.sh $BREAKPAD_TOOLS ElMaven.exe ElMaven
		rm ElMaven.pdb
		rm -r symbols
	fi;

	if [ $MAC -eq 1 ]; then
		bin_path=$(find . -name "El_Maven*.app" -maxdepth 1 -print | ggrep -o "El_Maven.*")
		echo "binary path : $bin_path"
		bin_name=$(echo $bin_path | ggrep -o -P ".*(?=.app)")
		$BREAKPAD_TOOLS/mac/strip_symbols.sh $BREAKPAD_TOOLS "$bin_path/Contents/MacOS/$bin_name" $bin_name
	fi;
}


copy_node()
{
	if [ $MAC -eq 1 ]; then
		cp -r $NODE_MAC $BIN
	fi;

	if [ $WINDOWS -eq 1 ]; then
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


	if [ $MAC -eq 1 ]; then
		archivegen $ARCHIVE_FILE $BIN &>/dev/null
		if [ $? != 0 ]; then
			ERROR_MSG="Make sure archivegen is in system path"
			return -1
		fi;
	fi;

	if [ $WINDOWS -eq 1 ]; then
		archivegen.exe $ARCHIVE_FILE $BIN &>/dev/null
		if [ $? != 0 ]; then
			return -1
		fi;
	fi;

	mkdir $PACKAGE_DATA
	cp $ARCHIVE_FILE $PACKAGE_DATA

	return 0
}


update_version()
{

	cd $PARENT_DIR

	if [ $MAC -eq 1 ]; then 
		python update_version.py $num_version
	fi;

	if [ $WINDOWS -eq 1 ]; then

		if hash python.exe 2>/dev/null; then
			python.exe update_version.py $num_version

		elif hash python2.7.exe 2>/dev/null; then
			python2.7.exe update_version.py $num_version

		elif hash python3.6.exe 2>/dev/null; then
			python3.6.exe update_version.py $num_version

		else
			echo "could not find python"
			return -1;
		fi;


	fi;

	if [ $? != 0 ]; then
	       return -1;
	fi;

	return 0;

}

create_installer()
{
	cd $PARENT_DIR

	if [ $MAC -eq 1 ]; then
		binarycreator --ignore-translations -c config/config.xml -p packages/ $INSTALLER &>/dev/null
		if [ $? != 0 ]; then
			ERROR_MSG="Make sure binarycreator is in system path"
			return -1
		fi;
	fi;

	if [ $WINDOWS -eq 1 ]; then 
		binarycreator -c config/config.xml -p packages/ $INSTALLER &>/dev/null
		if [ $? != 0 ]; then
			ERROR_MSG="Make sure binarycreator is in system path"			
			return -1
		fi;
	fi;

	return 0

}

codesign_installer()
{
	cd $PARENT_DIR

	if [ $MAC -eq 1 ]; then
		codesign -s "Elucidata Corporation" $INSTALLER.app &> /dev/null
		if [ $? != 0 ]; then
			ERROR_MSG="Make sure that the certificate name is correct"
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


strip_upload_symbols

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

codesign_installer
if [ $? != 0 ]; then
	echo "codesigning the installer $failed"
	exit -1
else
	echo "codesigning the installer $success"
fi;
