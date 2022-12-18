;Program compiled by Great Cow BASIC (0.99.01 2022-01-27 (Windows 64 bit) : Build 1073) for Microchip MPASM
;Need help? See the GCBASIC forums at http://sourceforge.net/projects/gcbasic/forums,
;check the documentation or email w_cholmondeley at users dot sourceforge dot net.

;********************************************************************************

;Set up the assembler options (Chip type, clock source, other bits and pieces)
 LIST p=16F887, r=DEC
#include <P16F887.inc>
 __CONFIG _CONFIG1, _LVP_OFF & _FCMEN_ON & _CPD_OFF & _CP_OFF & _MCLRE_OFF & _WDTE_OFF & _INTOSCIO
 __CONFIG _CONFIG2, _WRT_OFF

;********************************************************************************

;Set aside memory locations for variables
ADREADPORT                       EQU 32
ADTEMP                           EQU 33
DELAYTEMP                        EQU 112
DELAYTEMP2                       EQU 113
FIREVALUE                        EQU 34
LCDBYTE                          EQU 35
LCDCOLUMN                        EQU 36
LCDLINE                          EQU 37
LCDVALUE                         EQU 38
LCDVALUETEMP                     EQU 39
LCD_STATE                        EQU 40
PRINTLEN                         EQU 41
READAD                           EQU 42
STRINGPOINTER                    EQU 43
SYSBYTETEMPA                     EQU 117
SYSBYTETEMPB                     EQU 121
SYSBYTETEMPX                     EQU 112
SYSCALCTEMPA                     EQU 117
SYSCALCTEMPX                     EQU 112
SYSDIVLOOP                       EQU 116
SYSDIVMULTA                      EQU 119
SYSDIVMULTA_H                    EQU 120
SYSDIVMULTB                      EQU 123
SYSDIVMULTB_H                    EQU 124
SYSDIVMULTX                      EQU 114
SYSDIVMULTX_H                    EQU 115
SYSLCDTEMP                       EQU 44
SYSPRINTDATAHANDLER              EQU 45
SYSPRINTDATAHANDLER_H            EQU 46
SYSPRINTTEMP                     EQU 47
SYSREPEATTEMP1                   EQU 48
SYSSTRINGA                       EQU 119
SYSSTRINGA_H                     EQU 120
SYSSTRINGB                       EQU 114
SYSSTRINGB_H                     EQU 115
SYSSTRINGLENGTH                  EQU 118
SYSSTRINGPARAM1                  EQU 488
SYSTEMP1                         EQU 49
SYSTEMP1_H                       EQU 50
SYSTEMP2                         EQU 51
SYSTEMP2_H                       EQU 52
SYSWAITTEMP10US                  EQU 117
SYSWAITTEMPMS                    EQU 114
SYSWAITTEMPMS_H                  EQU 115
SYSWAITTEMPUS                    EQU 117
SYSWAITTEMPUS_H                  EQU 118
SYSWORDTEMPA                     EQU 117
SYSWORDTEMPA_H                   EQU 118
SYSWORDTEMPB                     EQU 121
SYSWORDTEMPB_H                   EQU 122
SYSWORDTEMPX                     EQU 112
SYSWORDTEMPX_H                   EQU 113
WALLDIST1                        EQU 53
WALLDIST2                        EQU 54

;********************************************************************************

;Alias variables
ALLANSEL EQU 392
ALLANSEL_H EQU 393
SYSREADADBYTE EQU 42

;********************************************************************************

;Vectors
	ORG	0
	pagesel	BASPROGRAMSTART
	goto	BASPROGRAMSTART
	ORG	4
	retfie

;********************************************************************************

;Start of program memory page 0
	ORG	5
BASPROGRAMSTART
;Call initialisation routines
	call	INITSYS
	call	INITLCD

;Start of the main program
;Components
;#DEFINE MotorL PortB.2
;#DEFINE MotorL2 PortB.3
;#DEFINE MotorR PortB.4
;#DEFINE MotorR2 PortB.5
;#DEFINE WallDet1 PortA.0 'D2, AN0
;#DEFINE WallDet2 PortA.1 'D3, AN1
;#DEFINE LineDet PortA.3 'D5, AN3
;#DEFINE FireDet PortA.5 'D7, AN4
;#DEFINE FanMotor PortB.1
;LCD display
;#DEFINE LCD_IO 4
;#DEFINE LCD_RS portd.0
;#DEFINE LCD_RW portd.1
;#DEFINE LCD_Enable portd.2
;#DEFINE LCD_DB4 portd.4
;#DEFINE LCD_DB5 portd.5
;#DEFINE LCD_DB6 portd.6
;#DEFINE LCD_DB7 portd.7
;Pinout
;Dir MotorL Out
	banksel	TRISB
	bcf	TRISB,2
;Dir MotorL2 Out
	bcf	TRISB,3
;Dir MotorR Out
	bcf	TRISB,4
;Dir MotorR2 Out
	bcf	TRISB,5
;Dir LineDet In
	bsf	TRISA,3
;Dir WallDet1 In
	bsf	TRISA,0
;Dir WallDet2 In
	bsf	TRISA,1
;Dir FireDet In
	bsf	TRISA,5
;Dir FanMotor Out
	bcf	TRISB,1
;Variables
;Dim wallDist as byte
;Dim deltaWallDist as byte
;Dim fireValue as byte
;Void setup
;FanMotor = false
	banksel	PORTB
	bcf	PORTB,1
;LineDet = true
	bsf	PORTA,3
;Motors on by default
;MotorL = true
	bsf	PORTB,2
;MotorR = true
	bsf	PORTB,4
;MotorL2 = false
	bcf	PORTB,3
;MotorR2 = false
	bcf	PORTB,5
;Void loop
;Do
SysDoLoop_S1
;Loop initialization
;wallDist1 = ReadAD(AN0);
	clrf	ADREADPORT
	call	FN_READAD9
	movf	SYSREADADBYTE,W
	movwf	WALLDIST1
