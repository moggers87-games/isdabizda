SOURCE := $(shell find isdabizda -type f)
VERSION := $(shell cat .version || git describe --long --dirty || echo 0)
UNAME := $(shell uname)

CFLAGS = -O3
LIBFLAGS =
LIBOPENGL = -lGL

ifeq ($(UNAME),Darwin)
# taken from hashlink's Makefile
CFLAGS += -I /usr/local/include -I /usr/local/opt/libjpeg-turbo/include -I /usr/local/opt/jpeg-turbo/include -I /usr/local/opt/sdl2/include/SDL2 -I /usr/local/opt/libvorbis/include -I /usr/local/opt/openal-soft/include -Dopenal_soft
LIBFLAGS += -L/usr/local/opt/libjpeg-turbo/lib -L/usr/local/opt/jpeg-turbo/lib -L/usr/local/lib -L/usr/local/opt/libvorbis/lib -L/usr/local/opt/openal-soft/lib
LIBOPENGL = -framework OpenGL
endif

.PHONY: all
all: export/js export/hl export/native

.PHONY: release
release: all export/source

.PHONY: clean
clean:
	rm -rf export

.PHONY: lint
lint: .haxelib
	haxelib install checkstyle
	haxelib run checkstyle -s isdabizda --exitcode

.haxelib:
	haxelib newrepo

.installed-deps-haxe-js: js.hxml compile.hxml .haxelib
	haxelib install js.hxml --always
	touch $@

.installed-deps-haxe-hl: hl.hxml hashlink.hxml compile.hxml .haxelib
	haxelib install hl.hxml --always
	touch $@

.installed-deps-haxe-native: native.hxml hashlink.hxml compile.hxml .haxelib
	haxelib install native.hxml --always
	touch $@

export/hl/isdabizda.hl: $(SOURCE) .installed-deps-haxe-hl
	mkdir -p $(@D)
	haxe hl.hxml

export/hl: export/hl/isdabizda.hl
	cp /usr/local/lib/fmt.hdll $@
	cp /usr/local/lib/openal.hdll $@
	cp /usr/local/lib/sdl.hdll $@
	cp /usr/local/lib/ui.hdll $@

export/native/src/isdabizda.c: $(SOURCE) .installed-deps-haxe-native
	mkdir -p $(@D)
	haxe native.hxml
	touch $@

export/native/isdabizda: export/native/src/isdabizda.c
	gcc $(CFLAGS) -o $@ -std=c11 -I$(@D)/src $(@D)/src/isdabizda.c /usr/local/lib/sdl.hdll /usr/local/lib/ui.hdll /usr/local/lib/fmt.hdll /usr/local/lib/openal.hdll /usr/local/lib/ui.hdll $(LIBFLAGS) -lhl -lSDL2 -lm -lopenal $(LIBOPENGL)

export/native: export/native/isdabizda

export/js/isdabizda.js: $(SOURCE) .installed-deps-haxe-js
	mkdir -p $(@D)
	haxe js.hxml

export/js/index.html: isdabizda/data/index.html
	mkdir -p $(@D)
	cp isdabizda/data/index.html $@

export/js: export/js/isdabizda.js export/js/index.html
	rm -f $@/*.zip
	zip -j $@/isdabizda-$(VERSION).zip $@/*
	cp $@/isdabizda-$(VERSION).zip $@/isdabizda-game.zip
	date -Iseconds

export/source: $(SOURCE)
	rm -f $@/*.zip
	mkdir -p $@
	echo $(VERSION) > .version
	git archive --output=export/source/isdabizda-source-$(VERSION).zip --prefix=isdabizda/ --format=zip --add-file=.version HEAD
	rm .version
	date -Iseconds

.PHONY: test-js
test-js: export/js
	python -m http.server --directory export/js

.PHONY: test-hl
test-hl: export/hl
	cd export/hl; hl isdabizda.hl

.PHONY: test-native
test-native: export/native
	cd export/native; ./isdabizda
