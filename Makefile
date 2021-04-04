prefix ?= /usr/local
libdir ?= ${prefix}/lib
libexecdir ?= ${prefix}/libexec

all:
	objfw-compile --arc -DLIBDIR='"${libdir}"'  -o laptopd LaptopD.m
	objfw-compile --arc --plugin -o asus ASUSPlugin.m

clean:
	rm -f laptopd *.o *.so

install: all
	install -m 755 laptopd ${libexecdir}/laptopd
	install -d ${libdir}/laptopd/asus
	install -m 755 asus.so ${libdir}/laptopd/asus/asus.so

uninstall:
	rm -f ${libexecdir}/laptopd
	rm -fr ${libdir}/laptopd
