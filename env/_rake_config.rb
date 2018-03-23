# coding: utf-8
# Rake Configuration File. This file contains variables to override defaults in
# the Rakefile.

# $SITE_DIR contains the output directory jekyll generates files in. It also
# serves as the point to run tests on. Default Value: "_site/"
$SITE_DIR = "_site/"

# $POST_DIR contains the directory to create new posts in.
# Default Value: "_posts/"
$POST_DIR = "_posts/"

# $DRAFT_DIR contains the directory to create new drafts in.
# Default Value: "_drafts/"
$DRAFT_DIR = "_drafts/"

# $POST_EXT is the extenstion used when creating new posts.
# Default Value: ".md"
$POST_EXT = ".md"

# $SSL_CERT is the certificate file used for enabling SSL.
$SSL_CERT = "env/ssl/devCA.crt"

# $SSL_KEY is the private key file corresponding to $SSL_CERT.
$SSL_KEY = "env/ssl/devCA.key"

# $SERVER_ADDR is the address for the development server.
$SERVER_ADDR = "localhost"

# $SERVER_PORT is the port for the development server.
$SERVER_PORT = "4000"
