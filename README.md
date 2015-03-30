# Snaply

The most beautiful note service with the ugliest code.

## Development

### The technologies(fake) we use:

Backend stack:

- Koa.js
- MongoDB
- Redis

Frontend tools:

- CoffeeScript
- Bower
- Gulp

### The way not so bright

- Fork this repo
- Run `npm install` and `bower install` inside the project directory
- Create your app on [GitHub](https://github.com/settings/applications/new) and gain the app key and secret
- Edit the `setenv_example` with the key-secret you got in the last step, rename it to `setenv` and run `source ./setenv`
- Run `gulpc` to watch it build and open [localhost:2378](http://localhost:2378) to see her alive

### The way shines

You can do all the things above in a [vagrant](https://www.vagrantup.com/) box in order not to break something accidentally in your developing environment. I will give a more detailed instruction about it later if needed.

## Security and backup

For the data's own good, Dropbox support is now in my todolist.

If you want more features you can fork and make a pull request, or even just submitting an issue is welcome by me.

## Todo

Checkout the [todolist](https://snaply.me/p/8LMfu0QtCwr) on Snaply.

## Sponsor

This work is sponsored by [Zorceta](https://github.com/zorceta).

## License

MIT.