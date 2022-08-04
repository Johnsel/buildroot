################################################################################
#
# libiio
#
################################################################################


LIBIIO_VERSION = 0.24
LIBIIO_SITE = $(call github,analogdevicesinc,libiio,v$(LIBIIO_VERSION))

#LIBIIO_VERSION = 60de6b948a04d4074d2feca46dbb64dca92ae60d
#LIBIIO_SITE = https://github.com/analogdevicesinc/libiio.git
#LIBIIO_SITE_METHOD = git

LIBIIO_INSTALL_STAGING = YES
LIBIIO_LICENSE = LGPL-2.1+
LIBIIO_LICENSE_FILES = COPYING.txt

LIBIIO_CONF_OPTS = -DENABLE_IPV6=ON \
	-DWITH_LOCAL_BACKEND=$(if $(BR2_PACKAGE_LIBIIO_LOCAL_BACKEND),ON,OFF) \
	-DWITH_LOCAL_CONFIG=$(if $(BR2_PACKAGE_LIBIIO_LOCAL_CONFIG),ON,OFF) \
	-DWITH_NETWORK_BACKEND=$(if $(BR2_PACKAGE_LIBIIO_NETWORK_BACKEND),ON,OFF) \
	-DINSTALL_UDEV_RULE=$(if $(BR2_PACKAGE_HAS_UDEV),ON,OFF) \
	-DWITH_TESTS=$(if $(BR2_PACKAGE_LIBIIO_TESTS),ON,OFF) \
	-DWITH_DOC=OFF

ifeq ($(BR2_TOOLCHAIN_HAS_THREADS),y)
LIBIIO_CONF_OPTS += -DNO_THREADS=OFF
else
LIBIIO_CONF_OPTS += -DNO_THREADS=ON
endif

ifeq ($(BR2_PACKAGE_LIBIIO_XML_BACKEND),y)
LIBIIO_DEPENDENCIES += libxml2 zstd
LIBIIO_CONF_OPTS += -DWITH_XML_BACKEND=ON
else
LIBIIO_CONF_OPTS += -DWITH_XML_BACKEND=OFF
endif

ifeq ($(BR2_PACKAGE_LIBIIO_USB_BACKEND),y)
LIBIIO_DEPENDENCIES += libusb
LIBIIO_CONF_OPTS += -DWITH_USB_BACKEND=ON
else
LIBIIO_CONF_OPTS += -DWITH_USB_BACKEND=OFF
endif

ifeq ($(BR2_PACKAGE_LIBIIO_SERIAL_BACKEND),y)
LIBIIO_DEPENDENCIES += libserialport
LIBIIO_CONF_OPTS += -DWITH_SERIAL_BACKEND=ON
else
LIBIIO_CONF_OPTS += -DWITH_SERIAL_BACKEND=OFF
endif

ifeq ($(BR2_PACKAGE_LIBIIO_HWMON_SUPPORT),y)
LIBIIO_CONF_OPTS += -DWITH_HWMON=ON
else
LIBIIO_CONF_OPTS += -DWITH_HWMON=OFF
endif

ifeq ($(BR2_PACKAGE_LIBIIO_IIOD),y)
LIBIIO_DEPENDENCIES += host-flex host-bison libaio
LIBIIO_CONF_OPTS += -DWITH_IIOD=ON -DWITH_AIO=ON
else
LIBIIO_CONF_OPTS += -DWITH_IIOD=OFF
endif

ifeq ($(BR2_PACKAGE_LIBIIO_IIOD_USBD),y)
LIBIIO_DEPENDENCIES += libaio
LIBIIO_CONF_OPTS += -DWITH_IIOD_USBD=ON
else
LIBIIO_CONF_OPTS += -DWITH_IIOD_USBD=OFF
endif

ifeq ($(BR2_PACKAGE_LIBAIO),y)
LIBIIO_DEPENDENCIES += libaio
LIBIIO_CONF_OPTS += -DWITH_AIO=ON
else
LIBIIO_CONF_OPTS += -DWITH_AIO=OFF
endif

ifeq ($(BR2_PACKAGE_AVAHI_LIBAVAHI_CLIENT),y)
LIBIIO_DEPENDENCIES += avahi
LIBIIO_CONF_OPTS += -DHAVE_DNS_SD=ON
else
LIBIIO_CONF_OPTS += -DHAVE_DNS_SD=OFF
endif

ifeq ($(BR2_PACKAGE_LIBIIO_BINDINGS_PYTHON),y)
LIBIIO_DEPENDENCIES += host-python-setuptools python3
LIBIIO_CONF_OPTS += \
	-DPYTHON_BINDINGS=ON \
	-DPYTHON_EXECUTABLE=$(HOST_DIR)/bin/python3
else
LIBIIO_CONF_OPTS += -DPYTHON_BINDINGS=OFF
endif

ifeq ($(BR2_PACKAGE_LIBIIO_BINDINGS_CSHARP),y)
define LIBIIO_INSTALL_CSHARP_BINDINGS_TO_TARGET
	$(HOST_DIR)/bin/gacutil -root $(TARGET_DIR)/usr/lib -i \
		$(TARGET_DIR)/usr/lib/cli/libiio-sharp-$(LIBIIO_VERSION)/libiio-sharp.dll
endef
define LIBIIO_INSTALL_CSHARP_BINDINGS_TO_STAGING
	$(HOST_DIR)/bin/gacutil -root $(STAGING_DIR)/usr/lib -i \
		$(STAGING_DIR)/usr/lib/cli/libiio-sharp-$(LIBIIO_VERSION)/libiio-sharp.dll
endef
LIBIIO_POST_INSTALL_TARGET_HOOKS += LIBIIO_INSTALL_CSHARP_BINDINGS_TO_TARGET
LIBIIO_POST_INSTALL_STAGING_HOOKS += LIBIIO_INSTALL_CSHARP_BINDINGS_TO_STAGING
LIBIIO_DEPENDENCIES += mono
LIBIIO_CONF_OPTS += -DCSHARP_BINDINGS=ON
else
LIBIIO_CONF_OPTS += -DCSHARP_BINDINGS=OFF
endif

ifeq ($(BR2_PACKAGE_LIBIIO_IIOD),y)
define LIBIIO_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 package/libiio/S99iiod \
		$(TARGET_DIR)/etc/init.d/S99iiod
endef
endif

$(eval $(cmake-package))
