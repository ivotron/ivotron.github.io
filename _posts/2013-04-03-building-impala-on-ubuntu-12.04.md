---
layout: post
title: Building Impala 0.6 on Ubuntu 12.04
---

# {{ page.title }}

This post complements the compilation notes contained in the [Impala's Github page][i-gh] (as of 
March/2013; version 0.6). They are intended to be applied on Ubuntu 12.04 LTS.

## Dependencies


```bash
sudo aptitude install \
     build-essential automake libtool flex bison \
     git subversion \
     libboost-test-dev libboost-program-options-dev libboost-filesystem-dev libboost-system-dev \
     libboost-regex-dev libboost-thread-dev \
     protobuf-compiler \
     libssl-dev \
     libbz2-dev \
     libevent1-dev \
     pkg-config \
     doxygen
```

### LLVM 3.2

The only difference between this and the build instructions at Github is the `--prefix` argument to 
`./configure`:

```bash
$> wget http://llvm.org/releases/3.2/llvm-3.2.src.tar.gz
$> tar xvzf llvm-3.2.src.tar.gz
$> cd llvm-3.2.src/tools
$> svn co http://llvm.org/svn/llvm-project/cfe/tags/RELEASE_32/final/ clang
$> cd ../projects
$> svn co http://llvm.org/svn/llvm-project/compiler-rt/tags/RELEASE_32/final/ compiler-rt
$> cd ..
$> ./configure --with-pic --prefix=$HOME/.opt/
$> make -j4 REQUIRES_RTTI=1
```

Add it to `.bashrc`:

```bash
PATH=$PATH:$HOME/.opt/bin/
```

### CMake

2.8.7 (the current version in 12.04) is too old and thus it can't find the JNI files correctly.
Installing 2.8.9 from [this PPA][cmakeppa] solves the issue.

### Java

Java 7 works as fine as 6 (OpenJDK-7 has an [issue][openjdk-issue]):

```bash
$> sudo add-apt-repository ppa:webupd8team/java
$> sudo apt-get update
$> sudo apt-get install oracle-java7-installer
```

Then make sure `JAVA_HOME` is set correctly (in my case this points to 
`/usr/lib/jvm/java-7-oracle/`).

### Maven

Instead of installing in `/usr/local`, I did in my `.opt/`:

```bash
$> cd $HOME/.opt/
$> wget http://archive.apache.org/dist/maven/binaries/apache-maven-3.0.4-bin.tar.gz
$> tar xvfz apach-maven-3.0.4-bin.tar.gz
$> rm apache-maven-3.0.4-bin.tar.gz
```

Then add the following to `.bashrc`:

```bash
$> export M2_HOME=$HOME/.opt/apache-maven-3.0.4
$> export M2=$M2_HOME/bin
$> export PATH=$M2:$PATH
```

## Building Impala

This is exactly as in [Impala's Github][i-gh].

[i-gh]: https://github.com/cloudera/impala
[cmakeppa]: https://launchpad.net/~kubuntu-ppa/+archive/backports
[openjdk-issue]: https://issues.apache.org/jira/browse/HDFS-4387
