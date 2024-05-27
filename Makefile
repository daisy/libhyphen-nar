MVN := mvn
COMPOSE := docker compose
VERSION := $(shell xmllint --xpath "/*/*[local-name()='version']/text()" pom.xml)

TARGET_NAR_LINUX_32 := $(addprefix target/nar/hyphen-$(VERSION)-i386-Linux-gpp-,executable shared)
TARGET_NAR_LINUX_64 := $(addprefix target/nar/hyphen-$(VERSION)-amd64-Linux-gpp-,executable shared)
TARGET_NAR_MAC_32   := $(addprefix target/nar/hyphen-$(VERSION)-i386-MacOSX-gpp-,executable shared)
TARGET_NAR_MAC_64   := $(addprefix target/nar/hyphen-$(VERSION)-x86_64-MacOSX-gpp-,executable shared)
TARGET_NAR_WIN_32   := $(addprefix target/nar/hyphen-$(VERSION)-i586-mingw32msvc-gpp-,executable shared)
TARGET_NAR_WIN_64   := $(addprefix target/nar/hyphen-$(VERSION)-x86_64-w64-mingw32-gpp-,executable shared)

all : compile-linux compile-macosx compile-windows

clean :
	$(MVN) clean

compile-linux : $(TARGET_NAR_LINUX_32) $(TARGET_NAR_LINUX_64)
compile-macosx : $(TARGET_NAR_MAC_64)
compile-windows : $(TARGET_NAR_WIN_32) $(TARGET_NAR_WIN_64)

$(TARGET_NAR_LINUX_32) :
	$(COMPOSE) run debian mvn test -Dos.arch=i386

$(TARGET_NAR_LINUX_64) :
	$(COMPOSE) run debian mvn test

$(TARGET_NAR_MAC_32) :
	[[ "$$(uname)" == Darwin ]]
	$(MVN) test -Dos.arch=i386

$(TARGET_NAR_MAC_64) :
	[[ "$$(uname)" == Darwin && "$$(uname -m)" == x86_64 ]]
	$(MVN) test

$(TARGET_NAR_WIN_32) :
	$(COMPOSE) run debian mvn test -Pcross-compile -Dhost.os=w64-mingw32 -Dos.arch=i686

$(TARGET_NAR_WIN_64) :
	$(COMPOSE) run debian mvn test -Pcross-compile -Dhost.os=w64-mingw32 -Dos.arch=x86_64

snapshot :
	[[ $(VERSION) == *-SNAPSHOT ]]
	$(MVN) nar:nar-package install:install deploy:deploy

release :
	[[ $(VERSION) != *-SNAPSHOT ]]
	$(MVN) nar:nar-package jar:jar gpg:sign install:install deploy:deploy -Psonatype-deploy
