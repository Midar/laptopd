prefix ?= /usr/local
libdir ?= ${prefix}/lib
libexecdir ?= ${prefix}/libexec

all:
	objfw-compile --arc -DLIBDIR='"${libdir}"'  -o laptopd LaptopD.m
	objfw-compile --arc --plugin -o asus_linux ASUSLinuxPlugin.m
	objfw-compile --arc --plugin -o linux_battery LinuxBatteryPlugin.m

clean:
	rm -f laptopd *.o *.so

install: all
	install -m 755 laptopd ${libexecdir}/laptopd
	for i in asus_linux linux_battery; do \
		install -d ${libdir}/laptopd/$$i; \
		install -m 755 $$i.so ${libdir}/laptopd/$$i/$$i.so; \
	done

uninstall:
	rm -f ${libexecdir}/laptopd
	rm -fr ${libdir}/laptopd
