;;Chess Game by: Daniel Stuart & Luis Troscianczuk
;;Assembly info: https://github.com/simon-whitehead/assembly-fun/blob/master/windows-x64/README.md

bits 64
default rel

%define u(x) __?utf16?__(x)


%define UNICODE 0
%define USECHAR 1

%define EMPTY 0

%define KING 1
%define QUEEN 2
%define ROOK 3 
%define BISHOP 4 
%define KNIGHT 5 
%define PAWN 6

;; white: 0b0xxx
%define WHITE(x) x
;; black: 0b1xxx
%define BLACK(x) x + 8

%define CHAR_EMPTY u(` `)

%if UNICODE

%if USECHAR
%define CHAR_KING 10
%define CHAR_QUEEN 16
%define CHAR_ROOK 17 
%define CHAR_BISHOP 1 
%define CHAR_KNIGHT 13 
%define CHAR_PAWN 15 

%define CHAR_WHITE u(`A`)
%define CHAR_BLACK u(`a`)

%else

%define CHAR_KING 1
%define CHAR_QUEEN 2
%define CHAR_ROOK 3
%define CHAR_BISHOP 4
%define CHAR_KNIGHT 5
%define CHAR_PAWN 6

%define CHAR_WHITE u(`\u2653`)
%define CHAR_BLACK u(`\u2659`)
%endif

%define VERTICAL u(`\u2502`)
%define MIDDLE u(`\u23af`)
%define CROSS u(`\u253c`)
%define RIGHTCROSS u(`\u251c`)
%define LEFTCROSS u(`\u2524`)

%define BOTLEFTCROSS u(`\u2514`)
%define BOTRIGHTCROSS u(`\u2518`)
%define BOTCROSS u(`\u2534`)

%define TOPLEFTCROSS u(`\u250c`)
%define TOPRIGHTCROSS u(`\u2510`)
%define TOPCROSS u(`\u252c`)

%else

%define CHAR_KING 10
%define CHAR_QUEEN 16
%define CHAR_ROOK 17 
%define CHAR_BISHOP 1 
%define CHAR_KNIGHT 13 
%define CHAR_PAWN 15 

%define CHAR_WHITE u(`A`)
%define CHAR_BLACK u(`a`)

%define VERTICAL u(`|`)
%define MIDDLE u(`-`)
%define CROSS u(`+`)
%define RIGHTCROSS u(`+`)
%define LEFTCROSS u(`+`)

%define BOTLEFTCROSS u(`+`)
%define BOTRIGHTCROSS u(`+`)

%define TOPLEFTCROSS u(`+`)
%define TOPRIGHTCROSS u(`+`)

%endif

%define TABLE(x, y) chessTable + x + y*8

segment .data
    columNames:
        dw  u(`  `),
        dw  u(`  A `), VERTICAL
        dw  u(` B `), VERTICAL
        dw  u(` C `), VERTICAL
        dw  u(` D `), VERTICAL
        dw  u(` E `), VERTICAL
        dw  u(` F `), VERTICAL
        dw  u(` G `), VERTICAL
        dw  u(` H `)
        dw  0xd, 0xa, 0
    header:
        dw u(`  `), TOPLEFTCROSS
        times 7 dw MIDDLE, MIDDLE, MIDDLE, CROSS
        dw MIDDLE, MIDDLE, MIDDLE, TOPRIGHTCROSS
        dw  0xd, 0xa, 0
    footer:
        dw u(`  `), BOTLEFTCROSS
        times 7 dw MIDDLE, MIDDLE, MIDDLE, CROSS
        dw MIDDLE, MIDDLE, MIDDLE, BOTRIGHTCROSS
        dw  0xd, 0xa, 0
    middle:
        dw MIDDLE, MIDDLE, CROSS
        times 7 dw MIDDLE, MIDDLE, MIDDLE, CROSS
        dw MIDDLE, MIDDLE, MIDDLE, CROSS, MIDDLE, MIDDLE
        dw  0xd, 0xa, 0
    row:
        dw u(`%hhu `)
        times 8 dw VERTICAL, u(` %lc `)
        dw VERTICAL
        dw u(` %hhu`)
        dw 0xd, 0xa, 0
    
    newLine: dw 0xd, 0xa, 0
    
    printCommand: dw u(`Command: `), 0

    computerPlaying: dw u(`Computer is playing...`), 0xd, 0xa, 0
    
    getCommand: dw u(` %7s`), 0

    invalidMove: dw u(`Move is invalid!`), 0xd, 0xa, 0
    prohibitedMove: dw u(`Move is prohibited!`), 0xd, 0xa, 0
    winner: dw u(`You won the game!`), 0xd, 0xa, 0
    loser: dw u(`You lost the game!`), 0xd, 0xa, 0
    draw: dw u(`The game was tied!`), 0xd, 0xa, 0

