FROM mcr.microsoft.com/mssql/server

COPY setup_mssql_things.sql .

ENV MSSQL_PID=Express
ENV ACCEPT_EULA=Y
RUN /opt/mssql/bin/sqlservr &

# RUN source /etc/environment \
#   && /opt/mssql/bin/sqlservr & \
#   sleep 10 \
#   && /opt/mssql-tools/bin/sqlcmd \
#   -S localhost \
#   -U sa \
#   -P ${LOCAL_SA_PASSWORD} \
#   -i setup_mssql_things.sql