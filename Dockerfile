# Use a minimal Ubuntu image as a parent image
FROM ubuntu:22.04

# Set non-interactive mode
ENV DEBIAN_FRONTEND noninteractive

# Set the working directory to /opt/odoo17
WORKDIR /opt/odoo17

# Update and install dependencies
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y openssh-server fail2ban \
       python3-pip python3-dev libxml2-dev libxslt1-dev zlib1g-dev libsasl2-dev libldap2-dev build-essential \
       libssl-dev libffi-dev libmysqlclient-dev libjpeg-dev libpq-dev libjpeg8-dev liblcms2-dev libblas-dev libatlas-base-dev \
       npm node-less \
       postgresql git \
    && npm install -g less less-plugin-clean-css \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


# Create Odoo system user
RUN adduser --system --home=/opt/odoo17 --group odoo17

# Install additional Python dependencies
COPY requirements.txt /opt/odoo17/requirements.txt
RUN pip3 install -r requirements.txt

# Install wkhtmltopdf
USER root
RUN apt-get update && apt-get -y install wkhtmltopdf

# Copy Odoo configuration file
COPY odoo.conf /etc/odoo17.conf
RUN chown odoo17: /etc/odoo17.conf && chmod 640 /etc/odoo17.conf

# Create Odoo log directory
RUN mkdir /var/log/odoo && chown odoo17:root /var/log/odoo

# Expose Odoo port
EXPOSE 8069

# Odoo service file
USER root
COPY odoo.service /etc/systemd/system/odoo17.service
RUN chmod 755 /etc/systemd/system/odoo17.service && chown root: /etc/systemd/system/odoo17.service

# Start Odoo
CMD ["systemctl", "start", "odoo17.service"]