;wallDist1 = (((6787/(wallDist1-3)))-4)/5
	movlw	3
	subwf	WALLDIST1,W
	movwf	SysTemp1
	movlw	131
	movwf	SysWORDTempA
	movlw	26
	movwf	SysWORDTempA_H
	movf	SysTemp1,W
	movwf	SysWORDTempB
	clrf	SysWORDTempB_H
	call	SYSDIVSUB16
	movf	SysWORDTempA,W
	movwf	SysTemp2
	movf	SysWORDTempA_H,W
	movwf	SysTemp2_H
	movlw	4
	subwf	SysTemp2,W
	movwf	SysTemp1
	movf	SysTemp2_H,W
	movwf	SysTemp1_H
	movlw	0
	btfss	STATUS,C
	movlw	0 + 1
	subwf	SysTemp1_H,F
	movf	SysTemp1,W
	movwf	SysWORDTempA
	movf	SysTemp1_H,W
	movwf	SysWORDTempA_H
	movlw	5
	movwf	SysWORDTempB
	clrf	SysWORDTempB_H
	call	SYSDIVSUB16
	movf	SysWORDTempA,W
	movwf	WALLDIST1
;wallDist2 = ReadAD(AN1);
	movlw	1
	movwf	ADREADPORT
	call	FN_READAD9
	movf	SYSREADADBYTE,W
	movwf	WALLDIST2
;wallDist2 = (((6787/(wallDist2-3)))-4)/5
	movlw	3
	subwf	WALLDIST2,W
	movwf	SysTemp1
	movlw	131
	movwf	SysWORDTempA
	movlw	26
	movwf	SysWORDTempA_H
	movf	SysTemp1,W
	movwf	SysWORDTempB
	clrf	SysWORDTempB_H
	call	SYSDIVSUB16
	movf	SysWORDTempA,W
	movwf	SysTemp2
	movf	SysWORDTempA_H,W
	movwf	SysTemp2_H
	movlw	4
	subwf	SysTemp2,W
	movwf	SysTemp1
	movf	SysTemp2_H,W
	movwf	SysTemp1_H
	movlw	0
	btfss	STATUS,C
	movlw	0 + 1
	subwf	SysTemp1_H,F
	movf	SysTemp1,W
	movwf	SysWORDTempA
	movf	SysTemp1_H,W
	movwf	SysWORDTempA_H
	movlw	5
	movwf	SysWORDTempB
	clrf	SysWORDTempB_H
	call	SYSDIVSUB16
	movf	SysWORDTempA,W
	movwf	WALLDIST2
;fireValue = ReadAD(AN4);
	movlw	4
	movwf	ADREADPORT
	call	FN_READAD9
	movf	SYSREADADBYTE,W
	movwf	FIREVALUE
;CLS
	call	CLS
;Locate 0,0
	clrf	LCDLINE
	clrf	LCDCOLUMN
	call	LOCATE
;print("Front: ")
	movlw	low SYSSTRINGPARAM1
	movwf	SysStringB
	movlw	high SYSSTRINGPARAM1
	movwf	SysStringB_H
	movlw	low StringTable1
	movwf	SysStringA
	movlw	high StringTable1
	movwf	SysStringA_H
	call	SYSREADSTRING
	movlw	low SYSSTRINGPARAM1
	movwf	SysPRINTDATAHandler
	movlw	high SYSSTRINGPARAM1
	movwf	SysPRINTDATAHandler_H
;SYSSTRINGPARAM*1
	call	PRINT111
;print (wallDist1)
	movf	WALLDIST1,W
	movwf	LCDVALUE
	call	PRINT112
;Locate 1,0
	movlw	1
	movwf	LCDLINE
	clrf	LCDCOLUMN
	call	LOCATE
;print("Left: ")
	movlw	low SYSSTRINGPARAM1
	movwf	SysStringB
	movlw	high SYSSTRINGPARAM1
	movwf	SysStringB_H
	movlw	low StringTable2
	movwf	SysStringA
	movlw	high StringTable2
	movwf	SysStringA_H
	call	SYSREADSTRING
	movlw	low SYSSTRINGPARAM1
	movwf	SysPRINTDATAHandler
	movlw	high SYSSTRINGPARAM1
	movwf	SysPRINTDATAHandler_H
;SYSSTRINGPARAM*1
	call	PRINT111
;print (wallDist2)
	movf	WALLDIST2,W
	movwf	LCDVALUE
	call	PRINT112
;Wall hug
;Are adjustments necessary? If so, take 100 ms to make the turn
;Adjusting range, 10 - 15 good range
;if wallDist1 =< 10 & wallDist1 > 4 then
	movf	WALLDIST1,W
	movwf	SysBYTETempB
	movlw	10
	movwf	SysBYTETempA
	call	SYSCOMPLESSTHAN
	comf	SysByteTempX,F
	movf	SysByteTempX,W
	movwf	SysTemp1
	movf	WALLDIST1,W
	movwf	SysBYTETempB
	movlw	4
	movwf	SysBYTETempA
	call	SYSCOMPLESSTHAN
	movf	SysTemp1,W
	andwf	SysByteTempX,W
	movwf	SysTemp2
	btfss	SysTemp2,0
	goto	ELSE1_1
;print ("Reverse")
	movlw	low SYSSTRINGPARAM1
	movwf	SysStringB
	movlw	high SYSSTRINGPARAM1
	movwf	SysStringB_H
	movlw	low StringTable3
	movwf	SysStringA
	movlw	high StringTable3
	movwf	SysStringA_H
	call	SYSREADSTRING
	movlw	low SYSSTRINGPARAM1
	movwf	SysPRINTDATAHandler
	movlw	high SYSSTRINGPARAM1
	movwf	SysPRINTDATAHandler_H
;SYSSTRINGPARAM*1
	call	PRINT111
;gosub Reverse
	call	REVERSE
;else if wallDist2 > 25 then
	goto	ENDIF1
ELSE1_1
	movf	WALLDIST2,W
	sublw	25
	btfsc	STATUS, C
	goto	ELSE1_2
;gosub TurnLeftSharp
	call	TURNLEFTSHARP
;print("Left Sharp")
;else if wallDist2 > 20 then
	goto	ENDIF1
ELSE1_2
	movf	WALLDIST2,W
	sublw	20
	btfsc	STATUS, C
	goto	ELSE1_3
;gosub TurnLeft
	call	TURNLEFT
;else if wallDist2 < 10 then
	goto	ENDIF1
ELSE1_3
	movlw	10
	subwf	WALLDIST2,W
	btfsc	STATUS, C
	goto	ELSE1_4
;gosub TurnRight
	call	TURNRIGHT
;else
	goto	ENDIF1
