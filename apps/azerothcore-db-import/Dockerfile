FROM alpine/git@sha256:3b44767883ac77bddae0160cc27b6b039345e23fa3504f4159efaa32264ab57f AS module-cloner
RUN git clone --depth 1 https://github.com/azerothcore/mod-solocraft /modules/mod-solocraft \
 && git clone --depth 1 https://github.com/azerothcore/mod-ah-bot /modules/mod-ah-bot \
 && git clone --depth 1 https://github.com/azerothcore/mod-transmog /modules/mod-transmog

FROM acore/ac-wotlk-db-import:master@sha256:2ba8157cf487281c0ba0462c9817662640371e06c8f42e1cb5e32d2e7b8d41e9
COPY --from=module-cloner /modules/mod-solocraft /azerothcore/modules/mod-solocraft
COPY --from=module-cloner /modules/mod-ah-bot /azerothcore/modules/mod-ah-bot
COPY --from=module-cloner /modules/mod-transmog /azerothcore/modules/mod-transmog
COPY --chmod=755 apps/azerothcore-db-import/import-with-modules.sh /import-with-modules.sh
CMD ["/import-with-modules.sh"]
