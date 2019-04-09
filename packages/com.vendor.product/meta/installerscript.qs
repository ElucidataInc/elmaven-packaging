function Component()
{
    console.log("initializing component")
    installer.setDefaultPageVisible(QInstaller.ReadyForInstallation, false) 
    installer.setDefaultPageVisible(QInstaller.StartMenuSelection, false)
}

Component.prototype.createOperationsForArchive = function(archive)
{
    console.log("performing custom extract operation")
    component.addOperation("Extract", archive, "@TargetDir@" + "/" + installer.value("version") + "/");
}

Component.prototype.createOperations = function()
{
    component.createOperations();
    if(systemInfo.productType === "windows") {
        component.addOperation("CreateShortcut",
                               "@TargetDir@" + "/" + installer.value("version") + "/bin/El-MAVEN.exe",
                               "@DesktopDir@/El-MAVEN.lnk",
                               "description=El-MAVEN");
     }
}

