# Nicholas Nooney's Blog

## Rake Resources

### Configuring Rake

Modify the variables in the file `env/_rake_config.rb` to control options for
the Rake targets listed below. No modification of `Rakefile` should be
necessary.

### Rake Targets

Run `rake` to list all targets.

- `author`: Authoring content for the site
    - `post[date,title,category]`: Create a new post
    - `publish`: Publish changes (git push origin HEAD)
- `ci`: Building and Deploying Targets (Used in dev and prod)
    - `build`: Build the site
    - `clean`: Clean the site
    - `deploy`: Run the CI pipeline (clean, build, test)
    - `rebuild`: Build the Site from scratch
    - `test`: Test the currently build site
- `dev`: Development Targets
    - `preview`: Preview the site locally (this will use HTTPS with the SSL
      certificates created by the `ssl` target if they are available).
    - `ssl`: Generate self-signed SSL Cert via OpenSSL
- `m`: Main Targets
    - `deploy`: Runs `ci:deploy` target
    - `post`: Runs `author:post` target

### Using Rake from Windows

Depending on how the prerequisites were installed and what shell the user
develops with, there may be issues with the development server process remaining
when stopping it from the terminal with `Ctrl + C`. Below are successful methods
for ensuring processes will clean up correctly.

#### mintty shell

The mintty shell (which is used in programs like git-bash and msys2) does not
support Windows console signal handling. Therefore, signals from this shell will
not properly propagate to programs. A workaround is to use the winpty shell
which can handle the bindings.

- Bad: `rake dev:preview`
- Good: `winpty rake.cmd dev:preview`
