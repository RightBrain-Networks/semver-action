FROM rightbrainnetworks/auto-semver:beta-test

LABEL "com.github.actions.name"="Run Auto-Semver"
LABEL "com.github.actions.description"="Github Action for RBN Auto Semver by Branch tool"
LABEL "com.github.actions.icon"="chevrons-up"
LABEL "com.github.actions.color"="blue"

LABEL repository="https://github.com/RightBrain-Networks/semver-action"
LABEL homepage="https://github.com/RightBrain-Networks/semver-action"
LABEL maintainer="RightBrain Networks <cloud@rightbrainnetworks.com>"

USER root
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
