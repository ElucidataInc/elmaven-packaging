import xml.etree.ElementTree as ET
import sys
from datetime import datetime

tree = ET.parse("config/config.xml")
root = tree.getroot()
version = sys.argv[1]
update_branch = sys.argv[2]
root.find("Version").text = version
root.find("RemoteRepositories").find("Repository").find("Url").text = "https://elmaven-installers.s3-us-west-2.amazonaws.com/{}-updates".format(update_branch)
tree.write("config/config.xml")

tree = ET.parse("packages/com.vendor.product/meta/package.xml")
root = tree.getroot()
now = datetime.now()
root.find("ReleaseDate").text = "{}-{:02d}-{:02d}".format(now.year, now.month, now.day)
root.find("DisplayName").text = "El-MAVEN"
root.find("Description").text = "Install El-MAVEN " +  version
root.find("Version").text = version
tree.write("packages/com.vendor.product/meta/package.xml")
