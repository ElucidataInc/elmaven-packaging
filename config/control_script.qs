function Controller()
{
    console.log("intializing controller")
    if(installer.isInstaller()) {
        installer.setValue("application", "@Name@")
        installer.setValue("version", "@Version@")
    }
}

Controller.prototype.IntroductionPageCallback = function()
{
}

Controller.prototype.TargetDirectoryPageCallback = function()
{
}

Controller.prototype.DynamicPolicyPageCallback = function()
{
    console.log("creating privacy policy page")
    var page = gui.pageByObjectName("DynamicPolicyPage")
    var policyTxt = installer.readFile(":/metadata/config/privacypolicy.html", "UTF-8")
    page.PolicyPage.textBox.setText(policyTxt)
    page.complete = false
}
