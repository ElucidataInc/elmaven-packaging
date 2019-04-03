function Component()
{
    console.log("initializing component")
    installer.setDefaultPageVisible(QInstaller.ReadyForInstallation, false) 
    installer.setDefaultPageVisible(QInstaller.StartMenuSelection, false)
    installer.addWizardPage(component, "PolicyPage", QInstaller.PerformInstallation)
    gui.pageByObjectName("DynamicPolicyPage").entered.connect(enteredPolicyPage)
}

Component.prototype.createOperationsForArchive = function(archive)
{
    console.log("performing custom extract operation")
    component.addOperation("Extract", archive, "@TargetDir@" + "/" + installer.value("version") + "/");
}

Component.prototype.createOperations = function()
{
    component.createOperations();
    component.addOperation("CreateShortcut","@TargetDir@" + "/" + installer.value("version") + "/bin/ElMaven.exe", 
            "@DesktopDir@/@version@.lnk");
    // if(systemInfo.productType === "windows") {
    //     component.addOperation("CreateShortcut","@TargetDir@" + "/" + installer.value("version") + "/bin/ElMaven.exe", 
    //         "@DesktopDir@/@version@.lnk");
    // }
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