segment .bss
    curRow: resb 1
    curPointer: resq 1
    chessTable: resb 8*8
    command: resb 8

segment .text

global main
extern userMove
extern computerMove
extern _CRT_INIT
extern wprintf
extern wscanf
extern getchar 
extern __acrt_iob_func
extern _fileno
extern _setmode
extern ExitProcess

;;START: MAIN
main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32 ;;Allocate space for calls
    
    call    _CRT_INIT

 %if UNICODE
    ;;START: Windows set UTF-16
    mov     ecx, 1          ; Ix
    call    __acrt_iob_func
    mov     rcx, rax        ; Stream
    call    _fileno
    mov     edx, 20000h     ; Mode
    mov     ecx, eax        ; FileHandle
    call    _setmode
    ;;END: Windows set UTF-16
%endif

    mov     al, WHITE(ROOK)
    mov     [TABLE(0, 0)], al
    mov     al, WHITE(KNIGHT)
    mov     [TABLE(1, 0)], al
    mov     al, WHITE(BISHOP)
    mov     [TABLE(2, 0)], al
    mov     al, WHITE(QUEEN)
    mov     [TABLE(3, 0)], al
    mov     al, WHITE(KING)
    mov     [TABLE(4, 0)], al
    mov     al, WHITE(BISHOP)
    mov     [TABLE(5, 0)], al
    mov     al, WHITE(KNIGHT)
    mov     [TABLE(6, 0)], al
    mov     al, WHITE(ROOK)
    mov     [TABLE(7, 0)], al

    mov     al, WHITE(PAWN)
    mov     [TABLE(0, 1)], al
    mov     [TABLE(1, 1)], al
    mov     [TABLE(2, 1)], al
    mov     [TABLE(3, 1)], al
    mov     [TABLE(4, 1)], al
    mov     [TABLE(5, 1)], al
    mov     [TABLE(6, 1)], al
    mov     [TABLE(7, 1)], al

    mov     al, BLACK(PAWN)
    mov     [TABLE(0, 6)], al
    mov     [TABLE(1, 6)], al
    mov     [TABLE(2, 6)], al
    mov     [TABLE(3, 6)], al
    mov     [TABLE(4, 6)], al
    mov     [TABLE(5, 6)], al
    mov     [TABLE(6, 6)], al
    mov     [TABLE(7, 6)], al

    mov     al, BLACK(ROOK)
    mov     [TABLE(0, 7)], al
    mov     al, BLACK(KNIGHT)
    mov     [TABLE(1, 7)], al
    mov     al, BLACK(BISHOP)
    mov     [TABLE(2, 7)], al
    mov     al, BLACK(QUEEN)
    mov     [TABLE(3, 7)], al
    mov     al, BLACK(KING)
    mov     [TABLE(4, 7)], al
    mov     al, BLACK(BISHOP)
    mov     [TABLE(5, 7)], al
    mov     al, BLACK(KNIGHT)
    mov     [TABLE(6, 7)], al
    mov     al, BLACK(ROOK)
    mov     [TABLE(7, 7)], al

MAINLOOP:
    call    PRINT
    call    GETMOVE

    mov     rcx, chessTable
    mov     rdx, command
    call    userMove

    cmp     al, 0
    je      COMPMOVE

    cmp     al, 1
    je      PROHIBITED

    cmp     al, 2
    je      INVALID

    cmp     al, 3
    je      WON

    cmp     al, 4
    je      LOST

    mov     rcx, draw
    call    wprintf

    jmp     END

WON:
    mov     rcx, winner
    call    wprintf

    jmp     END

PROHIBITED:
    mov     rcx, prohibitedMove
    call    wprintf

    jmp     MAINLOOP

INVALID:
    mov     rcx, invalidMove
    call    wprintf

    jmp     MAINLOOP

