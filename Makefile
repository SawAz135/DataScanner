TARGET := iphone:clang:latest:14.0
ARCHS := arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := DataScanner

DataScanner_FILES := Sources/Tweak.xm Sources/ScannerCore.mm Sources/ScannerMenu.mm Sources/ScriptScanner.mm Sources/ExportManager.mm

DataScanner_CFLAGS := -fobjc-arc
DataScanner_CCFLAGS := -std=c++17
DataScanner_FRAMEWORKS := UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
