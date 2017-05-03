# API
Templating tools for generating the Fineo API

## Certficates

the `api.fineo.io` SSL certificate is managed by Let's Encrypt. To update the certificate, start by requesting a new one:

```
$ sudo certbot certonly --manual -d api.fineo.io
```

The process will then ask you to ensure that an endpoint matches a value. Some like:

```
Make sure your web server displays the following content at
http://api.fineo.io/.well-known/acme-challenge/GLlI9kSJiH7mM5ay-CTL0xRng5IK9_20vGgy_sjI3DU before continuing:

GLlI9kSJiH7mM5ay-CTL0xRng5IK9_20vGgy_sjI3DU.ZiFMKNhK_iyLdSdCd0gVBAeiNjRDf47zYCWJaWeojo0
```

Now, go to [https://console.aws.amazon.com/apigateway/home?region=us-east-1#/apis/wjniw7tj19/stages/handle] and set the `acme` stage variable to the content to display.

Hit `Enter` on the terminal running the Let's Encrypt update and ensure it completes successfully. Now, you need to add the certificate to AWS.

Navigate to [https://console.aws.amazon.com/acm], select api.fineo.io and 'Reimport Certificate'. Enter the body:

```
$ sudo cat /etc/letsencrypt/live/api.fineo.io/cert.pem
```

the private key:

```
$ sudo cat /etc/letsencrypt/live/api.fineo.io/privkey.pem 
```

and the full certificate chain:

```
$ sudo cat /etc/letsencrypt/live/api.fineo.io/fullchain.pem
```

into the respective fields.

## Templating

Templating is handled via the [Liquid] ruby templating engine 
and wrapped in our own `templatizer`. 

### Running Templates

Template generation for a specify stack is done via:

```
template/bin/template -o $WORKSPACE/template --$STACK $WORKSPACE/properties/${STACK}.json -v
```

where the options:

 * -o
   * output directory 
 * --$STACK
   * the name of the stack to configure, which specifies
   * the configuration file to use
 * -v
   * enable verbose mode

### Generating External Swagger Documentation
 
By default, we don't generate external swagger documentation. However, the ```--external``` 
flag enables generation of the 'public' version of the swagger documentation. This removes the 
internal specific (and occasionally sensitive) APIs from being generated. 

## Internals

Each api has its own folder under ```template/input```, for instance ```stream``` and ```batch```
. An 'api' maps to Swagger 'tag' for user documentation, but is also written as an independent 
file for consumption by AWS.

There are also a set of core definitions and includes statements can you can leverage in your 
templates.

Under each 'api' you can have a specific ```includes/``` folder. Beyond that, each folder/file 
acts as part of the api path.

For instance, ```stream/event.json``` defines the path ```[/event]``` under the ```stream``` api.
 Each json file is templated with [Liquid] where includes/defintions JSON file is a fully formed 
 elements you can reference by name, e.g. Error_400.json would be referenced by ```{{Error_400}}```. 
 

[Liquid]: https://shopify.github.io/liquid/
