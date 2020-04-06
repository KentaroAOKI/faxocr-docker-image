FROM ubuntu:16.04

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
# ubuntu packages
RUN apt-get update
RUN apt-get install -y git curl g++ make bzip2
RUN apt-get install -y zlib1g-dev libssl-dev libreadline-dev
RUN apt-get install -y libyaml-dev libxml2-dev libxslt-dev
RUN apt-get install -y sqlite3 libsqlite3-dev nodejs
RUN apt-get install -y wget libopencv-dev
RUN apt-get install -y openssl build-essential imagemagick php libcurl4-openssl-dev
RUN apt-get install -y wget libmysqlclient-dev
RUN apt-get install -y libtool-bin wkhtmltopdf gocr netpbm fetchmail sendemail pdftk zip mpack xvfb
RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv
# ruby
ENV RUBY_VERSION=1.9.2-p330
ENV PATH=/root/.rbenv/bin:$PATH
RUN mkdir -p /root/.rbenv/plugins && cd /root/.rbenv/plugins && git clone https://github.com/sstephenson/ruby-build.git
RUN /root/.rbenv/bin/rbenv install $RUBY_VERSION
RUN echo "install: --no-ri --no-rdoc" > /root/.gemrc \
    && echo "update: --no-ri --no-rdoc" >> /root/.gemrc
ENV PATH=/root/.rbenv/versions/$RUBY_VERSION/bin:$PATH
RUN /root/.rbenv/versions/$RUBY_VERSION/bin/gem install bundler -v 1.11.2
# faxocr
RUN git clone -b kentaro/ruby19rails23mysql56 https://github.com/KentaroAOKI/faxocr.git /home/faxocr
RUN cd /home/faxocr/rails && /root/.rbenv/versions/$RUBY_VERSION/bin/bundle install
COPY database.yml /home/faxocr/rails/config/database.yml
RUN mkdir /root/.fonts && cp /home/faxocr/etc/OCRB.ttf /root/.fonts/ && fc-cache -v -f
# kocr and sheet-reader 
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
RUN cd /home/faxocr/src \
    && git clone https://github.com/cluscore/cluscore.git \
    && cd cluscore \
    && ./configure \
    && make install
RUN cd /home/faxocr/src/srhelper \
    && make \
    && make install
RUN cd /home/faxocr/src \
    && git clone https://github.com/faxocr/kocr.git \
    && cd kocr/src \
    && make \
    && make library \
    && make install
RUN cd /home/faxocr/src \
    && git clone https://github.com/faxocr/sheet-reader.git \
    && cd sheet-reader \
    && ./configure \
    && make install \
    && cp src/sheetreader ../../bin/
