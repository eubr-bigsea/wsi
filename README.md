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
docker build --no-cache --force-rm -t wsi .
~~~

This will build a docker image tagged as `wsi`.
*Be patient, the building process could take several minutes.*

Note that the container will be built with the configuration located in the same directory (i.e. `WSI/docker/wsi_config.xml`).

Once the images has been built, the WebService can be launched in a docker container.

### Run Container
From the repository root directory, launch:

~~~
cd WSI/
export WSI_SERVICE_PORT=8080
docker run --name wsi_service -d -v ${PATH_YOUR_CUSTOM_CONFIG}:/home/wsi/wsi_config.xml -p ${WSI_SERVICE_PORT}:8080 wsi
~~~

where the enviroment variable `WSI_SERVICE_PORT` is the port where tomcat will listen to.

The options:
 * `-d` launchs the container in a demon process.
 * `-v` binds a custom configuration file in the container. If you want to use the default configuration just skip that option.
 in the container.
 * `-p` allows the binding of the port.
 * `--name` sets the name of docker container.
 
### Useful Commands and Informations
#### Restart Application
Since the configuration file is read only at the application's startup, when it is changed the application
needs to be restarted.

In order to restart the docker container, just launch:

~~~
docker restart wsi_service
~~~

#### Configuration File
By default, the configuration file in the container is located in:
~~~
/home/wsi/wsi_config.xml
~~~




 
