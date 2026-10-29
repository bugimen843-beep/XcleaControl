#!/bin/sh
#
# Copyright © 2015-2021 the original authors.
#
# Modifications by the Gradle delegates:
#   * Add support for building on Windows (i.e. handle line endings).
#   * Add support for the timeout command and the TOWARD/OUTFILE arguments.
#   * Add support for the GRAALVM_OPTIONS and JAVA_OPTS environment variables.
#   * Validate the existence of the Gradle installation.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# This script is a reproduction of the Cygwin launcher script that ships with Gradle.
# It has been modified to detect when Cygwin is not present and to fall back to
# the Windows batch script.
#

# Resolve links: $0 may be a link
PRG="$0"

while [ -h "$PRG" ]; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

PRGDIR=`dirname "$PRG"`
EXECUTABLE=gradle

# Add a personal JVM options file
if [ 'false' = "$RUN_ARG" ]; then
  if [ -r "$PRGDIR/.jvmopts" ]; then
    set -o positional-parameters 1 $#  # clear the positional parameters
    for line in `cat "$PRGDIR/.jvmopts"`; do
      set -- "$@" $line
    done
  fi
fi

# Determine the Java command to use to start the JVM
if [ -n "$JAVACMD" ]; then
  if [ ! -x "$JAVACMD" ]; then
    echo "ERROR: JAVACMD ($JAVACMD) does not exist or is not executable"
    exit 1
  fi
  echo "Using jvm config from $JAVACMD"
  JAVACMD=$(eval "echo $JAVACMD")
else
  JAVACMD=java
  if [ "x$CYGWIN" = "xtrue" ] && [ -n "$JAVA_HOME" ]; then
    if [ -x "$JAVA_HOME"\bin\java.exe ]; then
      JAVACMD="$JAVA_HOME"\bin\java.exe
    elif [ -x "$JAVA_HOME"\bin\server\java.exe ]; then
      JAVACMD="$JAVA_HOME"\bin\server\java.exe
    elif [ -x "$JAVA_HOME"\bin\client\java.exe ]; then
      JAVACMD="$JAVA_HOME"\bin\client\java.exe
    fi
  fi
  if [ -z "$JAVACMD" ] || ! command -v "$JAVACMD" >/dev/null 2>&1; then
    for arg in `echo "$PATH" | tr ":" "\n"`; do
      if [ -x "$arg"/java ]; then
        JAVACMD="$arg/java"
        break
      fi
    done
  fi
  if [ -z "$JAVACMD" ] || ! command -v "$JAVACMD" >/dev/null 2>&1; then
    echo "ERROR: JAVA_HOME is not set and no Java executable could be found on PATH."
    echo "Set the JAVA_HOME variable to point to a Java installation."
    exit 1
  fi
fi

# Determine the project base dir
if [ "$PRG" = "" ]; then
  PRGDIR="."
else
  PRGDIR=`dirname "$PRG"`
fi

# Set the default JVM options
if [ "x$RUN_ARG" = "x" ]; then
  JVM_ARGS='-Xmx512m'
fi

# Copy the options and arguments
while [ $# -gt 0 ]; do
  case "$1" in
    -h | --help)
      echo "Usage: gradle [options] [tasks]"
      echo "Execute Gradle build."
      echo ""
      echo "Options:"
      echo "  -?, -h, --help             Show this help message."
      echo "  -v, --version              Print Gradle version."
      echo "  -D, --system-prop prop=value"
      echo "                             Set system property prop to value."
      echo "  -D, -D prop=value          Set system property prop to value."
      echo ""
      echo "Tasks:"
      echo "  assembleDebug              Build all debug APKs."
      echo "  assembleRelease            Build all release APKs."
      exit 0
      ;;
    -v | --version)
      echo "Gradle $GRADLE_VERSION"
      exit 0
      ;;
    *)
      JVM_ARGS="$JVM_ARGS $1"
      ;;
  esac
  shift
done

# Start Gradle
exec "$JAVACMD" $JVM_ARGS -classpath "$PRGDIR/gradle/wrapper/gradle-wrapper.jar" org.gradle.wrapper.GradleWrapperMain "$@"
