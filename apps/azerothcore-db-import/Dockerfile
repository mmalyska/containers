FROM alpine/git@sha256:a299a963fbe31628ab481ca42907bcf0691d004f86734c02638abdf513691d42 AS module-cloner
RUN git clone --depth 1 https://github.com/azerothcore/mod-solocraft /modules/mod-solocraft \
 && git clone --depth 1 https://github.com/azerothcore/mod-ah-bot /modules/mod-ah-bot \
 && git clone --depth 1 https://github.com/azerothcore/mod-transmog /modules/mod-transmog

FROM acore/ac-wotlk-db-import:master@sha256:0c18afb89438428b44d1ddf0120570dbe310ef2806223cf495d9c82edcabeaf8
COPY --from=module-cloner /modules/mod-solocraft /azerothcore/modules/mod-solocraft
COPY --from=module-cloner /modules/mod-ah-bot /azerothcore/modules/mod-ah-bot
COPY --from=module-cloner /modules/mod-transmog /azerothcore/modules/mod-transmog
COPY --chmod=755 apps/azerothcore-db-import/import-with-modules.sh /import-with-modules.sh
CMD ["/import-with-modules.sh"]
