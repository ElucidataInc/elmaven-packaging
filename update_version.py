import xml.etree.ElementTree as ET
import sys
from datetime import datetime

tree = ET.parse("config/config.xml")
root = tree.getroot()
version = sys.argv[1]
root.find("Version").text = version
tree.write("config/config.xml")

tree = ET.parse("packages/com.vendor.product/meta/package.xml")
root = tree.getroot()
now = datetime.now()
root.find("ReleaseDate").text = "{}-{:02d}-{:02d}".format(now.year, now.month, now.day)
root.find("DisplayName").text = "El-MAVEN " +  version
root.find("Description").text = "Install El-MAVEN " +  version
root.find("Version").text = version
tree.write("packages/com.vendor.product/meta/package.xml")
