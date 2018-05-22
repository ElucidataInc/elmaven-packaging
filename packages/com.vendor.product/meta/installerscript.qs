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
    // component.addOperation("Execute", "@TargetDir@" + "/" + installer.value("version") + "/bin/Docker.dmg");
    component.addElevatedOperation("Execute", "sudo", "chmod", "+x", "@TargetDir@" + "/" + installer.value("version") + "/bin/install_docker.sh");
    component.addElevatedOperation("Execute", "@TargetDir@" + "/" + installer.value("version") + "/bin/install_docker.sh", "@TargetDir@" + "/" + installer.value("version") + "/bin/Docker.dmg");

    component.addElevatedOperation("Execute", "sudo", "chmod", "+x", "@TargetDir@" + "/" + installer.value("version") + "/bin/install_xquartz.sh");

    component.addElevatedOperation("Execute", "@TargetDir@" + "/" + installer.value("version") + "/bin/install_xquartz.sh", "@TargetDir@" + "/" + installer.value("version") + "/bin/XQuartz-2.7.11.dmg");

    component.addElevatedOperation("Execute", "sudo", "chmod", "+x", "@TargetDir@" + "/" + installer.value("version") + "/bin/run_msconvert.sh");

    // component.addElevatedOperation("Execute", "open", "/Applications/Docker.app", "--args", "-AppCommandLineArg");
    // component.addOperation("Execute", "docker", "pull", "kushalgupta/msconvert:0.2");
}

Component.prototype.createOperations = function()
{

    component.createOperations();
    component.addOperation("CreateShortcut","@TargetDir@" + "/" + installer.value("version") + "/bin/ElMaven.exe",
            "@DesktopDir@/@version@.lnk");
    // component.addOperation("Execute", "brew", "install", "docker", "docker-compose", "docker-machine", "xhyve", "docker-machine-driver-xhyve");
    // component.addOperation("Execute", "sudo", "chown", "root:wheel", "$(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve");
    // component.addOperation("Execute", "sudo", "chmod", "u+s", "$(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve");
    // component.addOperation("Execute", "docker-machine", "create", "default", "--driver", "xhyve", "--xhyve-experimental-nfs-share");
    // component.addOperation("Execute", "eval", "$(docker-machine env default)");
    // if(systemInfo.productType === "windows") {
    //     component.addOperation("CreateShortcut","@TargetDir@" + "/" + installer.value("version") + "/bin/ElMaven.exe",
    //         "@DesktopDir@/@version@.lnk");
    // }
}
