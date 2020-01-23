function Component()
{
    console.log("initializing component")
    if (installer.isInstaller())
        installer.setValue("AllUsers", true);

    installer.setDefaultPageVisible(QInstaller.ReadyForInstallation, false) 
    installer.setDefaultPageVisible(QInstaller.StartMenuSelection, false)
    installer.addWizardPage(component, "PolicyPage", QInstaller.PerformInstallation)
    gui.pageByObjectName("DynamicPolicyPage").entered.connect(enteredPolicyPage)
}

Component.prototype.createOperationsForArchive = function(archive)
{
    console.log("performing custom extract operation")
    component.addOperation("Extract", archive, "@TargetDir@" + "/" + installer.value("application") + "/");
}

Component.prototype.createOperations = function()
{
    component.createOperations();
    if(systemInfo.productType === "windows") {
        component.addOperation("CreateShortcut",
                               "@TargetDir@" + "/" + installer.value("application") + "/bin/El-MAVEN.exe",
                               "@DesktopDir@/El-MAVEN.lnk",
                               "description=El-MAVEN");
        component.addElevatedOperation("GlobalConfig",
                                       "Elucidata",
                                       installer.value("application") + " " + installer.value("version"),
                                       "InstallDir",
                                       "@TargetDir@");
        component.addElevatedOperation("GlobalConfig",
                                       "Elucidata",
                                       installer.value("application") + " " + installer.value("version"),
                                       "BinaryDir",
                                       "@TargetDir@" + "\\" + installer.value("application") + "\\bin");
    }
}

enteredPolicyPage = function()
{
    console.log("entered policy page")
    var page = gui.currentPageWidget().PolicyPage;
    page.acceptButton.toggled.connect(policyAccepted);
    page.rejectButton.toggled.connect(policyRejected);
    page.rejectButton.setChecked(true)
}

policyAccepted = function()
{
    var wizard = gui.currentPageWidget();
    wizard.complete = true
}

policyRejected = function()
{
    var wizard = gui.currentPageWidget();
    wizard.complete = false
}
