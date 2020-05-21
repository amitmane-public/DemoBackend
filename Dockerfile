ARG ARCH=amd64

FROM amd64/websphere-liberty:19.0.0.5-microProfile1 as builder
MAINTAINER IBM

USER root

# Set password length and expiry for compliance with Vulnerability Advisor
RUN sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs \
	&& sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   1/' /etc/login.defs \
    && sed -i 's/sha512/sha512 minlen=8/' /etc/pam.d/common-password

RUN mkdir -p /opt/ibm/wlp/usr/servers/defaultServer/resources/security \
    && chown -R 1001:0 /opt/ibm/wlp/usr/servers/defaultServer/resources/security \
    && rm -rf /opt/ibm/wlp/usr/servers/defaultServer/configDropins/defaults \
    && chown -R 1001:0 /opt/ibm/wlp/usr/servers/defaultServer/configDropins/overrides \
    && chown -R 1001:0 /opt/ibm/wlp

USER 1001

# Copy MFP Server war files
#COPY mfpf-libs/mfp-server.war  /opt/ibm/wlp/usr/servers/defaultServer/apps
COPY mfpf-libs/DemoServlet.war /opt/ibm/wlp/usr/servers/defaultServer/apps

# USER root
# RUN chmod -R 777 /opt/ibm/wlp/databases
USER 1001

COPY server.xml /opt/ibm/wlp/usr/servers/defaultServer
#COPY jvm.options /opt/ibm/wlp/usr/servers/defaultServer
#COPY bootstrap.properties /opt/ibm/wlp/usr/servers/defaultServer
# update keystore  and truststore file
#COPY security/keystore.jks /opt/ibm/wlp/usr/servers/defaultServer/resources/security

FROM  ${ARCH}/websphere-liberty:19.0.0.5-kernel
MAINTAINER IBM

COPY --chown=1001:0 --from=builder /etc/login.defs /etc/login.defs
COPY --chown=1001:0 --from=builder /etc/pam.d/common-password /etc/pam.d/common-password
COPY --chown=1001:0 --from=builder /opt/ibm/wlp /opt/ibm/wlp
#COPY --chown=1001:0 --from=builder /opt/ibm/MobileFirst /opt/ibm/MobileFirst

USER 1001
EXPOSE 9080
