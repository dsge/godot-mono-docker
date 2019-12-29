#------------------#
# GLOBAL ARGUMENTS #
#------------------#

# The folder name inside godot's "templates/" directory varies from version to version
ARG EXPORT_TEMPLATE_DIR=/root/.local/share/godot/templates/3.2.beta4.mono

#------------------------------------#
# Stage 0: Create final docker image #
#------------------------------------#
FROM mono:6.6

# Import these arguments from the global scope above
ARG EXPORT_TEMPLATE_DIR

RUN mkdir -p $EXPORT_TEMPLATE_DIR

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        # python \
        # python-openssl \
        unzip \
        wget \
        zip 

RUN wget https://downloads.tuxfamily.org/godotengine/3.2/beta4/mono/Godot_v3.2-beta4_mono_linux_headless_64.zip && \
    wget https://downloads.tuxfamily.org/godotengine/3.2/beta4/mono/Godot_v3.2-beta4_mono_export_templates.tpz
RUN mkdir ~/.cache && \
    mkdir -p ~/.config/godot && \
    mkdir -p $EXPORT_TEMPLATE_DIR && \
    mkdir -p /opt/godot && \
    unzip Godot_v3.2-beta4_mono_linux_headless_64.zip && \
    mv Godot_v3.2-beta4_mono_linux_headless_64/ /opt/ && \ 
    ln -s /opt/Godot_v3.2-beta4_mono_linux_headless_64/Godot_v3.2-beta4_mono_linux_headless.64 /usr/bin/godot && \
    unzip Godot_v3.2-beta4_mono_export_templates.tpz && \
    mv templates/* $EXPORT_TEMPLATE_DIR && \
    rm -f Godot_v3.2-beta4_mono_export_templates.tpz Godot_v3.2-beta4_mono_linux_headless_64.zip

ENTRYPOINT ["/usr/bin/godot"]