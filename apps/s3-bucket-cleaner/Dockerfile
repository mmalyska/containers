ARG VERSION
FROM public.ecr.aws/aws-cli/aws-cli:$VERSION

COPY ./apps/s3-bucket-cleaner/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
ENTRYPOINT [ ]
