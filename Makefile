NO_COLOR=\x1b[0m
OK_COLOR=\x1b[32;01m
ERROR_COLOR=\x1b[31;01m
WARN_COLOR=\x1b[33;01m

PHP=php
PHP_NO_INI=php -n
PHPUNIT=vendor/bin/phpunit

all: check-reqs checks autoload test testdox cov

autoload:
	composer install

checks: phpstan phpcs

check-reqs:
	@echo "Verifying dev dependencies are installed ..."
	@test -f box.phar || { echo >&2 "Box is not installed locally"; exit 1; }
	@test -f phpcs.phar || { echo >&2 "PHP_CodeSniffer is not installed locally"; exit 2; }
	@test -f phpstan.phar || { echo >&2 "PHPStan is not installed locally"; exit 3; }
	@test -f phpmd.phar || { echo >&2 "PHP Mess Detector is not installed locally"; exit 4; }
	@echo Ok.

cov:
	@$(PHP) $(PHPUNIT) -c phpunit.xml.dist --coverage-text

feature:
	@$(PHP_NO_INI) $(PHPUNIT) -c phpunit.xml.dist  --testsuite=functional --testdox\
	 | sed 's/\[x\]/$(OK_COLOR)$\[x]$(NO_COLOR)/' \
	 | sed -r 's/(\[ \].+)/$(ERROR_COLOR)\1$(NO_COLOR)/' \
	 | sed -r 's/(^[^ ].+)/$(WARN_COLOR)\1$(NO_COLOR)/'

unit:
	$(PHP_NO_INI) $(PHPUNIT) -c phpunit.xml.dist --testsuite=unit

test: unit feature

testdox:
	@$(PHP_NO_INI) $(PHPUNIT) -c phpunit.xml.dist --testdox \
	 | sed 's/\[x\]/$(OK_COLOR)$\[x]$(NO_COLOR)/' \
	 | sed -r 's/(\[ \].+)/$(ERROR_COLOR)\1$(NO_COLOR)/' \
	 | sed -r 's/(^[^ ].+)/$(WARN_COLOR)\1$(NO_COLOR)/'

phar:
	@composer update --no-dev
	@$(PHP) box.phar build
	@chmod +x build/test-generator.phar
	@composer update

phpstan:
	@$(PHP_NO_INI) phpstan.phar analyse src tests --level=4 -c phpstan.neon

phpmd:
	@$(PHP_NO_INI) phpmd.phar

phpcs:
	@$(PHP_NO_INI) phpcs.phar --standard=PSR2 src tests

phpcbf:
	@$(PHP_NO_INI) phpcbf.phar --standard=PSR2 src tests

c: cov

d: testdox

s: style

t: test

f: feature