# Docker images for HPE Vertica

Docker images collection for the HPE Vertica database.
HPE Vertica Analytics Platform from Hewlett Packard Enterprise is a column-oriented, relational database system built specifically to handle modern analytic workloads.
It's available with both a free community licence (up to 1 TB and 3 nodes) and an entreprise one.

## Branches & Operating systems. 
We have a different branch based on the supported operating systems.
Everything supported by the HPE team is provided except for the RHEL os which is not 
Following Vertica/Operating systems versions are provided:

OS | Version | 
--- | --- |
**CentOS**| 6.6 |
**CentOS**| 6.7 |
**CentOS**| 6.8 |
**CentOS**| 7.0 |
**SUSE**| 11.0 SP3 |
**Oracle**| 6.7 |
**Debian**| 7.6 |
**Debian**| 7.7 |
**Debian**| 8.5 |
**Ubuntu**| 12.04 LTS | 
**Ubuntu**| 14.04 LTS | 

## Usage

You can use theses images without persistent data store:

```
    docker run -p 5433:5433 yuntaz/vertica:8.0.1-0_centos-7.10
```

Or with persistent data store:

```
    docker run -p 5433:5433 -d \
               -v /path/to/vertica_data:/home/dbadmin/docker \
               jbfavre/vertica:7.2.3-0_debian-7.10
```

## How to fuild from Dockerfile

You have to get relevant Vertica package from my.vertica.com (registration mandatory).  
Save it in packages directory.

Then, use following command:

```
    docker build -f Dockerfile.<OS_codename>.<OS_version>_<Vertica_version> \
                 --build-arg VERTICA_PACKAGE=vertica_<Vertica_version>_amd64.deb \
                 -t jbfavre/vertica:<Vertica_version>_<OS_codename>-<OS_version> .
```

## Author				 
Yuntaz is an HPE big data partner from Mexico.
If you want to know more about Vertica, let's talk hi@yuntaz.com
Based on the original work of jbfavre. 
