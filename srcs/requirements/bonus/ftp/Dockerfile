FROM alpine:3.20

RUN apk add --no-cache vsftpd

COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY tools/setup.sh /usr/local/bin/ftp-entrypoint.sh
RUN chmod +x /usr/local/bin/ftp-entrypoint.sh

EXPOSE 21 21100-21110

ENTRYPOINT ["/usr/local/bin/ftp-entrypoint.sh"]
CMD ["/usr/sbin/vsftpd", "/etc/vsftpd/vsftpd.conf"]