ELSE1_4
;gosub Straight
	call	STRAIGHT
;end if
ENDIF1
;Continue forward for 200 ms before checking anything else (eg. adjustments)
;MotorL = true
;MotorR = true
;wait 200 ms
;Stop completely when front distance < 10
;if wallDist1 < 15 then
;MotorL = false
;MotorR = false
;end if
;if wallDist1 < 15 | wallDist2 < 15 then
;MotorL = false
;MotorR = false
;else
;MotorL = true
;MotorR = true
;end if
;Line detection
;if LineDet = 0 then
;print "L: White"
;MotorL = true
;MotorL2 = false
;MotorR = true
;MotorR2 = false
;end if
;if LineDet = 1 then
;print "L: Black"
;MotorL = false
;MotorL2 = false
;MotorR = false
;MotorR2 = false
;end if
;Fire detection
;Locate (0, 0)
;print(" F: ")
;print(fireValue)
;if fireValue < 100 then
;FanMotor = true
;else
;FanMotor = false
;end if
;Loop
	goto	SysDoLoop_S1
SysDoLoop_E1
BASPROGRAMEND
	sleep
	goto	BASPROGRAMEND

;********************************************************************************

;Source: lcd.h (955)
CHECKBUSYFLAG
;Sub that waits until LCD controller busy flag goes low (ready)
;Only used by LCD_IO 4,8 and only when LCD_NO_RW is NOT Defined
;Called by sub LCDNOrmalWriteByte
;LCD_RSTemp = LCD_RS
	bcf	SYSLCDTEMP,2
	btfsc	PORTD,0
	bsf	SYSLCDTEMP,2
;DIR SCRIPT_LCD_BF  IN
	banksel	TRISD
	bsf	TRISD,7
;SET LCD_RS OFF
	banksel	PORTD
	bcf	PORTD,0
;SET LCD_RW ON
	bsf	PORTD,1
;Do
SysDoLoop_S3
;Set LCD_Enable ON
	bsf	PORTD,2
;wait 1 us
	goto	$+1
;SysLCDTemp.7 = SCRIPT_LCD_BF
	bcf	SYSLCDTEMP,7
	btfsc	PORTD,7
	bsf	SYSLCDTEMP,7
;Set LCD_Enable OFF
	bcf	PORTD,2
;Wait 1 us
	goto	$+1
;PulseOut LCD_Enable, 1 us
;Macro Source: stdbasic.h (186)
;Set Pin On
	bsf	PORTD,2
;WaitL1 Time
	nop
;Set Pin Off
	bcf	PORTD,2
;Wait 1 us
	goto	$+1
;Loop While SysLCDTemp.7 <> 0
	btfsc	SYSLCDTEMP,7
	goto	SysDoLoop_S3
SysDoLoop_E3
;LCD_RS = LCD_RSTemp
	bcf	PORTD,0
	btfsc	SYSLCDTEMP,2
	bsf	PORTD,0
	return

;********************************************************************************

;Source: lcd.h (364)
CLS
;Sub to clear the LCD
;SET LCD_RS OFF
	bcf	PORTD,0
;Clear screen
;LCDWriteByte (0b00000001)
	movlw	1
	movwf	LCDBYTE
	call	LCDNORMALWRITEBYTE
;Wait 4 ms
	movlw	4
	movwf	SysWaitTempMS
	clrf	SysWaitTempMS_H
	call	Delay_MS
;Move to start of visible DDRAM
;LCDWriteByte(0x80)
	movlw	128
	movwf	LCDBYTE
	call	LCDNORMALWRITEBYTE
;Wait 50 us
	movlw	33
	movwf	DELAYTEMP
DelayUS1
	decfsz	DELAYTEMP,F
	goto	DelayUS1
	return

;********************************************************************************

Delay_10US
D10US_START
	movlw	5
	movwf	DELAYTEMP
DelayUS0
	decfsz	DELAYTEMP,F
	goto	DelayUS0
	nop
	decfsz	SysWaitTemp10US, F
	goto	D10US_START
	return

;********************************************************************************

Delay_MS
	incf	SysWaitTempMS_H, F
DMS_START
	movlw	4
	movwf	DELAYTEMP2
DMS_OUTER
	movlw	165
	movwf	DELAYTEMP
DMS_INNER
	decfsz	DELAYTEMP, F
	goto	DMS_INNER
	decfsz	DELAYTEMP2, F
	goto	DMS_OUTER
	decfsz	SysWaitTempMS, F
	goto	DMS_START
	decfsz	SysWaitTempMS_H, F
	goto	DMS_START
	return

;********************************************************************************

;Source: lcd.h (437)
INITLCD
;asm showdebug  `LCD_IO selected is ` LCD_IO
;asm showdebug  `LCD_Speed is SLOW`
;asm showdebug  `OPTIMAL is set to ` OPTIMAL
;asm showdebug  `LCD_Speed is set to ` LCD_Speed
;Wait 50 ms
	movlw	50
	movwf	SysWaitTempMS
	clrf	SysWaitTempMS_H
	call	Delay_MS
;Dir LCD_RW OUT
	banksel	TRISD
	bcf	TRISD,1
;Set LCD_RW OFF
	banksel	PORTD
	bcf	PORTD,1
;Dir LCD_DB4 OUT
	banksel	TRISD
	bcf	TRISD,4
;Dir LCD_DB5 OUT
	bcf	TRISD,5
;Dir LCD_DB6 OUT
	bcf	TRISD,6
;Dir LCD_DB7 OUT
	bcf	TRISD,7
;Dir LCD_RS OUT
	bcf	TRISD,0
;Dir LCD_Enable OUT
	bcf	TRISD,2
;Set LCD_RS OFF
	banksel	PORTD
	bcf	PORTD,0
;Set LCD_Enable OFF
	bcf	PORTD,2
;Wakeup (0x30 - b'0011xxxx' )
;Set LCD_DB7 OFF
	bcf	PORTD,7
;Set LCD_DB6 OFF
	bcf	PORTD,6
;Set LCD_DB5 ON
	bsf	PORTD,5
;Set LCD_DB4 ON
	bsf	PORTD,4
;Wait 2 us
	goto	$+1
	goto	$+1
;PulseOut LCD_Enable, 2 us
;Macro Source: stdbasic.h (186)
;Set Pin On
	bsf	PORTD,2
