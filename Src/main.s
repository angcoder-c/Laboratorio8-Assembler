/*
Laboratorio 8
Angel Chavez 24248
23/05/2025
*/

.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.global main

.equ RCC_BASE,     0x40023800
.equ GPIOA_BASE,   0x40020000

.equ RCC_AHB1ENR,  RCC_BASE + 0x30
.equ GPIOA_MODER,  GPIOA_BASE + 0x00
.equ GPIOA_ODR,    GPIOA_BASE + 0x14

.equ GPIOC_MODER,   0x40020800
.equ GPIOC_IDR,     0x40020810

.equ LED_PIN_PA5, 5 // PA5
.equ LED_PIN_PA4, 4 // PA5
.equ BUTTON_PIN, 13 // PC13

main:
	// (inciso 3)
	// inicializar el contador del boton
	LDR r2, =0

	// SETUP

    /* habilitar reloj para GPIOA y GPIOC */
    LDR r0, =RCC_AHB1ENR
    LDR r1, [r0]
    // GPIOA
    ORR r1, r1, #(1 << 0)
    // GPIOC
    ORR r1, r1, #(1 << 2)
    STR r1, [r0]

    /* PC13 como entrada */
    LDR r0, =GPIOC_MODER
    LDR r1, [r0]
    BIC r1, r1, #(0x3 << (BUTTON_PIN * 2))  // asegurarse que sea entrada
    STR r1, [r0]

    // PA5 como salida
    LDR r0, =GPIOA_MODER
    LDR r1, [r0]
    BIC r1, r1, #(0x3 << (LED_PIN_PA5 * 2))   // limpiar bits 11:10
    ORR r1, r1, #(0x1 << (LED_PIN_PA5 * 2))
    STR r1, [r0]

    // (inciso 1) configurar y encender PA$ con subrutinas
	B configurar_pa4

loop:
    // lee el estado del switch
    LDR r0, =GPIOC_IDR
    LDR r1, [r0]
    LSR r1, r1, #BUTTON_PIN
    AND r1, r1, #1

	// if SWITCH == LOW
    CMP r1, #0
    // (inciso 3) aumentar el contador de pulsaciones
    BEQ button_count

button_released:
    // PA5 apagado por defecto
    LDR r0, =GPIOA_ODR
    LDR r1, [r0]
    BIC r1, r1, #(1 << LED_PIN_PA5)
    STR r1, [r0]
    B loop

button_pressed:
    // encender PA5
    LDR r0, =GPIOA_ODR
    LDR r1, [r0]
    ORR r1, r1, #(1 << LED_PIN_PA5)
    STR r1, [r0]
    B loop


button_count:
    ADD R2, R2, #1
    // (inciso 2) encender un led cuando se pulse el boton
    B button_pressed

// (inciso 5) shifts
shifts_on_r0:
	// con el valor actual de R0
	LSL R0, R0, #3 // izquierda
	ASR R0, R0, #3 // derecha
	B subrutina_aritmetica

// (inciso 4) operaciones aritmeticas
subrutina_aritmetica:
    LDR R3, =10
    LDR R4, =5
    LDR R5, =3
    LDR R6, =4

    // R9 = (R1 + R2) - (R3 * 4)
    ADD R7, R3, R4
    MUL R8, R5, R6
    SUB R9, R7, R8
	B loop

encender_pa4:
	// (inciso 1) configurar pa4 con subrutinas
	LDR r0, =GPIOA_ODR
    LDR r1, [r0]
    ORR r1, r1, #(1 << LED_PIN_PA4)
    STR r1, [r0]
    // (inciso 5) link a subrutina del inciso 5
    B shifts_on_r0

configurar_pa4:
	// (inciso 1) encender pa4 con subrutinas
	LDR r0, =GPIOA_MODER
    LDR r1, [r0]
    BIC r1, r1, #(0x3 << (LED_PIN_PA4 * 2))   // limpiar bits 11:10
    ORR r1, r1, #(0x1 << (LED_PIN_PA4 * 2))   // establecer 01 (salida)
    STR r1, [r0]
    B encender_pa4




