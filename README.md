# WSI
*WSI* is a Web Service Application which implements a 
[RESTFul](https://en.wikipedia.org/wiki/Representational_state_transfer) API.

Those services are a process's part of the [Bigsea Project](http://www.eubra-bigsea.eu/).

## Building From Docker

### Build Image
First of all, we need to build the docker image.
From the repository root directory, launch:

~~~
cd WSI/docker
docker build --no-cache --force-rm -t WSI .
~~~

This will build a docker image tagged as `WSI`.
*Be patient, the building process could take several minutes.*

Once the images has been built, the WebService can be launched in a docker container.

### Run Container
From the repository root directory, launch:

~~~
cd WSI/
export WSI_SERVICE_PORT=8080
docker run --name WSI_service -d -v ${PWD}/config_example/wsi_config.xml:/home/wsi/wsi_config.xml -p ${WSI_SERVICE_PORT}:8080 WSI
~~~

where the enviroment variable `WSI_SERVICE_PORT` is the port where tomcat will listen to.

The options:
 * `-d` launchs the container in a demon process.
 * `-v` binds the default configuration file (which is located in the repository at `WSI/config_example/wsi_config.xml`)
 in the container.
 * `-p` allows the binding of the port.
 * `--name` sets the name of docker container.
 
