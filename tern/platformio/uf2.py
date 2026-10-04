# tern: после сборки PlatformIO делает из .hex файл .uf2 для прошивки перетаскиванием на диск NRF52BOOT.
# Конвертер uf2conv.py берётся из пакета ядра Adafruit nRF52, который PlatformIO уже скачал.

import os
import sys

Import("env")


def hex_to_uf2(source, target, env):
    hex_path = target[0].get_abspath()
    uf2_path = os.path.join(env.subst("$PROJECT_DIR"), "tern", "build", env.subst("rnode_firmware_${PIOENV}.uf2"))
    os.makedirs(os.path.dirname(uf2_path), exist_ok=True)
    framework_dir = env.PioPlatform().get_package_dir("framework-arduinoadafruitnrf52")
    uf2conv = os.path.join(framework_dir, "tools", "uf2conv", "uf2conv.py")
    env.Execute(
        env.VerboseAction(
            f'"{sys.executable}" "{uf2conv}" "{hex_path}" -c -f 0xADA52840 -o "{uf2_path}"',
            f"UF2: {uf2_path}",
        )
    )


env.AddPostAction("$BUILD_DIR/${PROGNAME}.hex", hex_to_uf2)
