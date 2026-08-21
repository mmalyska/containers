FROM alpine/git@sha256:a299a963fbe31628ab481ca42907bcf0691d004f86734c02638abdf513691d42 AS module-cloner
RUN git clone --depth 1 https://github.com/azerothcore/mod-solocraft /modules/mod-solocraft \
 && git clone --depth 1 https://github.com/azerothcore/mod-ah-bot /modules/mod-ah-bot \
 && git clone --depth 1 https://github.com/azerothcore/mod-transmog /modules/mod-transmog

FROM acore/ac-wotlk-db-import:master@sha256:49990b1d5bbdf5d7438d41f8430f3b997d0f7a2a7d035fe3e235ee2a9fd2981b
COPY --from=module-cloner /modules/mod-solocraft /azerothcore/modules/mod-solocraft
COPY --from=module-cloner /modules/mod-ah-bot /azerothcore/modules/mod-ah-bot
COPY --from=module-cloner /modules/mod-transmog /azerothcore/modules/mod-transmog
COPY --chmod=755 apps/azerothcore-db-import/import-with-modules.sh /import-with-modules.sh
CMD ["/import-with-modules.sh"]
