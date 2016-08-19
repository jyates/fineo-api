# API

## Templating

Templating is handled via the [Liquid] ruby templating engine 
and wrapped in out own 
`templatizer`. To run the templating, just call:

```
$ template/template.rb
```

### Internals

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
