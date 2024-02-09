# Use a minimal Ubuntu image as a parent image
FROM ubuntu:22.04

# Set non-interactive mode
ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONDONTWRITEBYTECODE 1
# Set the working directory to /opt/odoo17
WORKDIR /opt/odoo17

# Copy the Odoo files from your local machine to the container
COPY . /opt/odoo17

# Update and install dependencies
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y openssh-server fail2ban \
       python3-pip python3-dev libxml2-dev libxslt1-dev zlib1g-dev libsasl2-dev libldap2-dev build-essential \
       libssl-dev nano libffi-dev libmysqlclient-dev libjpeg-dev libpq-dev libjpeg8-dev liblcms2-dev libblas-dev libatlas-base-dev \
       npm node-less \
       postgresql git \
    && npm install -g less less-plugin-clean-css \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


# Create Odoo system user
RUN adduser --system --home=/opt/odoo17 --group odoo17

# Install additional Python dependencies
RUN apt-get update && apt-get -y --allow-unauthenticated install wkhtmltopdf
# Install wkhtmltopdf
USER root
RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
RUN tar xvf wkhtmltox*.tar.xz
RUN mv wkhtmltox/bin/wkhtmlto* /usr/bin
RUN apt-get install -y openssl build-essential libssl-dev libxrender-dev git-core libx11-dev libxext-dev libfontconfig1-dev libfreetype6-dev fontconfig


RUN pip3 install Babel==2.9.1 chardet==4.0.0 cryptography==3.4.8 decorator==4.4.2 docutils==0.17 ebaysdk==2.1.5 freezegun==1.1.0 geoip2==2.9.0 gevent==22.10.2 greenlet==2.0.2 idna==2.10 Jinja2==3.1.2 \
    libsass==0.20.1 lxml==4.9.2 MarkupSafe==2.1.2 num2words==0.5.10 ofxparse==0.21 passlib==1.7.4 Pillow==9.4.0 polib==1.1.1 psutil==5.9.4 \
    psycopg2==2.9.5 pydot==1.4.2 pyopenssl==21.0.0 PyPDF2==2.12.1 pyserial==3.5 python-dateutil==2.8.1 python-ldap==3.4.0 python-stdnum==1.17 pytz pyusb==1.2.1 \
    qrcode==7.3.1 reportlab==3.6.12 requests==2.25.1 rjsmin==1.1.0 urllib3==1.26.5 vobject==0.9.6.1 Werkzeug==2.0.2 xlrd==1.2.0 XlsxWriter==3.0.2 xlwt==1.3.* zeep==4.1.0 fpdf img2pdf \
    user_agents prestapyt cerberus sqlparse openpyxl pandas html2text pdfminer google-auth
RUN pip3 install PyPDF2


# Copy Odoo configuration file
COPY odoo.conf /etc/odoo17.conf
RUN chown odoo17: /etc/odoo17.conf && chmod 640 /etc/odoo17.conf

# Create Odoo log directory
RUN mkdir /var/log/odoo17 && chown odoo17:root /var/log/odoo17
RUN chmod +x /opt/odoo17/odoo-bin
RUN chown -R odoo17:root /opt/odoo17

# Create Odoo Service
COPY odoo17 /etc/init.d/odoo17
RUN chmod 755 /etc/init.d/odoo17 \
    && chown root: /etc/init.d/odoo17
RUN chmod +x /etc/init.d/odoo17

USER odoo17

# Expose Odoo port
EXPOSE 8069 8071 8072

CMD ["/opt/odoo17/odoo-bin", "-c", "/etc/odoo17.conf"]
