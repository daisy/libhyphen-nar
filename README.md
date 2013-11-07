Build
-----

    mvn clean install

To build for 32 bit on a 64 bit machine:

    mvn clean install -Dos.arch=i386

Deploy
------

To deploy to Sonatype OSS, use the `sonatype-oss-release` profile:

      mvn clean deploy -P sonatype-oss-release
      
