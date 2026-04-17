# vi:filetype=make:syntax=make:
.RECIPEPREFIX := $() $()

APP_SYSTEM = cl-bookmark-tool
BINARY_NAME = cl-bookmark-tool

DEP_URL = git@github.com:ediw8311xht/maximilian-utils.git
DEP_DIR = libs/maximilian-utils

.PHONY: all deps build clean clean-deps

all: deps build

deps:
 @mkdir -p libs
 @if [ ! -d "$(DEP_DIR)" ] ; then \
  echo "Make: Cloning dependency..."; \
  git clone $(DEP_URL) $(DEP_DIR); \
 else \
  echo "Make: Updating dependency..."; \
  cd "$(DEP_DIR)" && git pull; \
  cd -; \
 fi

build:
 @echo "Building binary..."
 sbcl \
  --load ~/quicklisp/setup.lisp \
  --eval '(require :asdf)' \
  --eval '(push (truename ".") asdf:*central-registry*)' \
  --eval '(push (truename "$(DEP_DIR)/") asdf:*central-registry*)' \
  --eval '(ql:quickload :$(APP_SYSTEM))' \
  --eval '(asdf:make :$(APP_SYSTEM))'

clean:
 rm -f $(BINARY_NAME)

clean-deps:
 rm -rf $(DEP_DIR)