;WaitL1 Time
	goto	$+1
	nop
;Set Pin Off
	bcf	PORTD,2
;Wait 10 ms
	movlw	10
	movwf	SysWaitTempMS
	clrf	SysWaitTempMS_H
	call	Delay_MS
;Repeat 3
	movlw	3
	movwf	SysRepeatTemp1
SysRepeatLoop1
;PulseOut LCD_Enable, 2 us
;Macro Source: stdbasic.h (186)
;Set Pin On
	bsf	PORTD,2
;WaitL1 Time
	goto	$+1
	nop
;Set Pin Off
	bcf	PORTD,2
;Wait 1 ms
	movlw	1
	movwf	SysWaitTempMS
	clrf	SysWaitTempMS_H
	call	Delay_MS
;End Repeat
	decfsz	SysRepeatTemp1,F
	goto	SysRepeatLoop1
SysRepeatLoopEnd1
;Set 4 bit mode (0x20 - b'0010xxxx')
;Set LCD_DB7 OFF
	bcf	PORTD,7
;Set LCD_DB6 OFF
	bcf	PORTD,6
;Set LCD_DB5 ON
	bsf	PORTD,5
;Set LCD_DB4 OFF
	bcf	PORTD,4
;Wait 2 us
	goto	$+1
	goto	$+1
;PulseOut LCD_Enable, 2 us
;Macro Source: stdbasic.h (186)
;Set Pin On
	bsf	PORTD,2
;WaitL1 Time
	goto	$+1
	nop
;Set Pin Off
	bcf	PORTD,2
;Wait 100 us
	movlw	66
	movwf	DELAYTEMP
DelayUS2
	decfsz	DELAYTEMP,F
	goto	DelayUS2
	nop
;===== now in 4 bit mode =====
;LCDWriteByte 0x28    '(b'00101000')  '0x28 set 2 line mode
	movlw	40
	movwf	LCDBYTE
	call	LCDNORMALWRITEBYTE
;LCDWriteByte 0x06    '(b'00000110')  'Set cursor movement
	movlw	6
	movwf	LCDBYTE
	call	LCDNORMALWRITEBYTE
;LCDWriteByte 0x0C    '(b'00001100')  'Turn off cursor
	movlw	12
	movwf	LCDBYTE
	call	LCDNORMALWRITEBYTE
;Cls  'Clear the display
	call	CLS
;LCD_State = 12
	movlw	12
	movwf	LCD_STATE
	return

;********************************************************************************

;Source: system.h (156)
INITSYS
;asm showdebug This code block sets the internal oscillator to ChipMHz
;asm showdebug 'OSCCON type is 103 - This part does not have Bit HFIOFS @ ifndef Bit(HFIOFS)
;OSCCON = OSCCON OR b'01110000'
	movlw	112
	banksel	OSCCON
	iorwf	OSCCON,F
;OSCCON = OSCCON AND b'10001111'
	movlw	143
	andwf	OSCCON,F
;Address the two true tables for IRCF
;[canskip] IRCF2, IRCF1, IRCF0 = b'111'    ;111 = 8 MHz (INTOSC drives clock directly)
	bsf	OSCCON,IRCF2
	bsf	OSCCON,IRCF1
	bsf	OSCCON,IRCF0
;End of type 103 init
;asm showdebug _Complete_the_chip_setup_of_BSR,ADCs,ANSEL_and_other_key_setup_registers_or_register_bits
;Ensure all ports are set for digital I/O and, turn off A/D
;SET ADFM OFF
	bcf	ADCON1,ADFM
;Switch off A/D Var(ADCON0)
;SET ADCON0.ADON OFF
	banksel	ADCON0
	bcf	ADCON0,ADON
;ANSEL = 0
	banksel	ANSEL
	clrf	ANSEL
;ANSELH = 0
	clrf	ANSELH
;Set comparator register bits for many MCUs with register CM2CON0
;C2ON = 0
	banksel	CM2CON0
	bcf	CM2CON0,C2ON
;C1ON = 0
	bcf	CM1CON0,C1ON
;
;'Turn off all ports
;PORTA = 0
	banksel	PORTA
	clrf	PORTA
;PORTB = 0
	clrf	PORTB
;PORTC = 0
	clrf	PORTC
;PORTD = 0
	clrf	PORTD
;PORTE = 0
	clrf	PORTE
	return

;********************************************************************************

;Source: lcd.h (1006)
LCDNORMALWRITEBYTE
;Sub to write a byte to the LCD
;CheckBusyFlag         'WaitForReady
	call	CHECKBUSYFLAG
;set LCD_RW OFF
	bcf	PORTD,1
;Dim Temp as Byte
;Pins must be outputs if returning from WaitForReady, or after LCDReadByte or GET subs
;DIR LCD_DB4 OUT
	banksel	TRISD
	bcf	TRISD,4
;DIR LCD_DB5 OUT
	bcf	TRISD,5
;DIR LCD_DB6 OUT
	bcf	TRISD,6
;DIR LCD_DB7 OUT
	bcf	TRISD,7
;Write upper nibble to output pins
;set LCD_DB4 OFF
;set LCD_DB5 OFF
;set LCD_DB6 OFF
;set LCD_DB7 OFF
;if LCDByte.7 ON THEN SET LCD_DB7 ON
;if LCDByte.6 ON THEN SET LCD_DB6 ON
;if LCDByte.5 ON THEN SET LCD_DB5 ON
;if LCDByte.4 ON THEN SET LCD_DB4 ON
;LCD_DB7 = LCDByte.7
	banksel	PORTD
	bcf	PORTD,7
	btfsc	LCDBYTE,7
	bsf	PORTD,7
;LCD_DB6 = LCDByte.6
	bcf	PORTD,6
	btfsc	LCDBYTE,6
	bsf	PORTD,6
;LCD_DB5 = LCDByte.5
	bcf	PORTD,5
	btfsc	LCDBYTE,5
	bsf	PORTD,5
;LCD_DB4 = LCDByte.4
	bcf	PORTD,4
	btfsc	LCDBYTE,4
	bsf	PORTD,4
;Wait 1 us
	goto	$+1
;PulseOut LCD_enable, 1 us
;Macro Source: stdbasic.h (186)
;Set Pin On
	bsf	PORTD,2
;WaitL1 Time
	nop
