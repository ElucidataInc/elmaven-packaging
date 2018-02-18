import xml.etree.ElementTree as ET
import sys


tree = ET.parse("config/config.xml")
root = tree.getroot()

version = sys.argv[1]


root.find("Version").text = version

tree.write("config/config.xml")


tree = ET.parse("packages/com.vendor.product/meta/package.xml")
root = tree.getroot()

root.find("DisplayName").text = "El-Maven " +  version
root.find("Description").text = "Install El-Maven " +  version
root.find("Version").text = version

tree.write("packages/com.vendor.product/meta/package.xml")