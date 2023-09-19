FROM zabbix/zabbix-server-mysql:alpine-6.4-latest
USER root
ENV ACCEPT_EULA=Y
RUN apk update && apk add --update curl gnupg openssl unixodbc-dev mariadb-dev \
  && curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.10.2.1-1_amd64.apk \
  && curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.10.1.1-1_amd64.apk \

  && curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.10.2.1-1_amd64.sig \
  && curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.10.1.1-1_amd64.sig \

  && curl https://packages.microsoft.com/keys/microsoft.asc  | gpg --import - \
  && gpg --verify msodbcsql17_17.10.2.1-1_amd64.sig msodbcsql17_17.10.2.1-1_amd64.apk \
  && gpg --verify mssql-tools_17.10.1.1-1_amd64.sig mssql-tools_17.10.1.1-1_amd64.apk \

  && apk add --allow-untrusted msodbcsql17_17.10.2.1-1_amd64.apk \
  && apk add --allow-untrusted mssql-tools_17.10.1.1-1_amd64.apk
RUN apk add mariadb-connector-odbc --update-cache --repository http://dl-4.alpinelinux.org/alpine/edge/testing/ --allow-untrusted
COPY openssl.cnf /etc/ssl/openssl.cnf