;Set Pin Off
	bcf	PORTD,2
;All data pins low
;set LCD_DB4 OFF
;set LCD_DB5 OFF
;set LCD_DB6 OFF
;set LCD_DB7 OFF
	bcf	PORTD,7
;
;'Write lower nibble to output pins
;if LCDByte.3 ON THEN SET LCD_DB7 ON
	btfsc	LCDBYTE,3
	bsf	PORTD,7
;if LCDByte.2 ON THEN SET LCD_DB6 ON
;if LCDByte.1 ON THEN SET LCD_DB5 ON
;if LCDByte.0 ON THEN SET LCD_DB4 ON
;LCD_DB7 = LCDByte.3
;LCD_DB6 = LCDByte.2
	bcf	PORTD,6
	btfsc	LCDBYTE,2
	bsf	PORTD,6
;LCD_DB5 = LCDByte.1
	bcf	PORTD,5
	btfsc	LCDBYTE,1
	bsf	PORTD,5
;LCD_DB4 = LCDByte.0
	bcf	PORTD,4
	btfsc	LCDBYTE,0
	bsf	PORTD,4
;Wait 1 us
	goto	$+1
;PulseOut LCD_enable, 1 us
;Macro Source: stdbasic.h (186)
;Set Pin On
	bsf	PORTD,2
;WaitL1 Time
	nop
;Set Pin Off
	bcf	PORTD,2
;Set data pins low again
;SET LCD_DB7 OFF
;SET LCD_DB6 OFF
;SET LCD_DB5 OFF
;SET LCD_DB4 OFF
;Wait SCRIPT_LCD_POSTWRITEDELAY
	movlw	38
	movwf	DELAYTEMP
DelayUS3
	decfsz	DELAYTEMP,F
	goto	DelayUS3
	nop
;If Register Select is low
;IF LCD_RS = 0 then
	btfsc	PORTD,0
	goto	ENDIF12
;IF LCDByte < 16 then
	movlw	16
	subwf	LCDBYTE,W
	btfsc	STATUS, C
	goto	ENDIF13
;if LCDByte > 7 then
	movf	LCDBYTE,W
	sublw	7
	btfsc	STATUS, C
	goto	ENDIF14
;LCD_State = LCDByte
	movf	LCDBYTE,W
	movwf	LCD_STATE
;end if
ENDIF14
;END IF
ENDIF13
;END IF
ENDIF12
	return

;********************************************************************************

;Source: lcd.h (350)
LOCATE
;Sub to locate the cursor
;Where LCDColumn is 0 to screen width-1, LCDLine is 0 to screen height-1
;Set LCD_RS Off
	bcf	PORTD,0
;If LCDLine > 1 Then
	movf	LCDLINE,W
	sublw	1
	btfsc	STATUS, C
	goto	ENDIF6
;LCDLine = LCDLine - 2
	movlw	2
	subwf	LCDLINE,F
;LCDColumn = LCDColumn + LCD_WIDTH
	movlw	20
	addwf	LCDCOLUMN,F
;End If
ENDIF6
;LCDWriteByte(0x80 or 0x40 * LCDLine + LCDColumn)
	movf	LCDLINE,W
	movwf	SysBYTETempA
	movlw	64
	movwf	SysBYTETempB
	call	SYSMULTSUB
	movf	LCDCOLUMN,W
	addwf	SysBYTETempX,W
	movwf	SysTemp1
	movlw	128
	iorwf	SysTemp1,W
	movwf	LCDBYTE
	call	LCDNORMALWRITEBYTE
;wait 5 10us
	movlw	5
	movwf	SysWaitTemp10US
	goto	Delay_10US

;********************************************************************************

;Overloaded signature: STRING:, Source: lcd.h (785)
PRINT111
;Sub to print a string variable on the LCD
;PrintLen = PrintData(0)
	movf	SysPRINTDATAHandler,W
	movwf	FSR
	bcf	STATUS, IRP
	btfsc	SysPRINTDATAHandler_H,0
	bsf	STATUS, IRP
	movf	INDF,W
	movwf	PRINTLEN
;If PrintLen = 0 Then Exit Sub
	movf	PRINTLEN,F
	btfsc	STATUS, Z
	return
;Set LCD_RS On
	bsf	PORTD,0
;Write Data
;For SysPrintTemp = 1 To PrintLen
	movlw	1
	movwf	SYSPRINTTEMP
SysForLoop1
;LCDWriteByte PrintData(SysPrintTemp)
	movf	SYSPRINTTEMP,W
	addwf	SysPRINTDATAHandler,W
	movwf	FSR
	bcf	STATUS, IRP
	btfsc	SysPRINTDATAHandler_H,0
	bsf	STATUS, IRP
	movf	INDF,W
	movwf	LCDBYTE
	call	LCDNORMALWRITEBYTE
;Next
;#4p Positive value Step Handler in For-next statement
	movf	SYSPRINTTEMP,W
	subwf	PRINTLEN,W
	movwf	SysTemp1
	movwf	SysBYTETempA
	clrf	SysBYTETempB
	call	SYSCOMPEQUAL
	comf	SysByteTempX,F
	btfss	SysByteTempX,0
	goto	ENDIF8
;Set LoopVar to LoopVar + StepValue where StepValue is a positive value
	incf	SYSPRINTTEMP,F
	goto	SysForLoop1
;END IF
ENDIF8
SysForLoopEnd1
	return

;********************************************************************************

;Overloaded signature: BYTE:, Source: lcd.h (800)
PRINT112
;Sub to print a byte variable on the LCD
;LCDValueTemp = 0
	clrf	LCDVALUETEMP
;Set LCD_RS On
	bsf	PORTD,0
;IF LCDValue >= 100 Then
	movlw	100
	subwf	LCDVALUE,W
	btfss	STATUS, C
	goto	ENDIF9
;LCDValueTemp = LCDValue / 100
	movf	LCDVALUE,W
	movwf	SysBYTETempA
	movlw	100
	movwf	SysBYTETempB
	call	SYSDIVSUB
	movf	SysBYTETempA,W
	movwf	LCDVALUETEMP
;LCDValue = SysCalcTempX
	movf	SYSCALCTEMPX,W
	movwf	LCDVALUE
;LCDWriteByte(LCDValueTemp + 48)
	movlw	48
	addwf	LCDVALUETEMP,W
	movwf	LCDBYTE
	call	LCDNORMALWRITEBYTE
