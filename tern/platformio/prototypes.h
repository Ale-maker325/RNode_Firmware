// tern: объявления функций скетча, которые PlatformIO не находит сам.
// arduino-cli генерирует их автоматически, а генератор PlatformIO пропускает функции,
// записанные с отступом внутри #if (как update_csma_parameters в RNode_Firmware.ino).
// Подключается через -include в platformio.ini, код автора не меняется.

#pragma once

void update_csma_parameters();
