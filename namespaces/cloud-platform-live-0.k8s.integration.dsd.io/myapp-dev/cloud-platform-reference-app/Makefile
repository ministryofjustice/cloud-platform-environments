build: all

cur-dir   := $(shell basename `pwd`)

all: codetest

test: codetest apptest

codetest:
	@echo "~> Checking codestyle"
	flake8 --ignore=F401 --count .

apptest:
	@echo "~> Running app tests"
	/usr/bin/env python3 manage.py test

prepare:
	# Following commands prepare developer environment adding appropriate githooks
	@echo "~> Preparing environment"
	# Please note that "@" supress output of commands.
	@/usr/bin/env pip3 install --upgrade -r requirements.txt
	# There are two ways to add githooks
	# 1.
	# @git config core.hooksPath .githooks
	# 2.
	# symlink based:
	@find .git/hooks -type l -exec rm {} \;
	@find .githooks -type f -exec ln -sf ../../{} .git/hooks/ \;
