#!/bin/bash

# install_zeromq
#
# Installs the specified version of ØMQ.
#
# Parameters:
#
#     1 - The version of ØMQ to install, in the form "vx.y.z"
install_zeromq() {
    local zeromq_version=$1
    case $zeromq_version in
    v2.2.0)
        wget http://download.zeromq.org/zeromq-2.2.0.tar.gz
        tar -xf zeromq-2.2.0.tar.gz
        cd ./zeromq-2.2.0
        ;;
    v3*)
        git clone https://github.com/zeromq/zeromq3-x
        cd ./zeromq3-x
        git checkout tags/$zeromq_version
        ;;
    v4*)
        git clone https://github.com/zeromq/zeromq4-x
        cd ./zeromq4-x
        git checkout tags/$zeromq_version
        ;;
    esac
    ./autogen.sh
    ./configure --prefix="${HOME}/zeromq-${zeromq_version}"
    make -j 8
    sudo make install
    cd ..
}

# install_zeromq_php_extension
#
# Installs the ØMQ PHP extension.
#
# Parameters: ~
build_zeromq_php_extension() {
	local zeromq_version=$1
    phpize
    ./configure --with-zmq="${HOME}/zeromq-${zeromq_version}"
    make
}

# run_zeromq_extension_tests
#
# Runs the ØMQ PHP extension tests and /returns the exit code/.
#
# Parameters: ~
run_zeromq_extension_tests() {
    export NO_INTERACTION=1
    export REPORT_EXIT_STATUS=1
    export TEST_PHP_EXECUTABLE=`which php`
    php run-tests.php -d extension=zmq.so -d extension_dir=modules -n ./tests/*.phpt
	exit_code=$?

    for i in `ls tests/*.out 2>/dev/null`; do echo "-- START ${i}"; cat $i; echo "-- END"; done
	return $exit_code
}

ZEROMQ_VERSION=$1
install_zeromq $ZEROMQ_VERSION
build_zeromq_php_extension $ZEROMQ_VERSION
run_zeromq_extension_tests
