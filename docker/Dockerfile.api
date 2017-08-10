FROM marjoram0/ispa:v1

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/local/bin/gunicorn config.wsgi -w 4 -b 0.0.0.0:5000"]
