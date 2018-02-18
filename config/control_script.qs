function Controller()
{
	console.log("intializing controller")
	if(installer.isInstaller()) {
		installer.setValue("version", "@Name@-@Version@")
	}

}


Controller.prototype.IntroductionPageCallback = function()
{
}

Controller.prototype.TargetDirectoryPageCallback = function()
{

}