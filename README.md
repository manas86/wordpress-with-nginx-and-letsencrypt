### Hosting WordPress over HTTPS with Docker , NGINX and Letsencrypt

For my SSL certificates, I’m using [Let’s Encrypt](https://letsencrypt.org/)via [Certbot](https://github.com/certbot/certbot). 
It’s a lovely little tool that automates the whole certificate registration process.

some more readings on certbot for [nginx manual mode](https://certbot.eff.org/docs/using.html#nginx).

The following is our configuration for docker compose 
```
- proxy:
  - nginx
- wordpress:
  - nginx
  - wordpress
  - mysql
```

#### NGINX Proxy container 

The container exposes port 80 and port 443 to the host machine. 
When the container is brought up, it mounts the two local directories to the `/etc/letsencrypt/` and `/etc/ssl/` directories on the container, respectively. 
Then, the default startup command (nginx -g 'daemon off;') is overridden to run the `start.sh` file.
Finally, the container is configured to restart whenever it goes now, via the `restart: always` line.

The `start.sh` script is intended to be run whenever the container is brought up (i.e. with docker-compose up). 
It will only attempt to register certifications if the directory for the certifications are not already in the `/etc/letsencrypt/live` directory on the container. 
The paths in `start.sh` must coincide with those in the Nginx configuration file.

##### nginx.conf

This configures the proxy to listen for requests hitting port `443` (e.g. requests using https://*). 
If the requests are for the `vihaan-photography.com` or `www.vihaan-photography.com` domain, 
then the request is passed on to the `http://docker-wordpress` server. 
The `http://docker-wordpress` “upstream” server is defined as port 80 of the connected `nginx-wordpress` container. 
Connecting the containers together is accomplished by using the networks key in the `docker-compose.yml` files.

The Nginx configuration file above to include a server block for allowing the proxy to pass Certbot’s ACME(Automated Certificate Management Environment) challenge. 
This is required for certificate renewal.

Any requests to port 80 are not using SSL (just normal http://*), so those requests are redirected to port 443 by forcing the use of HTTPS in the url.

#### Wordpress container 

`wordpress.conf` This Nginx server specifically caters to the WordPress container. 
It listens for requests to port 80 and sends any requests for PHP files (include admin pages) to the WordPress container on port 9000. 
This nginx server doesn't need to listen on port 443 because the proxy is handling the SSL authentication. 
Any incoming requests for files on the WordPress server will be routed through the proxy.

### WORKING IN PROGRESS
