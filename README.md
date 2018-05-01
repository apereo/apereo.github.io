# Apereo Community Blog

## Building and running locally

This blog is built and hosted in GitHub Pages, which is a SaaS implementation of Jekyll.

You can locally run Jekyll to build the site from source and even serve it up, e.g. to preview your in-development changes.

> *Note:* Tested with bundler 1.16.1

1. Clone the repo
2. Run `bundle install`
3. Run `bundle exec jekyll serve --incremental`
4. Should something similar to:
```
Configuration file: /apereo.github.io/_config.yml
            Source: /apereo.github.io
       Destination: /apereo.github.io/_site
 Incremental build: enabled
      Generating...
                    done in 3.294 seconds.
 Auto-regeneration: enabled for 'apereo.github.io'
    Server address: http://127.0.0.1:4000/
  Server running... press ctrl-c to stop.
```

> If you get any errors, try running `gem install bundler` and then re-run the `bundle install` command.
> 
> You can also run `bundle check` to see if there are any problems with the dependencies.