;End If
ENDIF9
;If LCDValueTemp > 0 Or LCDValue >= 10 Then
	movf	LCDVALUETEMP,W
	movwf	SysBYTETempB
	clrf	SysBYTETempA
	call	SYSCOMPLESSTHAN
	movf	SysByteTempX,W
	movwf	SysTemp1
	movf	LCDVALUE,W
	movwf	SysBYTETempA
	movlw	10
	movwf	SysBYTETempB
	call	SYSCOMPLESSTHAN
	comf	SysByteTempX,F
	movf	SysTemp1,W
	iorwf	SysByteTempX,W
	movwf	SysTemp2
	btfss	SysTemp2,0
	goto	ENDIF10
;LCDValueTemp = LCDValue / 10
	movf	LCDVALUE,W
	movwf	SysBYTETempA
	movlw	10
	movwf	SysBYTETempB
	call	SYSDIVSUB
	movf	SysBYTETempA,W
	movwf	LCDVALUETEMP
;LCDValue = SysCalcTempX
	movf	SYSCALCTEMPX,W
	movwf	LCDVALUE
;LCDWriteByte(LCDValueTemp + 48)
	movlw	48
	addwf	LCDVALUETEMP,W
	movwf	LCDBYTE
	call	LCDNORMALWRITEBYTE
;End If
ENDIF10
;LCDWriteByte (LCDValue + 48)
	movlw	48
	addwf	LCDVALUE,W
	movwf	LCDBYTE
	goto	LCDNORMALWRITEBYTE

;********************************************************************************

;Overloaded signature: BYTE:, Source: a-d.h (1748)
FN_READAD9
;ADFM should configured to ensure LEFT justified
;SET ADFM OFF
	banksel	ADCON1
	bcf	ADCON1,ADFM
;***************************************
;Perform conversion
;LLReadAD 1
;Macro Source: a-d.h (373)
;Code for PICs with with ANSEL register
;Dim AllANSEL As Word Alias ANSELH, ANSEL
;AllANSEL = 0
	banksel	ALLANSEL
	clrf	ALLANSEL
	clrf	ALLANSEL_H
;ADTemp = ADReadPort + 1
	banksel	ADREADPORT
	incf	ADREADPORT,W
	movwf	ADTEMP
;Set C On
	bsf	STATUS,C
;Do
SysDoLoop_S2
;Rotate AllANSEL Left
	banksel	ALLANSEL
	rlf	ALLANSEL,F
	rlf	ALLANSEL_H,F
;decfsz ADTemp,F
	banksel	ADTEMP
	decfsz	ADTEMP,F
;Loop
	goto	SysDoLoop_S2
SysDoLoop_E2
;SET ADCS1 OFF
	bcf	ADCON0,ADCS1
;SET ADCS0 ON
	bsf	ADCON0,ADCS0
;Choose port
;SET CHS0 OFF
	bcf	ADCON0,CHS0
;SET CHS1 OFF
	bcf	ADCON0,CHS1
;SET CHS2 OFF
	bcf	ADCON0,CHS2
;SET CHS3 OFF
	bcf	ADCON0,CHS3
;IF ADReadPort.0 On Then Set CHS0 On
	btfsc	ADREADPORT,0
	bsf	ADCON0,CHS0
;IF ADReadPort.1 On Then Set CHS1 On
	btfsc	ADREADPORT,1
	bsf	ADCON0,CHS1
;IF ADReadPort.2 On Then Set CHS2 On
	btfsc	ADREADPORT,2
	bsf	ADCON0,CHS2
;If ADReadPort.3 On Then Set CHS3 On
	btfsc	ADREADPORT,3
	bsf	ADCON0,CHS3
;Enable A/D
;SET ADON ON
	bsf	ADCON0,ADON
;Acquisition Delay
;Wait AD_Delay
	movlw	2
	movwf	SysWaitTemp10US
	call	Delay_10US
;Read A/D @1
;SET GO_NOT_DONE ON
	bsf	ADCON0,GO_NOT_DONE
;nop
	nop
;Wait While GO_NOT_DONE ON
SysWaitLoop1
	btfsc	ADCON0,GO_NOT_DONE
	goto	SysWaitLoop1
;Switch off A/D
;SET ADCON0.ADON OFF
	bcf	ADCON0,ADON
;ANSEL = 0
	banksel	ANSEL
	clrf	ANSEL
;ANSELH = 0
	clrf	ANSELH
;ReadAD = ADRESH
	banksel	ADRESH
	movf	ADRESH,W
	movwf	READAD
;SET ADFM OFF
	banksel	ADCON1
	bcf	ADCON1,ADFM
	banksel	STATUS
	return

;********************************************************************************

;Source: first-start-sample.gcb (141)
REVERSE
;MotorL = false
	bcf	PORTB,2
;MotorR = false
	bcf	PORTB,4
;MotorL2 = true
	bsf	PORTB,3
;MotorR2 = true
	bsf	PORTB,5
;wait 750 ms
	movlw	238
	movwf	SysWaitTempMS
	movlw	2
	movwf	SysWaitTempMS_H
	call	Delay_MS
;Start going forward
;MotorL2 = false
	bcf	PORTB,3
;MotorR2 = false
	bcf	PORTB,5
;Turn right a bit
;MotorL = true
	bsf	PORTB,2
;MotorR = false
	bcf	PORTB,4
;wait 500 ms
	movlw	244
	movwf	SysWaitTempMS
	movlw	1
	movwf	SysWaitTempMS_H
	goto	Delay_MS

;********************************************************************************

;Source: first-start-sample.gcb (135)
STRAIGHT
;MotorL = true
	bsf	PORTB,2
;MotorR = true
	bsf	PORTB,4
;wait 10 ms
	movlw	10
	movwf	SysWaitTempMS
	clrf	SysWaitTempMS_H
	call	Delay_MS
;return
	return

;********************************************************************************

;Source: system.h (2997)
SYSCOMPEQUAL
;Dim SysByteTempA, SysByteTempB, SysByteTempX as byte
;clrf SysByteTempX
	clrf	SYSBYTETEMPX
;movf SysByteTempA, W
	movf	SYSBYTETEMPA, W
;subwf SysByteTempB, W
	subwf	SYSBYTETEMPB, W
