FROM alpine/git AS module-cloner
RUN git clone --depth 1 https://github.com/azerothcore/mod-solocraft /modules/mod-solocraft \
 && git clone --depth 1 https://github.com/azerothcore/mod-ah-bot /modules/mod-ah-bot \
 && git clone --depth 1 https://github.com/ZhengPeiRu21/mod-individual-progression /modules/mod-individual-progression

FROM acore/ac-wotlk-db-import:master
COPY --from=module-cloner /modules/mod-solocraft /azerothcore/modules/mod-solocraft
COPY --from=module-cloner /modules/mod-ah-bot /azerothcore/modules/mod-ah-bot
COPY --from=module-cloner /modules/mod-individual-progression /azerothcore/modules/mod-individual-progression
COPY import-with-modules.sh /import-with-modules.sh
RUN chmod +x /import-with-modules.sh
CMD ["/import-with-modules.sh"]
