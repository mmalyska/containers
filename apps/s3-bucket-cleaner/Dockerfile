ARG VERSION
FROM public.ecr.aws/aws-cli/aws-cli:$VERSION

# Install jq
RUN yum update -y \
  && yum install -y jq \
  && yum clean all

COPY ./apps/s3-bucket-cleaner/urldecode.jq /var/lib/jq/urldecode.jq
COPY ./apps/s3-bucket-cleaner/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
