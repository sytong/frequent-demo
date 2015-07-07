# frequent-demo

`frequent-demo` is an experiment to find out how we can visualize the data produced by the [frequent-algorithm](https://github.com/buruzaemon/frequent-algorithm) gem. Here we are using text from some of Homer's work (Iliad and Odyssey), feeding them into the frequent-algorithm and capture what are the trending words in the stories.

This is still a very early implementation. 

_TODO_:
* ~~Add a HTML page to display the results~~
* ~~Display results in a table~~
* Bug fixes
    * Pausing main thread causes socket connection delay (requires retries to succeed)
* Graphical visualization
    * Use D3 Donut Chart (rough cut is ready)
    * Use HighChart Donut Chart?
    * What else?

## Usage

Check out the code and run `bundle`.
Then start the server by:
    
    rackup config.ru
    

Then open `http://localhost:9292` using Google Chrome to see the simple HTML table presentations.
Open `http://localhost:9292/d3_donut` to see animated D3 Donut Chart in action.

## Development

The following gems have been used in the implementation of this demo:

* [`sinatra-hijacker`](https://github.com/minoritea/sinatra-hijacker)
* [`tubesock`](https://github.com/ngauthier/tubesock)
* [`frequent-algorithm`](https://github.com/buruzaemon/frequent-algorithm)

The demo also requires [`puma`](https://github.com/puma/puma) to run.

## License

frequent-demo is provided under the terms of the MIT license.

Copyright &copy; 2015, Willie Tong. All rights reserved. Please see the {file:LICENSE} file for further details.
