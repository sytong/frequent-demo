# frequent-demo

`frequent-demo` is an experiment to find ways in visualizing of the [frequent-algorithm](https://github.com/buruzaemon/frequent-algorithm) gem. Here we are using text from some of Homer's work (Iliad and Odyssey), feeding the into the frequent-algorithm and capture what are the trending words in the stories.

This is still a very early implementation.

_TODO_:
* ~~Add a HTML page to display the results~~
* Display results in a table
* Bug fixes
* Graphical visualization?

## Usage

Check out the code and run `bundle`.
Then start the server by:
    
    rackup config.ru
    

Then open `http://localhost:9292` using Google Chrome.

## Development

The following gems have been used in the implementation of this demo:

* [`sinatra-hijacker`](https://github.com/minoritea/sinatra-hijacker)
* [`tubesock`](https://github.com/ngauthier/tubesock)
* [`frequent-algorithm`](https://github.com/buruzaemon/frequent-algorithm)

The demo also requires [`puma`](https://github.com/puma/puma) to run.

## License

frequent-demo is provided under the terms of the MIT license.

Copyright &copy; 2015, Willie Tong. All rights reserved. Please see the {file:LICENSE} file for further details.
