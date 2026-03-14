#!/bin/sh

# === PRE-BUILD CLEANUP ===
# rm -rf glaze re2 muparser hyprutils hyprlang hyprgraphics hyprcursor aquamarine hyprwire Hyprland tomlplusplus

# === PART 1: THE COMPLETE SYSTEM FOUNDATION ===

# 1. Install EVERY dependency found in your world list + build essentials
doas apk add base-devel clang lld ninja cmake pkgconf git \
    wayland-devel wayland-protocols libdrm-devel mesa-gbm-devel \
    libinput-devel libxkbcommon-devel pango-devel cairo-devel \
    pixman-devel libxcursor-devel lcms2-devel xcb-util-devel \
    xcb-util-errors-devel xcb-util-wm-devel xcb-util-image-devel \
    xcb-util-keysyms-devel libdisplay-info-devel libliftoff-devel \
    glslang-devel spirv-tools-devel mesa-devel libcap-devel \
    pugixml-devel libpng-devel libwebp-devel elogind librsvg libomp-devel libzip \
    libseat hwdata iniparser

# 2. Fix the glslang "Ghost File" error
doas touch /usr/bin/glslang
doas chmod +x /usr/bin/glslang
doas ln -sf /usr/bin/glslangValidator /usr/local/bin/glslang

# 3. Build tomlplusplus from source
git clone https://github.com/marzer/tomlplusplus.git
cd tomlplusplus && rm -rf build
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local || exit
cmake --build build || exit
doas cmake --install build
cd ..

# 4. Create the tomlplusplus.pc
doas mkdir -p /usr/local/lib/pkgconfig
doas sh -c 'cat <<EOF > /usr/local/lib/pkgconfig/tomlplusplus.pc
prefix=/usr/local
includedir=\${prefix}/include

Name: tomlplusplus
Description: Header-only TOML config file parser and serializer for C++17
Version: 3.4.0
Cflags: -I\${includedir}
EOF'

# 5. Global Environment Setup
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:$PKG_CONFIG_PATH
export CMAKE_PREFIX_PATH=/usr/local
export CC=clang
export CXX=clang++
export CXXFLAGS="-include vector -include string -include stdexcept -include cstdint -include algorithm -include cmath -include unistd.h"

# === PART 2: CORE LIBRARIES ===
# (Glaze, RE2, muparser)
git clone https://github.com/stephenberry/glaze
(cd glaze  && rm -rf build  && cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local  && doas cmake --install build  && cd ..) || exit

git clone https://github.com/google/re2
(cd re2  && rm -rf build  && cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local  && cmake --build build  && doas cmake --install build && cd ..) || exit

git clone https://github.com/beltoforion/muparser
(cd muparser && rm -rf build && cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DENABLE_OPENMP=ON && cmake --build build && doas cmake --install build && cd ..) || exit

# === PART 3: HYPR ECOSYSTEM ===
# (Utils -> Lang -> Graphics -> Cursor -> Aquamarine)
git clone https://github.com/hyprwm/hyprutils
(cd hyprutils && rm -rf build && cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local && cmake --build build && doas cmake --install build && cd .. ) || exit

git clone https://github.com/hyprwm/hyprlang
(cd hyprlang && rm -rf build && cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local && cmake --build build && doas cmake --install build && cd .. ) || exit

git clone https://github.com/hyprwm/hyprwayland-scanner
(cd hyprwayland-scanner && rm -rf build && cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local && cmake --build build && doas cmake --install build && cd ..) || exit

git clone https://github.com/hyprwm/hyprgraphics
(cd hyprgraphics && rm -rf build && cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local && cmake --build build && doas cmake --install build && cd ..) || exit

git clone https://github.com/hyprwm/hyprcursor
(cd hyprcursor && rm -rf build && cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local && cmake --build build && doas cmake --install build && cd ..) || exit

git clone https://github.com/hyprwm/aquamarine
(cd aquamarine && rm -rf build && cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DOpenGL_GL_PREFERENCE=LEGACY -DOPENGL_opengl_LIBRARY=/usr/lib/libGL.so -DOPENGL_gl_LIBRARY=/usr/lib/libGL.so -DOPENGL_egl_LIBRARY=/usr/lib/libEGL.so && cmake --build build && doas cmake --install build && cd ..) || exit

# === PART 4: FINAL BINARIES ===
git clone https://github.com/hyprwm/hyprwire
(cd hyprwire && rm -rf build && cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=/usr/local && cmake --build build && doas cmake --install build && cd ..) || exit

git clone --recursive https://github.com/hyprwm/Hyprland
(cd Hyprland && git pull && git submodule update --init --recursive && rm -rf build && cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_PREFIX_PATH=/usr/local -DOpenGL_GL_PREFERENCE=LEGACY -Dglslang_DIR=/usr/lib/cmake/glslang -DOPENGL_opengl_LIBRARY=/usr/lib/libGL.so -DOPENGL_egl_LIBRARY=/usr/lib/libEGL.so && cmake --build build && doas cmake --install build && cd ..) || exit

doas ldconfig /usr/local/lib


git clone https://github.com/hyprwm/hyprtoolkit
(cd hyprtoolkit && rm -rf build && cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local && cmake --build build && doas cmake --install build && cd ..) || exit

git clone https://github.com/hyprwm/hyprland-guiutils
(cd hyprland-guiutils && rm -rf build && cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DOpenGL_GL_PREFERENCE=LEGACY -DOPENGL_opengl_LIBRARY=/usr/lib/libGL.so -DOPENGL_egl_LIBRARY=/usr/lib/libEGL.so && cmake --build build && doas cmake --install build && cd ..) || exit

echo "Hyprland is now fully installed from source."
