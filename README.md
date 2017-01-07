# API

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
 
### Excluded  
 

[Liquid]: https://shopify.github.io/liquid/