COMPMOVE:
    call    PRINT

    mov     rcx, computerPlaying
    call    wprintf

    mov     rcx, chessTable
    mov     rdx, 4
    call    computerMove

    cmp     al, 0
    je      MAINLOOP

    cmp     al, 3
    je      WON

    cmp     al, 4
    je      LOST

    mov     rcx, draw
    call    wprintf
    jmp     END

LOST:
    mov     rcx, loser
    call    wprintf

END:
    call    getchar
    call    getchar
    call    ExitProcess
;;END: MAIN

;;START: GETMOVE FUNCTION
GETMOVE:
    sub     rsp, 32

    ;;START: Old Column
    mov     rcx, printCommand
    call    wprintf

    mov     rcx, getCommand
    mov     rdx, command
    call    wscanf
    ;;END: Old Column

    add     rsp, 32
    ret
;;END: GETMOVE FUNCTION

;;START: Print table function
PRINT:
    sub     rsp, 32 ;;Allocate space for calls
    mov     rcx, columNames
    call    wprintf

    mov     rcx, header
    call    wprintf

    mov     rax, TABLE(7, 7)
    mov     dl, 9
    mov     [curRow], dl
PRINTLOOP:
    ;;Add parameters (8 in total: rcx, rdx, r8, r9, stack...)
    sub     rsp, 56 ;;Allocate space for parameters

    call    CHESSCHAR
    mov     [rsp + 32 + 40], bx
    dec     rax
    call    CHESSCHAR
    mov     [rsp + 32 + 32], bx
    dec     rax

    call    CHESSCHAR
    mov     [rsp + 32 + 24], bx
    dec     rax
    call    CHESSCHAR
    mov     [rsp + 32 + 16], bx
    dec     rax
    call    CHESSCHAR
    mov     [rsp + 32 + 8], bx
    dec     rax
    call    CHESSCHAR
    mov     [rsp + 32], bx
    dec     rax
    call    CHESSCHAR
    mov     r9w, bx
    dec     rax
    call    CHESSCHAR
    mov     r8w, bx
    dec     rax

    mov     rcx, row

    xor     rdx, rdx
    mov     dl, [curRow]
    dec     dl
    mov     [curRow], dl

    mov     [rsp + 32 + 48], dx

    mov     [curPointer], rax

    call    wprintf

    add     rsp, 56 ;;Deallocate space for parameters

    mov     rax, [curPointer]

    mov     rbx, chessTable
    cmp     rax, rbx
    jl      NOPRINT

    mov     rcx, middle
    call    wprintf

    mov     rax, [curPointer]

NOPRINT:
    mov     rbx, chessTable
    cmp     rax, rbx
    jg      PRINTLOOP


    mov     rcx, footer
    call    wprintf

    mov     rcx, columNames
    call    wprintf

    mov     rcx, newLine
    call    wprintf

    add     rsp, 32 ;;Deallocate space for parameters
    ret
;;END: Print table function

;;START: Chess to char function
CHESSCHAR:
    mov     cl, [rax]

    xor     bx, bx
    cmp     cl, BLACK(EMPTY)
    jg      BLACKCHAR
    mov     dx, CHAR_WHITE

CHESSCMP:
    and     cl, 7
    cmp     cl, KING
    je      KINGCHAR

    cmp     cl, QUEEN
    je      QUEENCHAR

    cmp     cl, ROOK
    je      ROOKCHAR

    cmp     cl, BISHOP
    je      BISHOPCHAR

    cmp     cl, KNIGHT
    je      KNIGHTCHAR

    cmp     cl, PAWN
    je      PAWNCHAR

    jmp     EMPTYCHAR

BLACKCHAR:
    mov     dx, CHAR_BLACK
    jmp     CHESSCMP

KINGCHAR:
    mov     bx, CHAR_KING
    jmp     C2CEND

QUEENCHAR:
    mov     bx, CHAR_QUEEN
    jmp     C2CEND

ROOKCHAR:
    mov     bx, CHAR_ROOK
    jmp     C2CEND

BISHOPCHAR:
    mov     bx, CHAR_BISHOP
    jmp     C2CEND

KNIGHTCHAR:
    mov     bx, CHAR_KNIGHT
    jmp     C2CEND

PAWNCHAR:
    mov     bx, CHAR_PAWN
    jmp     C2CEND

EMPTYCHAR:
    mov     bx, CHAR_EMPTY
    ret

C2CEND:
    add     bx, dx
    ret
;;END: Chess to char function