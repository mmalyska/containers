FROM alpine/git@sha256:d453f54c83320412aa89c391b076930bd8569bc1012285e8c68ce2d4435826a3 AS module-cloner
RUN git clone --depth 1 https://github.com/azerothcore/mod-solocraft /modules/mod-solocraft \
 && git clone --depth 1 https://github.com/azerothcore/mod-ah-bot /modules/mod-ah-bot \
 && git clone --depth 1 https://github.com/ZhengPeiRu21/mod-individual-progression /modules/mod-individual-progression

FROM acore/ac-wotlk-db-import:master@sha256:3ee59b900566318cfafaf5b18bc7ecd6cd7b559c3c32376d9e6a99903580f711
COPY --from=module-cloner /modules/mod-solocraft /azerothcore/modules/mod-solocraft
COPY --from=module-cloner /modules/mod-ah-bot /azerothcore/modules/mod-ah-bot
COPY --from=module-cloner /modules/mod-individual-progression /azerothcore/modules/mod-individual-progression
COPY --chmod=755 apps/azerothcore-db-import/import-with-modules.sh /import-with-modules.sh
CMD ["/import-with-modules.sh"]
