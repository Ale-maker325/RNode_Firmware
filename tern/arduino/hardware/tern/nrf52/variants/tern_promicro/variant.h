// Распиновка платы tern-nRF52840 ProMicro (nRF52840 ProMicro + Ebyte E22 SX126x + OLED SSD1306).
// Номера выводов: P0.xx = xx, P1.xx = 32 + xx (таблица g_ADigitalPinMap — один к одному).

#ifndef _VARIANT_TERN_PROMICRO_
#define _VARIANT_TERN_PROMICRO_

#define VARIANT_MCK (64000000ul)

// Внешнего кварца 32,768 кГц на клонах ProMicro может не быть: с USE_LFXO без кварца плата зависнет на старте.
#define USE_LFRC

#include "WVariant.h"

#ifdef __cplusplus
extern "C" {
#endif

#define PINS_COUNT (48)
#define NUM_DIGITAL_PINS (48)
#define NUM_ANALOG_INPUTS (1)
#define NUM_ANALOG_OUTPUTS (0)

// Светодиод: один красный на P0.15, горит при HIGH. Bluefruit использует LED_BLUE/LED_CONN как индикатор BLE.
#define PIN_LED1 (15)
#define LED_BUILTIN PIN_LED1
#define LED_CONN PIN_LED1
#define LED_RED PIN_LED1
#define LED_BLUE PIN_LED1
#define LED_STATE_ON 1

// Кнопка P1.00 (подтяжка к 3,3 В на плате, нажатие = LOW)
#define PIN_BUTTON1 (32 + 0)

// АЦП: напряжение батареи через делитель на P0.31 (AIN7)
#define PIN_A0 (31)
#define PIN_VBAT PIN_A0
static const uint8_t A0 = PIN_A0;
#define ADC_RESOLUTION 14

#define PIN_AREF (2)
static const uint8_t AREF = PIN_AREF;

// Serial1 — разъём GPS: P0.22 — приём (TX модуля GPS), P0.20 — передача (RX модуля GPS)
#define PIN_SERIAL1_RX (22)
#define PIN_SERIAL1_TX (20)

// Serial2 — дополнительный UART на нижней колодке
#define PIN_SERIAL2_RX (6)
#define PIN_SERIAL2_TX (8)

// SPI — радиомодуль E22
#define SPI_INTERFACES_COUNT 1
#define PIN_SPI_MISO (2)       // P0.02
#define PIN_SPI_MOSI (32 + 15) // P1.15
#define PIN_SPI_SCK (32 + 11)  // P1.11

static const uint8_t SS = (32 + 13); // P1.13 — CS радиомодуля
static const uint8_t MOSI = PIN_SPI_MOSI;
static const uint8_t MISO = PIN_SPI_MISO;
static const uint8_t SCK = PIN_SPI_SCK;

// I2C — только OLED-дисплей
#define WIRE_INTERFACES_COUNT 1
#define PIN_WIRE_SDA (32 + 4) // P1.04
#define PIN_WIRE_SCL (11)     // P0.11

// Управление питанием на плате tern
#define PIN_3V3_EN (13) // P0.13: питание OLED (HIGH = вкл)
#define PIN_GPS_EN (24) // P0.24: RT9080 линии GPS (HIGH = вкл), по умолчанию выключено

#ifdef __cplusplus
}
#endif

#endif