;btfsc STATUS, Z
	btfsc	STATUS, Z
;comf SysByteTempX,F
	comf	SYSBYTETEMPX,F
	return

;********************************************************************************

;Source: system.h (3023)
SYSCOMPEQUAL16
;dim SysWordTempA as word
;dim SysWordTempB as word
;dim SysByteTempX as byte
;clrf SysByteTempX
	clrf	SYSBYTETEMPX
;Test low, exit if false
;movf SysWordTempA, W
	movf	SYSWORDTEMPA, W
;subwf SysWordTempB, W
	subwf	SYSWORDTEMPB, W
;btfss STATUS, Z
	btfss	STATUS, Z
;return
	return
;Test high, exit if false
;movf SysWordTempA_H, W
	movf	SYSWORDTEMPA_H, W
;subwf SysWordTempB_H, W
	subwf	SYSWORDTEMPB_H, W
;btfss STATUS, Z
	btfss	STATUS, Z
;return
	return
;comf SysByteTempX,F
	comf	SYSBYTETEMPX,F
	return

;********************************************************************************

;Source: system.h (3302)
SYSCOMPLESSTHAN
;Dim SysByteTempA, SysByteTempB, SysByteTempX as byte
;clrf SysByteTempX
	clrf	SYSBYTETEMPX
;bsf STATUS, C
	bsf	STATUS, C
;movf SysByteTempB, W
	movf	SYSBYTETEMPB, W
;subwf SysByteTempA, W
	subwf	SYSBYTETEMPA, W
;btfss STATUS, C
	btfss	STATUS, C
;comf SysByteTempX,F
	comf	SYSBYTETEMPX,F
	return

;********************************************************************************

;Source: system.h (2712)
SYSDIVSUB
;dim SysByteTempA as byte
;dim SysByteTempB as byte
;dim SysByteTempX as byte
;Check for div/0
;movf SysByteTempB, F
	movf	SYSBYTETEMPB, F
;btfsc STATUS, Z
	btfsc	STATUS, Z
;return
	return
;Main calc routine
;SysByteTempX = 0
	clrf	SYSBYTETEMPX
;SysDivLoop = 8
	movlw	8
	movwf	SYSDIVLOOP
SYSDIV8START
;bcf STATUS, C
	bcf	STATUS, C
;rlf SysByteTempA, F
	rlf	SYSBYTETEMPA, F
;rlf SysByteTempX, F
	rlf	SYSBYTETEMPX, F
;movf SysByteTempB, W
	movf	SYSBYTETEMPB, W
;subwf SysByteTempX, F
	subwf	SYSBYTETEMPX, F
;bsf SysByteTempA, 0
	bsf	SYSBYTETEMPA, 0
;btfsc STATUS, C
	btfsc	STATUS, C
;goto Div8NotNeg
	goto	DIV8NOTNEG
;bcf SysByteTempA, 0
	bcf	SYSBYTETEMPA, 0
;movf SysByteTempB, W
	movf	SYSBYTETEMPB, W
;addwf SysByteTempX, F
	addwf	SYSBYTETEMPX, F
DIV8NOTNEG
;decfsz SysDivLoop, F
	decfsz	SYSDIVLOOP, F
;goto SysDiv8Start
	goto	SYSDIV8START
	return

;********************************************************************************

;Source: system.h (2780)
SYSDIVSUB16
;dim SysWordTempA as word
;dim SysWordTempB as word
;dim SysWordTempX as word
;dim SysDivMultA as word
;dim SysDivMultB as word
;dim SysDivMultX as word
;SysDivMultA = SysWordTempA
	movf	SYSWORDTEMPA,W
	movwf	SYSDIVMULTA
	movf	SYSWORDTEMPA_H,W
	movwf	SYSDIVMULTA_H
;SysDivMultB = SysWordTempB
	movf	SYSWORDTEMPB,W
	movwf	SYSDIVMULTB
	movf	SYSWORDTEMPB_H,W
	movwf	SYSDIVMULTB_H
;SysDivMultX = 0
	clrf	SYSDIVMULTX
	clrf	SYSDIVMULTX_H
;Avoid division by zero
;if SysDivMultB = 0 then
	movf	SYSDIVMULTB,W
	movwf	SysWORDTempA
	movf	SYSDIVMULTB_H,W
	movwf	SysWORDTempA_H
	clrf	SysWORDTempB
	clrf	SysWORDTempB_H
	call	SYSCOMPEQUAL16
	btfss	SysByteTempX,0
	goto	ENDIF22
;SysWordTempA = 0
	clrf	SYSWORDTEMPA
	clrf	SYSWORDTEMPA_H
;exit sub
	return
;end if
ENDIF22
;Main calc routine
;SysDivLoop = 16
	movlw	16
	movwf	SYSDIVLOOP
SYSDIV16START
;set C off
	bcf	STATUS,C
;Rotate SysDivMultA Left
	rlf	SYSDIVMULTA,F
	rlf	SYSDIVMULTA_H,F
;Rotate SysDivMultX Left
	rlf	SYSDIVMULTX,F
	rlf	SYSDIVMULTX_H,F
;SysDivMultX = SysDivMultX - SysDivMultB
	movf	SYSDIVMULTB,W
	subwf	SYSDIVMULTX,F
	movf	SYSDIVMULTB_H,W
	btfss	STATUS,C
	incfsz	SYSDIVMULTB_H,W
	subwf	SYSDIVMULTX_H,F
;Set SysDivMultA.0 On
	bsf	SYSDIVMULTA,0
;If C Off Then
	btfsc	STATUS,C
	goto	ENDIF23
;Set SysDivMultA.0 Off
	bcf	SYSDIVMULTA,0
;SysDivMultX = SysDivMultX + SysDivMultB
	movf	SYSDIVMULTB,W
	addwf	SYSDIVMULTX,F
	movf	SYSDIVMULTB_H,W
	btfsc	STATUS,C
	incfsz	SYSDIVMULTB_H,W
	addwf	SYSDIVMULTX_H,F
;End If
ENDIF23
;decfsz SysDivLoop, F
	decfsz	SYSDIVLOOP, F
;goto SysDiv16Start
	goto	SYSDIV16START
;SysWordTempA = SysDivMultA
	movf	SYSDIVMULTA,W
	movwf	SYSWORDTEMPA
	movf	SYSDIVMULTA_H,W
	movwf	SYSWORDTEMPA_H
