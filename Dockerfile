# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Set the working directory to /opt/odoo17
WORKDIR /opt/odoo17

# Update and install dependencies
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y openssh-server fail2ban \
       python3-pip python3-dev libxml2-dev libxslt1-dev zlib1g-dev libsasl2-dev libldap2-dev build-essential \
       libssl-dev libffi-dev libmysqlclient-dev libjpeg-dev libpq-dev libjpeg8-dev liblcms2-dev libblas-dev libatlas-base-dev \
       npm node-less \
       postgresql git \
    && ln -s /usr/bin/nodejs /usr/bin/node \
    && npm install -g less less-plugin-clean-css \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create PostgreSQL user and database
RUN su - postgres -c "createuser --createdb --username postgres --no-createrole --no-superuser --pwprompt odoo17" \
    && su - postgres -c "psql -c 'ALTER USER odoo17 WITH SUPERUSER;'"

# Create Odoo system user
RUN adduser --system --home=/opt/odoo17 --group odoo17

# Clone Odoo 17 repository
USER odoo17
RUN git clone https://github.com/Mahdi-Zitouni/odoo17.git --depth 1 --branch odoo17 .

# Install additional Python dependencies
RUN pip3 install -r /opt/odoo17/requirements.txt

# Install wkhtmltopdf
USER root
RUN apt-get -y install wkhtmltopdf

# Copy Odoo configuration file
COPY odoo.conf /etc/odoo17.conf
RUN chown odoo17: /etc/odoo17.conf && chmod 640 /etc/odoo17.conf

# Create Odoo log directory
RUN mkdir /var/log/odoo && chown odoo17:root /var/log/odoo

# Expose Odoo port
EXPOSE 8069

# Switch back to the Odoo user
USER odoo17

# Odoo service file
COPY odoo.service /etc/systemd/system/odoo17.service
RUN chmod 755 /etc/systemd/system/odoo17.service && chown root: /etc/systemd/system/odoo17.service

# Start Odoo
CMD ["sudo", "systemctl", "start", "odoo17.service"]
