; I have abided by the UNCG Academic Integrity Policy.
; Author: Joshua Crotts
; 
; This program asks the user to input 15 numbers between the range of -100 and 100.
; Following this, each number has a calculation performed. If the number is even, it
; is multiplied by its index plus 1. Conversely, if it is odd, it is divide by its index + 1.
; These newly computed values are then stored in the array in the index they originated from.

;Assignment5-Q5
;Joshua Crotts


INCLUDE io.h            ; header file for input/output

.586
.MODEL FLAT

.STACK 4096

.DATA
resultsLabel		BYTE	"Results: ", 0
resultsArray		BYTE	165 DUP(?), 0		; 11 bytes per result * 15 values
		
array			DWORD	15 DUP(?)		; Integers
tmp			DWORD	0			; Temp variable
stringOffSet		DWORD	0			; String offset 
ELEVEN_BYTES		DWORD	11			; Constant for 11 Bytes


intBuffer		BYTE	11 DUP(?)						; dtoa macro usage
prompt1			BYTE    "Enter your numbers: ", 0
above100Label		BYTE	"Your number must be less than or equal to 100.", 0
belowNeg100Label	BYTE	"Your number must be greater than or equal to -100.", 0
buffer			BYTE	40 DUP (?)						; Input buffer

.CODE
_MainProc PROC
										; eax register is ALWAYS for input
				lea		esi, array			; Load array into esi register for use
				mov		ecx, 15				; Loop 15 times
				mov		ebx, 0				; Offset for ResultsArray (Strings for display)
				mov		edx, 0				; Offset for array (actual dword data)
				
inputLoop:     			input		prompt1, buffer, 40		; read ASCII characters
				atod   		buffer				; convert to integer

cmp100:				cmp		eax, 100			; Checks to see if integer is greater than 100
				jg		above100			; If so, jump to re-input that integer

cmpNeg100:			cmp		eax, -100			; Checks to see if integer is less than -100
				jl		belowNeg100			; If so, jump to re-input a bigger integer
				
				add		esi, edx			; Adds offset to esi pointer
				add		DWORD PTR[esi], eax		; If the number is valid, input it into the array
				add		edx, 4				; Offset pointer in array to next index

				lea     	esi, resultsArray		; Loads results array (strings) into esi
				add		esi, ebx			; Adds offset to esi pointer

				dtoa		[esi], eax						
				add		ebx, 11				; Applies 11 byte offset to array for next string 
				lea		esi, array			; Reassigns esi to numeric array for next digit
				loop		inputLoop			; Loop back to top

				output		resultsLabel, resultsArray
				jmp		arithmetic			; Once loop is done, jump to next place in program 
										; where procedure is called
				

above100:			input		above100Label, buffer, 40	; Prompt the user that input > 100
				atod		buffer
				jmp		cmp100				; Recompare the number to the proper range

belowNeg100:			input		belowNeg100Label, buffer, 40	; Prompt the user that input < 100
				atod		buffer
				jmp		cmp100

				
arithmetic:			sub		esi, 60				; Applies a -60 (4 bytes x 15 indices) offset on the esi 
										; pointer so we can return to the beginning index
				mov		ecx, 15
				mov		edx, 0				; Index counter
				mov		ebx, 0				; String index counter

functionLoop:	lea		esi, 		array				; Loads array into esi
				add		esi, ebx			; Adds offset for array pointer
				mov		eax, [esi]			; Grabs element at offset index
				push		edx				; Adds current index to stack
				push		eax				; Adds current element to stack
				call		positionalMath			; Calls function
				add		esp, 8				; Adds 8 to the stack pointer to reassign it
				
				add		DWORD PTR[esi], eax		; Moves returned value into index in array
				add		ebx, 4				; Adds 4 to array pointer

				lea		esi, resultsArray		; Assigns esi to the resultsArray so we can insert the string version
				add		esi, stringOffSet		; Applies current byte offset to string (11 x index)
				dtoa		[esi], eax			; Converts eax to index in string array
				mov		eax, ELEVEN_BYTES		; Moves the permanent 11 byte offset var to eax for temp usage
				inc		edx						
				imul		eax, edx			; Multiplies permanent 11 byte offset by whatever our index is
				mov		stringOffSet, eax		; Assigns tmpOffSet var to next String array offset

				loop		functionLoop

				output		resultsLabel, resultsArray
			
				mov     	eax, 0				; exit with return code 0

				ret
_MainProc ENDP


positionalMath PROC
				push		ebp				; Pushes the stack base pointer to the stack
				mov		ebp, esp			; Moves the current stack pointer to the base pointer
				push		ecx				; Pushes current value of ecx onto stack
				push		edx				; Pushes current value of edx onto stack (to save)
				
				mov		ecx, [ebp + 8]			; Access first parameter
				mov		edx, [ebp + 12]			; Access second parameter
				mov		eax, ecx			; Moves first parameter into temp register

				inc		edx				; Increments edx for integer offset (described by the problem)
				mov		tmp, edx			; Need to store the index value in ebx in case a division occurs
										; to prevent a divide by zero from cdq
				and		ecx, 1				; Checks to see if ecx is odd (anything ANDed by 1 which results in 1 is odd)
				cmp		ecx, 1				; Subtracts 1 from either 0 or 1
				je		odd				; Jump if odd
				jl		evenF				; Jump if even b.c. 0 - 1 = -1

odd:				cdq		
				idiv		tmp				; Divides the buffer by edx (index + 1)
				jmp		continue

evenF:				imul		eax, edx			; Multiplies the buffer by edx (index + 1)
				
continue:			pop		edx				; Pops the original edx, ecx and base pointer 
				pop		ecx				; parameters off the stack
				pop		ebp
				ret
positionalMath ENDP

END								; end of source code

