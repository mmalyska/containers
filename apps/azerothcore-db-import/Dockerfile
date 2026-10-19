FROM alpine/git@sha256:03228d7ded483b0b3e55e1de7fa660d70d3e1bb432fa7021d29e192640de11aa AS module-cloner
RUN git clone --depth 1 https://github.com/azerothcore/mod-solocraft /modules/mod-solocraft \
 && git clone --depth 1 https://github.com/azerothcore/mod-ah-bot /modules/mod-ah-bot \
 && git clone --depth 1 https://github.com/azerothcore/mod-transmog /modules/mod-transmog

FROM acore/ac-wotlk-db-import:master@sha256:8e5ea9eb8166749623e4c8e78d50142ce517c222f3a9c970a2e2a39785ee53ea
COPY --from=module-cloner /modules/mod-solocraft /azerothcore/modules/mod-solocraft
COPY --from=module-cloner /modules/mod-ah-bot /azerothcore/modules/mod-ah-bot
COPY --from=module-cloner /modules/mod-transmog /azerothcore/modules/mod-transmog
COPY --chmod=755 apps/azerothcore-db-import/import-with-modules.sh /import-with-modules.sh
CMD ["/import-with-modules.sh"]