;SysWordTempX = SysDivMultX
	movf	SYSDIVMULTX,W
	movwf	SYSWORDTEMPX
	movf	SYSDIVMULTX_H,W
	movwf	SYSWORDTEMPX_H
	return

;********************************************************************************

;Source: system.h (2437)
SYSMULTSUB
;dim SysByteTempA as byte
;dim SysByteTempB as byte
;dim SysByteTempX as byte
;clrf SysByteTempX
	clrf	SYSBYTETEMPX
MUL8LOOP
;movf SysByteTempA, W
	movf	SYSBYTETEMPA, W
;btfsc SysByteTempB, 0
	btfsc	SYSBYTETEMPB, 0
;addwf SysByteTempX, F
	addwf	SYSBYTETEMPX, F
;bcf STATUS, C
	bcf	STATUS, C
;rrf SysByteTempB, F
	rrf	SYSBYTETEMPB, F
;bcf STATUS, C
	bcf	STATUS, C
;rlf SysByteTempA, F
	rlf	SYSBYTETEMPA, F
;movf SysByteTempB, F
	movf	SYSBYTETEMPB, F
;btfss STATUS, Z
	btfss	STATUS, Z
;goto MUL8LOOP
	goto	MUL8LOOP
	return

;********************************************************************************

;Source: system.h (1490)
SYSREADSTRING
;Dim SysCalcTempA As Byte
;Dim SysStringLength As Byte
;Set pointer
;movf SysStringB, W
	movf	SYSSTRINGB, W
;movwf FSR
	movwf	FSR
;bcf STATUS, IRP
	bcf	STATUS, IRP
;btfsc SysStringB_H, 0
	btfsc	SYSSTRINGB_H, 0
;bsf STATUS, IRP
	bsf	STATUS, IRP
;Get length
;call SysStringTables
	call	SYSSTRINGTABLES
;movwf SysCalcTempA
	movwf	SYSCALCTEMPA
;movwf INDF
	movwf	INDF
;addwf SysStringB, F
	addwf	SYSSTRINGB, F
;goto SysStringReadCheck
	goto	SYSSTRINGREADCHECK
SYSREADSTRINGPART
;Set pointer
;movf SysStringB, W
	movf	SYSSTRINGB, W
;movwf FSR
	movwf	FSR
;decf FSR,F
;bcf STATUS, IRP
	bcf	STATUS, IRP
;btfsc SysStringB_H, 0
	btfsc	SYSSTRINGB_H, 0
;bsf STATUS, IRP
	bsf	STATUS, IRP
;Get length
;call SysStringTables
	call	SYSSTRINGTABLES
;movwf SysCalcTempA
	movwf	SYSCALCTEMPA
;addwf SysStringLength,F
	addwf	SYSSTRINGLENGTH,F
;addwf SysStringB,F
	addwf	SYSSTRINGB,F
;Check length
SYSSTRINGREADCHECK
;If length is 0, exit
;movf SysCalcTempA,F
	movf	SYSCALCTEMPA,F
;btfsc STATUS,Z
	btfsc	STATUS,Z
;return
	return
;Copy
SYSSTRINGREAD
;Get char
;call SysStringTables
	call	SYSSTRINGTABLES
;Set char
;incf FSR, F
	incf	FSR, F
;movwf INDF
	movwf	INDF
;decfsz SysCalcTempA, F
	decfsz	SYSCALCTEMPA, F
;goto SysStringRead
	goto	SYSSTRINGREAD
	return

;********************************************************************************

SysStringTables
	movf	SysStringA_H,W
	movwf	PCLATH
	movf	SysStringA,W
	incf	SysStringA,F
	btfsc	STATUS,Z
	incf	SysStringA_H,F
	movwf	PCL

StringTable1
	retlw	7
	retlw	70	;F
	retlw	114	;r
	retlw	111	;o
	retlw	110	;n
	retlw	116	;t
	retlw	58	;:
	retlw	32	; 


StringTable2
	retlw	6
	retlw	76	;L
	retlw	101	;e
	retlw	102	;f
	retlw	116	;t
	retlw	58	;:
	retlw	32	; 


StringTable3
	retlw	7
	retlw	82	;R
	retlw	101	;e
	retlw	118	;v
	retlw	101	;e
	retlw	114	;r
	retlw	115	;s
	retlw	101	;e


;********************************************************************************

;Source: first-start-sample.gcb (155)
TURNLEFT
;MotorL = false
	bcf	PORTB,2
;MotorR = true
	bsf	PORTB,4
;wait 5 ms
	movlw	5
	movwf	SysWaitTempMS
	clrf	SysWaitTempMS_H
	call	Delay_MS
;MotorL = true
	bsf	PORTB,2
;MotorR = true
	bsf	PORTB,4
;wait 5 ms
	movlw	5
	movwf	SysWaitTempMS
	clrf	SysWaitTempMS_H
	call	Delay_MS
;return
	return

;********************************************************************************

;Source: first-start-sample.gcb (164)
TURNLEFTSHARP
;MotorL = false
	bcf	PORTB,2
;MotorR = true
	bsf	PORTB,4
;wait 15 ms
	movlw	15
	movwf	SysWaitTempMS
	clrf	SysWaitTempMS_H
	call	Delay_MS
;MotorL = true
	bsf	PORTB,2
;MotorR = true
	bsf	PORTB,4
;wait 1 ms
	movlw	1
	movwf	SysWaitTempMS
	clrf	SysWaitTempMS_H
	call	Delay_MS
;return
	return

;********************************************************************************

;Source: first-start-sample.gcb (173)
TURNRIGHT
;MotorL = true
	bsf	PORTB,2
;MotorR = false
	bcf	PORTB,4
;wait 5 ms
	movlw	5
	movwf	SysWaitTempMS
	clrf	SysWaitTempMS_H
	call	Delay_MS
;MotorL = true
	bsf	PORTB,2
;MotorR = true
	bsf	PORTB,4
;wait 5 ms
	movlw	5
	movwf	SysWaitTempMS
	clrf	SysWaitTempMS_H
	call	Delay_MS
;return
	return
;Do:
	return

;********************************************************************************

;Start of program memory page 1
	ORG	2048
;Start of program memory page 2
	ORG	4096
;Start of program memory page 3
	ORG	6144

 END
