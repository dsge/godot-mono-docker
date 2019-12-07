#------------------#
# GLOBAL ARGUMENTS #
#------------------#

# The Godot branch to checkout and build
ARG BRANCH=8eb183aebb9c79ff92d6f566af7ad2f91696ce08
# The folder name inside godot's "templates/" directory varies from version to version
ARG EXPORT_TEMPLATE_DIR=/root/.local/share/godot/templates/3.2.beta.mono

#--------------------------#
# Stage 0: Build Godot CLI #
#--------------------------#
FROM mono:6.4

# Import these arguments from the global scope above
ARG BRANCH
ARG EXPORT_TEMPLATE_DIR

# Godot build requirements
RUN apt-get update
RUN apt-get install -y git
RUN mozroots --import --sync
RUN apt-get install -y build-essential scons pkg-config libx11-dev libxcursor-dev libxinerama-dev \
    libgl1-mesa-dev libglu-dev libasound2-dev libpulse-dev libfreetype6-dev libudev-dev libxi-dev \
    libxrandr-dev yasm

WORKDIR /opt/godot.git

RUN git clone https://github.com/godotengine/godot.git /opt/godot.git 
RUN git checkout $BRANCH -b build

# BUILD GODOT CLI
RUN scons p=server tools=yes module_mono_enabled=yes mono_glue=no -j$(nproc)
RUN ./bin/godot_server.x11.tools.64.mono --generate-mono-glue modules/mono/glue
RUN scons p=server target=release_debug tools=yes module_mono_enabled=yes -j$(nproc)

# BUILD EXPORT TEMPLATES
RUN scons p=x11 target=release tools=no module_mono_enabled=yes -j$(nproc) && \
    mv ./bin/data.mono.x11.64.release $EXPORT_TEMPLATE_DIR && \
    mv ./bin/godot.x11.opt.64.mono $EXPORT_TEMPLATE_DIR/linux_x11_64_release

#------------------------------------#
# Stage 1: Create final docker image #
#------------------------------------#
FROM mono:6.4

# Import these arguments from the global scope above
ARG EXPORT_TEMPLATE_DIR

# Persist the built binaries and templates from the previous stage (but nothing else)
COPY --from=0 $EXPORT_TEMPLATE_DIR $EXPORT_TEMPLATE_DIR
RUN mkdir /opt/godot
WORKDIR /opt/godot
COPY --from=0 /opt/godot.git/bin/godot_server.x11.opt.tools.64.mono /opt/godot
RUN ln -s godot_server.x11.opt.tools.64.mono godot

ENV PATH /opt/godot:$PATH

ENTRYPOINT ["/opt/godot/godot_server.x11.opt.tools.64.mono"]