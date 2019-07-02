# My FaveTools

My-FaveTools is a Sinatra web application created to keep track of and share my favorite videos, software, documents, and other tools that I find useful.

## Demo

Visit [https://my-favetools.herokuapp.com/](https://my-favetools.herokuapp.com/) to browse my-favetools.

Sign up and login to keep track of and share your favorite tools. Or, you can use this pre-made user account setting to login:

    $ username: jade
    $ email: jade@email.com
    $ password: Pass1@

## Installation to run locally

In a bash terminal, clone the application repository from github then run the application.

    $ git clone git@github.com:nichia/my-favetools.git
    $ cd my-Favetools
    $ bundle install
    $ bundle exec rake db:create
    $ bundle exec rake db:migrate
    $ bundle exec rake db:seed

## Run the server

In a bash terminal, run the server.

    $ bundle exec shotgun

## Usage

Open up another terminal and copy/paste the IP server address into a web browser URL (usually http://localhost:9393) to use the application.

Sign up and login to keep track of and share your favorite tools. Or, you can use this pre-made user account setting to login:

    $ username: jade
    $ email: jade@email.com
    $ password: Pass1@

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nichia/my-favetools.

## License

The application is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
