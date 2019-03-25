from python:3

RUN apt-get update && apt-get install -y unzip 
RUN pip install boto3 botocore

WORKDIR /data
COPY test.py /data

COPY ENTRYPOINT.sh  /usr/local/bin/
RUN chmod +x  /usr/local/bin/ENTRYPOINT.sh


ENTRYPOINT ["/usr/local/bin/ENTRYPOINT.sh"]
CMD [ "python", "./data/test.py" ]