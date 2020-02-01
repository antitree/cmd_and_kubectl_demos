FROM python:3

MAINTAINER Your Name "antitree@gmail.com"

RUN apt-get update && apt-get install -y \
    curl \
    sudo \
 && rm -rf /var/lib/apt/lists/*

RUN useradd -u 999 -G sudo -ms /bin/bash antitree
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER antitree:antitree

COPY requirements.txt ./
RUN pip install --user --no-cache-dir -r requirements.txt

WORKDIR /usr/src/app
RUN sudo chown antitree /usr/src/app -R

COPY . .

# We copy just the requirements.txt first to leverage Docker cache


ENTRYPOINT [ "python" ]

CMD [ "app.py" ]
